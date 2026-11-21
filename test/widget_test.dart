import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/di/providers.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/core/security/secure_key_store.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/domain/habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/widget_sync/domain/widget_snapshot.dart';
import 'package:hilo/main.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;

  @override
  LocalDate today() => LocalDate.fromDateTime(_now);
}

final class _FakeWidgetBridge implements WidgetBridgePort {
  WidgetSnapshot? lastSnapshot;

  @override
  Future<Result<void, AppFailure>> pushSnapshot(WidgetSnapshot snapshot) async {
    lastSnapshot = snapshot;
    return const Success(null);
  }
}

final class _InMemoryKeyStore implements SecureKeyStorePort {
  bool biometric = false;
  bool screenPrivacy = false;
  bool widgetPrivacy = false;

  @override
  Future<String> getOrCreateDatabaseKey() async =>
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  @override
  Future<bool> isBiometricLockEnabled() async => biometric;

  @override
  Future<bool> isScreenPrivacyEnabled() async => screenPrivacy;

  @override
  Future<bool> isWidgetPrivacyModeEnabled() async => widgetPrivacy;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async =>
      biometric = enabled;

  @override
  Future<void> setScreenPrivacyEnabled(bool enabled) async =>
      screenPrivacy = enabled;

  @override
  Future<void> setWidgetPrivacyModeEnabled(bool enabled) async =>
      widgetPrivacy = enabled;
}

final class _InMemoryHabitRepository implements HabitRepository {
  final _habits = <String, Habit>{};
  final _controller = StreamController<List<Habit>>.broadcast();

  void _emit() => _controller.add(_habits.values.toList());

  @override
  Stream<List<Habit>> watchActiveHabits() async* {
    yield _habits.values.where((h) => !h.isArchived).toList();
    yield* _controller.stream
        .map((list) => list.where((h) => !h.isArchived).toList());
  }

  @override
  Stream<List<Habit>> watchAllHabits() async* {
    yield _habits.values.toList();
    yield* _controller.stream;
  }

  @override
  Future<List<Habit>> getActiveHabits() async =>
      _habits.values.where((h) => !h.isArchived).toList();

  @override
  Future<List<Habit>> getAllHabits() async => _habits.values.toList();

  @override
  Future<Habit?> getById(String id) async => _habits[id];

  @override
  Future<Result<Habit, AppFailure>> save(Habit habit) async {
    _habits[habit.id] = habit;
    _emit();
    return Success(habit);
  }

  @override
  Future<Result<void, AppFailure>> setArchived(String id, bool archived) async {
    final existing = _habits[id];
    if (existing != null) {
      _habits[id] = existing.copyWith(isArchived: archived);
      _emit();
    }
    return const Success(null);
  }

  @override
  Future<Result<void, AppFailure>> delete(String id) async {
    _habits.remove(id);
    _emit();
    return const Success(null);
  }

  Future<void> dispose() => _controller.close();
}

final class _InMemoryLogRepository implements LogRepository {
  final _logs = <String, HabitLog>{};
  final _controller = StreamController<List<HabitLog>>.broadcast();

  String _key(String habitId, LocalDate date) =>
      '$habitId::${date.toIsoString()}';

  void _emit() => _controller.add(_logs.values.toList());

  @override
  Stream<List<HabitLog>> watchLogsInRange(LocalDate from, LocalDate to) async* {
    yield _filter(from, to);
    yield* _controller.stream.map((_) => _filter(from, to));
  }

  List<HabitLog> _filter(LocalDate from, LocalDate to) =>
      _logs.values.where((l) => l.date >= from && l.date <= to).toList();

  @override
  Future<List<HabitLog>> getLogsInRange(LocalDate from, LocalDate to) async =>
      _filter(from, to);

  @override
  Future<List<HabitLog>> getAllLogs() async => _logs.values.toList();

  @override
  Future<HabitLog?> getLogForHabitOnDate(String habitId, LocalDate date) async =>
      _logs[_key(habitId, date)];

  @override
  Future<Result<HabitLog, AppFailure>> upsertLog(HabitLog log) async {
    _logs[_key(log.habitId, log.date)] = log;
    _emit();
    return Success(log);
  }

  @override
  Future<Result<void, AppFailure>> deleteLog(
    String habitId,
    LocalDate date,
  ) async {
    _logs.remove(_key(habitId, date));
    _emit();
    return const Success(null);
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets(
    'creates a habit, checks it in, syncs widget snapshot, and opens Heatmap tab',
    (tester) async {
      final habitRepo = _InMemoryHabitRepository();
      final logRepo = _InMemoryLogRepository();
      final bridge = _FakeWidgetBridge();
      final keyStore = _InMemoryKeyStore();
      final clock = _FixedClock(DateTime(2026, 11, 21, 9, 0));

      addTearDown(() async {
        await habitRepo.dispose();
        await logRepo.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitRepositoryProvider.overrideWithValue(habitRepo),
            logRepositoryProvider.overrideWithValue(logRepo),
            widgetBridgeProvider.overrideWithValue(bridge),
            secureKeyStoreProvider.overrideWithValue(keyStore),
            clockProvider.overrideWithValue(clock),
          ],
          child: const HiloApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Empieza tu primer hilo'), findsOneWidget);

      // Open new habit modal via FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Leer 20 min');
      await tester.tap(find.text('Crear hábito'));
      await tester.pumpAndSettle();

      // Habit appears on Today screen with 0/1 progress
      expect(find.text('Leer 20 min'), findsOneWidget);
      expect(find.text('0/1'), findsOneWidget);

      // Check in the habit
      await tester.tap(find.text('Leer 20 min'));
      await tester.pumpAndSettle();

      expect(find.text('1/1'), findsOneWidget);
      expect(bridge.lastSnapshot, isNotNull);
      expect(bridge.lastSnapshot!.completedToday, 1);
      expect(bridge.lastSnapshot!.globalStreak, 1);
      expect(bridge.lastSnapshot!.heatmapLevels.length, 112);

      // Navigate to Heatmap tab
      await tester.tap(find.text('Mapa'));
      await tester.pumpAndSettle();

      expect(find.text('Mapa de Calor'), findsOneWidget);
      expect(find.text('Tu Hilo Global'), findsOneWidget);
    },
  );
}
