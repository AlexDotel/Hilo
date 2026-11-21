import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/core/security/secure_key_store.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/domain/habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/heatmap_builder.dart';
import 'package:hilo/features/tracking/domain/schedule_strategy.dart';
import 'package:hilo/features/tracking/domain/streak_engine.dart';
import 'package:hilo/features/widget_sync/domain/widget_snapshot.dart';

/// Application service projecting the minimal, privacy-safe state to Android widgets.
final class WidgetSyncService {
  const WidgetSyncService({
    required this.habitRepository,
    required this.logRepository,
    required this.widgetBridge,
    required this.keyStore,
    required this.clock,
    required this.streakEngine,
    required this.heatmapBuilder,
  });

  final HabitRepository habitRepository;
  final LogRepository logRepository;
  final WidgetBridgePort widgetBridge;
  final SecureKeyStorePort keyStore;
  final Clock clock;
  final StreakEngine streakEngine;
  final HeatmapBuilder heatmapBuilder;

  Future<Result<void, AppFailure>> syncNow() async {
    final today = clock.today();
    final habits = await habitRepository.getActiveHabits();
    final from = today.subtractDays(120);
    final logs = await logRepository.getLogsInRange(from, today);
    final privacyMode = await keyStore.isWidgetPrivacyModeEnabled();

    final globalStreak = streakEngine.evaluateGlobal(
      activeHabits: habits,
      logs: logs,
      today: today,
    );

    final grid16Weeks = heatmapBuilder.buildGrid(
      activeHabits: habits,
      logs: logs,
      today: today,
      weeks: 16,
      shieldDates: globalStreak.autoShieldDates,
    );

    final todayLogsByHabit = <String, HabitLog>{
      for (final log in logs)
        if (log.date == today) log.habitId: log,
    };

    var completedToday = 0;
    var totalToday = 0;
    final widgetItems = <WidgetHabitItem>[];

    for (var i = 0; i < habits.length; i++) {
      final habit = habits[i];
      final strategy = ScheduleStrategy.forSchedule(habit.schedule);
      final log = todayLogsByHabit[habit.id];
      final isDone = log?.isCompleted == true;

      if (strategy.isScheduledOn(today)) {
        totalToday++;
        if (isDone) completedToday++;
      }

      if (widgetItems.length < 3) {
        final habitStreak = streakEngine.evaluateHabit(
          habit: habit,
          logs: logs,
          today: today,
        );
        final habitLogsByDate = <LocalDate, HabitLog>{
          for (final l in logs)
            if (l.habitId == habit.id) l.date: l,
        };
        final compact45 = <int>[];
        for (var offset = 44; offset >= 0; offset--) {
          final d = today.subtractDays(offset);
          final dLog = habitLogsByDate[d];
          if (dLog == null || dLog.isRestDay) {
            compact45.add(0);
          } else if (habit.type == HabitType.binary) {
            compact45.add(dLog.isCompleted ? 4 : 0);
          } else {
            final ratio = (dLog.value / habit.targetValue).clamp(0.0, 1.0);
            compact45.add(HeatmapBuilder.ratioToLevel(ratio));
          }
        }

        final progressLabel = habit.type == HabitType.quantitative
            ? '${(log?.value ?? 0).toStringAsFixed(0)}/${habit.targetValue.toStringAsFixed(0)}'
            : (isDone ? 'Hecho' : 'Pendiente');

        final weeklySummary =
            '${habitStreak.completedThisWeek}/${habitStreak.weeklyTarget} esta semana';

        widgetItems.add(
          WidgetHabitItem(
            id: habit.id,
            title: privacyMode ? 'Hábito ${i + 1}' : habit.name,
            isCompletedToday: isDone,
            isQuantitative: habit.type == HabitType.quantitative,
            progressLabel: progressLabel,
            weeklySummary: weeklySummary,
            currentStreak: habitStreak.currentStreak,
            colorHex: habit.colorHex,
            compactHeatmapLevels: compact45,
          ),
        );
      }
    }

    final snapshot = WidgetSnapshot(
      dateIso: today.toIsoString(),
      globalStreak: globalStreak.currentStreak,
      availableShields: globalStreak.availableShields,
      consistency30Days: globalStreak.consistency30Days,
      completedToday: completedToday,
      totalToday: totalToday,
      heatmapLevels: grid16Weeks.map((c) => c.level).toList(),
      todayHabits: widgetItems,
      privacyMode: privacyMode,
    );

    return widgetBridge.pushSnapshot(snapshot);
  }
}
