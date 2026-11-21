import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/database/hilo_database.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/core/security/backup_crypto_service.dart';
import 'package:hilo/core/security/biometric_guard.dart';
import 'package:hilo/core/security/secure_key_store.dart';
import 'package:hilo/features/backup/application/backup_service.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/domain/habit_repository.dart';
import 'package:hilo/features/habits/infrastructure/drift_habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/heatmap_builder.dart';
import 'package:hilo/features/tracking/domain/streak_engine.dart';
import 'package:hilo/features/tracking/infrastructure/drift_log_repository.dart';
import 'package:hilo/features/widget_sync/application/widget_sync_service.dart';
import 'package:hilo/features/widget_sync/domain/widget_snapshot.dart';
import 'package:hilo/features/widget_sync/infrastructure/android_home_widget_adapter.dart';
import 'package:uuid/uuid.dart';

/// Must be overridden in `ProviderScope` at app bootstrap (or in tests).
final databaseProvider = Provider<HiloDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden at startup');
});

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final secureKeyStoreProvider = Provider<SecureKeyStorePort>(
  (ref) => FlutterSecureKeyStore(),
);

final biometricGuardProvider = Provider<BiometricGuard>(
  (ref) => BiometricGuard(),
);

final widgetBridgeProvider = Provider<WidgetBridgePort>(
  (ref) => const AndroidHomeWidgetAdapter(),
);

final streakEngineProvider = Provider<StreakEngine>(
  (ref) => const StreakEngine(),
);

final heatmapBuilderProvider = Provider<HeatmapBuilder>(
  (ref) => const HeatmapBuilder(),
);

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => DriftHabitRepository(ref.watch(databaseProvider)),
);

final logRepositoryProvider = Provider<LogRepository>(
  (ref) => DriftLogRepository(ref.watch(databaseProvider)),
);

final widgetSyncServiceProvider = Provider<WidgetSyncService>(
  (ref) => WidgetSyncService(
    habitRepository: ref.watch(habitRepositoryProvider),
    logRepository: ref.watch(logRepositoryProvider),
    widgetBridge: ref.watch(widgetBridgeProvider),
    keyStore: ref.watch(secureKeyStoreProvider),
    clock: ref.watch(clockProvider),
    streakEngine: ref.watch(streakEngineProvider),
    heatmapBuilder: ref.watch(heatmapBuilderProvider),
  ),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    habitRepository: ref.watch(habitRepositoryProvider),
    logRepository: ref.watch(logRepositoryProvider),
    cryptoService: BackupCryptoService(),
    clock: ref.watch(clockProvider),
  ),
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Reactive stream of active habits.
final activeHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchActiveHabits();
});

/// Reactive stream of all habits (including archived).
final allHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchAllHabits();
});

/// Reactive stream of logs for the last 52 weeks (365 days).
final yearLogsProvider = StreamProvider<List<HabitLog>>((ref) {
  final today = ref.watch(clockProvider).today();
  final from = today.subtractDays(365);
  return ref.watch(logRepositoryProvider).watchLogsInRange(from, today);
});

/// Application controller for habit CRUD & daily check-ins with automatic
/// Android Home Screen widget synchronization.
final trackingControllerProvider = Provider<TrackingController>(
  (ref) => TrackingController(
    habitRepository: ref.watch(habitRepositoryProvider),
    logRepository: ref.watch(logRepositoryProvider),
    widgetSyncService: ref.watch(widgetSyncServiceProvider),
    clock: ref.watch(clockProvider),
  ),
);

final class TrackingController {
  const TrackingController({
    required this.habitRepository,
    required this.logRepository,
    required this.widgetSyncService,
    required this.clock,
  });

  final HabitRepository habitRepository;
  final LogRepository logRepository;
  final WidgetSyncService widgetSyncService;
  final Clock clock;

  static const _uuid = Uuid();

  Future<Result<Habit, AppFailure>> saveHabit({
    String? existingId,
    required String name,
    required String iconKey,
    required String colorHex,
    required HabitType type,
    required double targetValue,
    String? unit,
    required HabitSchedule schedule,
    required bool allowShields,
    String? reminderTime,
    int sortOrder = 0,
    bool isArchived = false,
    LocalDate? createdAt,
  }) async {
    final habit = Habit(
      id: existingId ?? _uuid.v4(),
      name: name.trim(),
      iconKey: iconKey,
      colorHex: colorHex,
      type: type,
      targetValue: type == HabitType.binary ? 1.0 : targetValue,
      unit: type == HabitType.binary ? null : unit?.trim(),
      schedule: schedule,
      allowShields: allowShields,
      reminderTime: reminderTime,
      sortOrder: sortOrder,
      isArchived: isArchived,
      createdAt: createdAt ?? clock.today(),
    );
    final res = await habitRepository.save(habit);
    if (res.isSuccess) {
      await widgetSyncService.syncNow();
    }
    return res;
  }

  Future<Result<void, AppFailure>> archiveHabit(
    String id,
    bool archived,
  ) async {
    final res = await habitRepository.setArchived(id, archived);
    if (res.isSuccess) {
      await widgetSyncService.syncNow();
    }
    return res;
  }

  Future<Result<void, AppFailure>> deleteHabit(String id) async {
    final res = await habitRepository.delete(id);
    if (res.isSuccess) {
      await widgetSyncService.syncNow();
    }
    return res;
  }

  Future<Result<void, AppFailure>> toggleBinaryHabit(
    Habit habit,
    LocalDate date,
  ) async {
    final existing = await logRepository.getLogForHabitOnDate(habit.id, date);
    final Result<Object?, AppFailure> res;
    if (existing?.isCompleted == true) {
      res = await logRepository.deleteLog(habit.id, date);
    } else {
      res = await logRepository.upsertLog(
        HabitLog(
          id: existing?.id ?? _uuid.v4(),
          habitId: habit.id,
          date: date,
          status: LogStatus.completed,
          value: 1.0,
          note: existing?.note,
          updatedAtEpochMs: clock.now().millisecondsSinceEpoch,
        ),
      );
    }
    if (res.isSuccess) {
      await widgetSyncService.syncNow();
      return const Success(null);
    }
    return Failure(res.errorOrNull!);
  }

  Future<Result<void, AppFailure>> adjustQuantitativeHabit(
    Habit habit,
    LocalDate date,
    double delta,
  ) async {
    final existing = await logRepository.getLogForHabitOnDate(habit.id, date);
    final current = existing?.isRestDay == true ? 0.0 : (existing?.value ?? 0.0);
    final next = (current + delta).clamp(0.0, habit.targetValue * 3);

    final Result<Object?, AppFailure> res;
    if (next <= 0) {
      res = await logRepository.deleteLog(habit.id, date);
    } else {
      res = await logRepository.upsertLog(
        HabitLog(
          id: existing?.id ?? _uuid.v4(),
          habitId: habit.id,
          date: date,
          status: next >= habit.targetValue
              ? LogStatus.completed
              : LogStatus.partial,
          value: next,
          note: existing?.note,
          updatedAtEpochMs: clock.now().millisecondsSinceEpoch,
        ),
      );
    }
    if (res.isSuccess) {
      await widgetSyncService.syncNow();
      return const Success(null);
    }
    return Failure(res.errorOrNull!);
  }

  Future<Result<void, AppFailure>> toggleRestDay(
    Habit habit,
    LocalDate date, {
    String? note,
  }) async {
    final existing = await logRepository.getLogForHabitOnDate(habit.id, date);
    final Result<Object?, AppFailure> res;
    if (existing?.isRestDay == true) {
      res = await logRepository.deleteLog(habit.id, date);
    } else {
      res = await logRepository.upsertLog(
        HabitLog(
          id: existing?.id ?? _uuid.v4(),
          habitId: habit.id,
          date: date,
          status: LogStatus.restDay,
          value: 0,
          note: note ?? existing?.note,
          updatedAtEpochMs: clock.now().millisecondsSinceEpoch,
        ),
      );
    }
    if (res.isSuccess) {
      await widgetSyncService.syncNow();
      return const Success(null);
    }
    return Failure(res.errorOrNull!);
  }

  Future<Result<void, AppFailure>> updateNote(
    Habit habit,
    LocalDate date,
    String note,
  ) async {
    final existing = await logRepository.getLogForHabitOnDate(habit.id, date);
    final trimmed = note.trim();
    if (existing == null && trimmed.isEmpty) {
      return const Success(null);
    }
    final res = await logRepository.upsertLog(
      HabitLog(
        id: existing?.id ?? _uuid.v4(),
        habitId: habit.id,
        date: date,
        status: existing?.status ?? LogStatus.partial,
        value: existing?.value ?? 0,
        note: trimmed.isEmpty ? null : trimmed,
        updatedAtEpochMs: clock.now().millisecondsSinceEpoch,
      ),
    );
    return res.isSuccess ? const Success(null) : Failure(res.errorOrNull!);
  }
}
