import 'package:flutter/widgets.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/database/hilo_database.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/core/security/secure_key_store.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/infrastructure/drift_habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/heatmap_builder.dart';
import 'package:hilo/features/tracking/domain/streak_engine.dart';
import 'package:hilo/features/tracking/infrastructure/drift_log_repository.dart';
import 'package:hilo/features/widget_sync/application/widget_sync_service.dart';
import 'package:hilo/features/widget_sync/domain/widget_snapshot.dart';
import 'package:home_widget/home_widget.dart';
import 'package:uuid/uuid.dart';

/// Adapter implementing [WidgetBridgePort] over the `home_widget` plugin.
final class AndroidHomeWidgetAdapter implements WidgetBridgePort {
  const AndroidHomeWidgetAdapter();

  static const String snapshotStorageKey = 'hilo_widget_snapshot_json';
  static const String standardProviderName = 'HiloWidgetProvider';
  static const String expandedProviderName = 'HiloExpandedWidgetProvider';
  static const String compactProviderName = 'HiloSingleHabitWidgetProvider';

  @override
  Future<Result<void, AppFailure>> pushSnapshot(WidgetSnapshot snapshot) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        snapshotStorageKey,
        snapshot.toJsonString(),
      );
      await HomeWidget.updateWidget(
        androidName: standardProviderName,
        qualifiedAndroidName: 'nuviapps.co.hilo.$standardProviderName',
      );
      await HomeWidget.updateWidget(
        androidName: expandedProviderName,
        qualifiedAndroidName: 'nuviapps.co.hilo.$expandedProviderName',
      );
      await HomeWidget.updateWidget(
        androidName: compactProviderName,
        qualifiedAndroidName: 'nuviapps.co.hilo.$compactProviderName',
      );
      return const Success(null);
    } catch (e) {
      return Failure(
        WidgetSyncFailure('No se pudo sincronizar el widget de Android.', e),
      );
    }
  }
}

/// Top-level background entry point executed when the user taps a habit
/// check-in button directly on the Android Home Screen widget.
@pragma('vm:entry-point')
Future<void> hiloWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();

  final parsed = WidgetActionValidator.parseUri(uri);
  if (parsed.isFailure) {
    debugPrint('Hilo widget action rejected: ${parsed.errorOrNull}');
    return;
  }

  final action = parsed.valueOrNull!;
  final keyStore = FlutterSecureKeyStore();
  final dbKey = await keyStore.getOrCreateDatabaseKey();
  final db = HiloDatabase.encrypted(hexKey: dbKey);

  try {
    final habitRepo = DriftHabitRepository(db);
    final logRepo = DriftLogRepository(db);
    const clock = SystemClock();
    final today = clock.today();

    final habit = await habitRepo.getById(action.habitId);
    if (habit == null || habit.isArchived) return;

    final existing = await logRepo.getLogForHabitOnDate(habit.id, today);
    final nowMs = clock.now().millisecondsSinceEpoch;

    if (habit.type == HabitType.binary) {
      if (existing?.isCompleted == true) {
        await logRepo.deleteLog(habit.id, today);
      } else {
        await logRepo.upsertLog(
          HabitLog(
            id: existing?.id ?? const Uuid().v4(),
            habitId: habit.id,
            date: today,
            status: LogStatus.completed,
            value: 1.0,
            note: existing?.note,
            updatedAtEpochMs: nowMs,
          ),
        );
      }
    } else {
      final currentValue = existing?.value ?? 0.0;
      final nextValue = currentValue >= habit.targetValue
          ? 0.0
          : (currentValue + 1.0).clamp(0.0, habit.targetValue);
      if (nextValue <= 0) {
        await logRepo.deleteLog(habit.id, today);
      } else {
        await logRepo.upsertLog(
          HabitLog(
            id: existing?.id ?? const Uuid().v4(),
            habitId: habit.id,
            date: today,
            status: nextValue >= habit.targetValue
                ? LogStatus.completed
                : LogStatus.partial,
            value: nextValue,
            note: existing?.note,
            updatedAtEpochMs: nowMs,
          ),
        );
      }
    }

    final syncService = WidgetSyncService(
      habitRepository: habitRepo,
      logRepository: logRepo,
      widgetBridge: const AndroidHomeWidgetAdapter(),
      keyStore: keyStore,
      clock: clock,
      streakEngine: const StreakEngine(),
      heatmapBuilder: const HeatmapBuilder(),
    );
    await syncService.syncNow();
  } finally {
    await db.close();
  }
}
