import 'package:flutter/foundation.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/schedule_strategy.dart';

@immutable
final class StreakSummary {
  const StreakSummary({
    required this.currentStreak,
    required this.bestStreak,
    required this.consistency30Days,
    required this.availableShields,
    required this.autoShieldDates,
    required this.completedThisWeek,
    required this.weeklyTarget,
  });

  static const empty = StreakSummary(
    currentStreak: 0,
    bestStreak: 0,
    consistency30Days: 0,
    availableShields: 0,
    autoShieldDates: {},
    completedThisWeek: 0,
    weeklyTarget: 7,
  );

  /// Current active streak (in completed days for daily/specific-days,
  /// or completed days within unbroken qualifying weeks for weekly-quota).
  final int currentStreak;
  final int bestStreak;

  /// Percentage [0..100] over the last 30 calendar days.
  final int consistency30Days;

  /// Grace shields currently available (max 2, earned 1 per 7 completed days).
  final int availableShields;

  /// Dates automatically protected by a grace shield.
  final Set<LocalDate> autoShieldDates;

  final int completedThisWeek;
  final int weeklyTarget;
}

/// Pure, deterministic domain engine for anti-burnout flexible streaks.
///
/// Rules:
/// - Non-scheduled days never break a streak.
/// - Explicit `restDay` logs freeze the streak without penalty.
/// - When `habit.allowShields` is enabled, 1 grace shield is earned every 7
///   completed days (capped at 2 active shields) and automatically protects
///   an unexpected missed scheduled day.
/// - Weekly-quota habits (`TimesPerWeekSchedule`) evaluate week-by-week so
///   hitting e.g. 3/3 any days of the week preserves the streak continuously.
final class StreakEngine {
  const StreakEngine();

  static const int maxActiveShields = 2;
  static const int completionsPerShield = 7;

  StreakSummary evaluateHabit({
    required Habit habit,
    required List<HabitLog> logs,
    required LocalDate today,
  }) {
    final logByDate = <LocalDate, HabitLog>{
      for (final log in logs)
        if (log.habitId == habit.id) log.date: log,
    };

    final strategy = ScheduleStrategy.forSchedule(habit.schedule);
    final weekStart = today.startOfWeek;
    var completedThisWeek = 0;
    for (var i = 0; i < 7; i++) {
      final d = weekStart.addDays(i);
      if (d > today) break;
      if (logByDate[d]?.isCompleted == true) {
        completedThisWeek++;
      }
    }

    if (habit.schedule case TimesPerWeekSchedule(:final timesPerWeek)) {
      return _evaluateWeeklyQuota(
        habit: habit,
        logByDate: logByDate,
        today: today,
        timesPerWeek: timesPerWeek,
        completedThisWeek: completedThisWeek,
      );
    }

    return _evaluateScheduledDays(
      habit: habit,
      strategy: strategy,
      logByDate: logByDate,
      today: today,
      completedThisWeek: completedThisWeek,
    );
  }

  /// Evaluates global streak across all active habits: a day counts as active
  /// if at least one scheduled habit was completed (or all were rest days).
  StreakSummary evaluateGlobal({
    required List<Habit> activeHabits,
    required List<HabitLog> logs,
    required LocalDate today,
  }) {
    if (activeHabits.isEmpty) return StreakSummary.empty;

    final logsByDate = <LocalDate, List<HabitLog>>{};
    for (final log in logs) {
      logsByDate.putIfAbsent(log.date, () => []).add(log);
    }

    final earliestHabitDate = activeHabits
        .map((h) => h.createdAt)
        .reduce((a, b) => a < b ? a : b);
    final earliestLogDate = logs.isEmpty
        ? today
        : logs.map((l) => l.date).reduce((a, b) => a < b ? a : b);
    final startDate =
        earliestHabitDate < earliestLogDate ? earliestHabitDate : earliestLogDate;

    var runningStreak = 0;
    var bestStreak = 0;
    var shields = 0;
    var sinceLastShield = 0;
    final shieldDates = <LocalDate>{};

    var cursor = startDate;
    while (cursor <= today) {
      final dayLogs = logsByDate[cursor] ?? const [];
      final completedCount = dayLogs.where((l) => l.isCompleted).length;
      final restCount = dayLogs.where((l) => l.isRestDay).length;

      if (completedCount > 0) {
        runningStreak++;
        if (runningStreak > bestStreak) bestStreak = runningStreak;
        sinceLastShield++;
        if (sinceLastShield >= completionsPerShield) {
          if (shields < maxActiveShields) shields++;
          sinceLastShield = 0;
        }
      } else if (restCount > 0) {
        // Rest day freezes streak without breaking it.
      } else if (cursor < today) {
        if (runningStreak > 0 && shields > 0) {
          shields--;
          shieldDates.add(cursor);
        } else {
          runningStreak = 0;
          sinceLastShield = 0;
        }
      }
      cursor = cursor.addDays(1);
    }

    // 30-day global consistency (accurately weighting weekly-quota habits)
    var scheduledSlots = 0;
    var fulfilledSlots = 0;
    final windowStart = today.subtractDays(29);
    for (final habit in activeHabits) {
      if (habit.schedule case TimesPerWeekSchedule(:final timesPerWeek)) {
        final effectiveStart =
            habit.createdAt > windowStart ? habit.createdAt : windowStart;
        if (effectiveStart > today) continue;
        final activeDays = today.differenceInDays(effectiveStart) + 1;
        final expected = ((activeDays / 7.0) * timesPerWeek).ceil().clamp(1, 30);
        var completed = 0;
        for (var i = 0; i < 30; i++) {
          final date = windowStart.addDays(i);
          if (date < effectiveStart || date > today) continue;
          final dayLogs = logsByDate[date] ?? const [];
          final log = dayLogs.where((l) => l.habitId == habit.id).firstOrNull;
          if (log?.isCompleted == true) completed++;
        }
        scheduledSlots += expected;
        fulfilledSlots += completed.clamp(0, expected);
      } else {
        final strategy = ScheduleStrategy.forSchedule(habit.schedule);
        for (var i = 0; i < 30; i++) {
          final date = windowStart.addDays(i);
          if (date < habit.createdAt) continue;
          if (!strategy.isScheduledOn(date)) continue;
          final dayLogs = logsByDate[date] ?? const [];
          final log = dayLogs.where((l) => l.habitId == habit.id).firstOrNull;
          if (log?.isRestDay == true) continue;
          scheduledSlots++;
          if (log?.isCompleted == true) {
            fulfilledSlots++;
          }
        }
      }
    }

    final consistency = scheduledSlots == 0
        ? 0
        : ((fulfilledSlots / scheduledSlots) * 100).round().clamp(0, 100);

    return StreakSummary(
      currentStreak: runningStreak,
      bestStreak: bestStreak,
      consistency30Days: consistency,
      availableShields: shields,
      autoShieldDates: Set.unmodifiable(shieldDates),
      completedThisWeek: 0,
      weeklyTarget: 7,
    );
  }

  StreakSummary _evaluateScheduledDays({
    required Habit habit,
    required ScheduleStrategy strategy,
    required Map<LocalDate, HabitLog> logByDate,
    required LocalDate today,
    required int completedThisWeek,
  }) {
    final earliestLog = logByDate.keys.isEmpty
        ? today
        : logByDate.keys.reduce((a, b) => a < b ? a : b);
    final startDate =
        habit.createdAt < earliestLog ? habit.createdAt : earliestLog;

    var runningStreak = 0;
    var bestStreak = 0;
    var shields = 0;
    var sinceLastShield = 0;
    final shieldDates = <LocalDate>{};

    var cursor = startDate;
    while (cursor <= today) {
      final log = logByDate[cursor];
      final isScheduled = strategy.isScheduledOn(cursor);

      if (log?.isCompleted == true) {
        runningStreak++;
        if (runningStreak > bestStreak) bestStreak = runningStreak;
        if (habit.allowShields) {
          sinceLastShield++;
          if (sinceLastShield >= completionsPerShield) {
            if (shields < maxActiveShields) shields++;
            sinceLastShield = 0;
          }
        }
      } else if (log?.isRestDay == true || log?.isShieldUsed == true) {
        // Frozen without penalty.
      } else if (isScheduled && cursor < today) {
        if (habit.allowShields && runningStreak > 0 && shields > 0) {
          shields--;
          shieldDates.add(cursor);
        } else {
          runningStreak = 0;
          sinceLastShield = 0;
        }
      }
      cursor = cursor.addDays(1);
    }

    // 30-day consistency
    var expected = 0;
    var completed = 0;
    final windowStart = today.subtractDays(29);
    for (var i = 0; i < 30; i++) {
      final d = windowStart.addDays(i);
      if (d < habit.createdAt) continue;
      if (!strategy.isScheduledOn(d)) continue;
      final log = logByDate[d];
      if (log?.isRestDay == true) continue;
      expected++;
      if (log?.isCompleted == true) completed++;
    }
    final consistency =
        expected == 0 ? 0 : ((completed / expected) * 100).round().clamp(0, 100);

    return StreakSummary(
      currentStreak: runningStreak,
      bestStreak: bestStreak,
      consistency30Days: consistency,
      availableShields: shields,
      autoShieldDates: Set.unmodifiable(shieldDates),
      completedThisWeek: completedThisWeek,
      weeklyTarget: strategy.weeklyTarget(),
    );
  }

  StreakSummary _evaluateWeeklyQuota({
    required Habit habit,
    required Map<LocalDate, HabitLog> logByDate,
    required LocalDate today,
    required int timesPerWeek,
    required int completedThisWeek,
  }) {
    final earliestLog = logByDate.keys.isEmpty
        ? today
        : logByDate.keys.reduce((a, b) => a < b ? a : b);
    final startDate =
        habit.createdAt < earliestLog ? habit.createdAt : earliestLog;

    var weekCursor = startDate.startOfWeek;
    final currentWeekStart = today.startOfWeek;

    var runningStreak = 0;
    var bestStreak = 0;
    var shields = 0;
    final shieldDates = <LocalDate>{};

    while (weekCursor <= currentWeekStart) {
      var weekCompleted = 0;
      var weekRest = 0;
      for (var i = 0; i < 7; i++) {
        final d = weekCursor.addDays(i);
        if (d > today) break;
        final log = logByDate[d];
        if (log?.isCompleted == true) weekCompleted++;
        if (log?.isRestDay == true) weekRest++;
      }

      final isCurrentWeek = weekCursor == currentWeekStart;
      final effectiveTarget = (timesPerWeek - weekRest).clamp(0, 7);

      if (isCurrentWeek) {
        runningStreak += weekCompleted;
        if (runningStreak > bestStreak) bestStreak = runningStreak;
      } else if (weekCompleted >= effectiveTarget) {
        runningStreak += weekCompleted;
        if (runningStreak > bestStreak) bestStreak = runningStreak;
        if (habit.allowShields && shields < maxActiveShields) {
          shields++;
        }
      } else {
        if (habit.allowShields && runningStreak > 0 && shields > 0) {
          shields--;
          shieldDates.add(weekCursor.addDays(6));
          runningStreak += weekCompleted;
          if (runningStreak > bestStreak) bestStreak = runningStreak;
        } else {
          runningStreak = 0;
        }
      }

      weekCursor = weekCursor.addDays(7);
    }

    // 30-day consistency relative to ~4.28 weeks * timesPerWeek
    var completed30 = 0;
    final windowStart = today.subtractDays(29);
    for (var i = 0; i < 30; i++) {
      final d = windowStart.addDays(i);
      if (logByDate[d]?.isCompleted == true) completed30++;
    }
    final activeDays = (today.differenceInDays(habit.createdAt) + 1).clamp(1, 30);
    final expected30 = ((activeDays / 7.0) * timesPerWeek).ceil().clamp(1, 30);
    final consistency =
        ((completed30 / expected30) * 100).round().clamp(0, 100);

    return StreakSummary(
      currentStreak: runningStreak,
      bestStreak: bestStreak,
      consistency30Days: consistency,
      availableShields: shields,
      autoShieldDates: Set.unmodifiable(shieldDates),
      completedThisWeek: completedThisWeek,
      weeklyTarget: timesPerWeek,
    );
  }
}
