import 'package:flutter/foundation.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/schedule_strategy.dart';

@immutable
final class HeatmapCell {
  const HeatmapCell({
    required this.date,
    required this.level,
    required this.completedCount,
    required this.scheduledCount,
    required this.hasRestDay,
    required this.hasShield,
    required this.isFuture,
  });

  final LocalDate date;

  /// Intensity level in [0..4] (GitHub-style 5-step scale).
  final int level;
  final int completedCount;
  final int scheduledCount;
  final bool hasRestDay;
  final bool hasShield;
  final bool isFuture;
}

/// Pure domain service constructing GitHub-style 7-row contribution grids.
final class HeatmapBuilder {
  const HeatmapBuilder();

  /// Builds a matrix of [weeks] columns × 7 rows (Monday..Sunday) ending on
  /// the week containing [today].
  List<HeatmapCell> buildGrid({
    required List<Habit> activeHabits,
    required List<HabitLog> logs,
    required LocalDate today,
    required int weeks,
    Habit? filterHabit,
    Set<LocalDate> shieldDates = const {},
  }) {
    final endWeekStart = today.startOfWeek;
    final gridStart = endWeekStart.subtractDays((weeks - 1) * 7);
    final totalCells = weeks * 7;

    final logsByDate = <LocalDate, List<HabitLog>>{};
    for (final log in logs) {
      if (filterHabit != null && log.habitId != filterHabit.id) continue;
      logsByDate.putIfAbsent(log.date, () => []).add(log);
    }

    final cells = <HeatmapCell>[];
    for (var i = 0; i < totalCells; i++) {
      final date = gridStart.addDays(i);
      final isFuture = date > today;
      if (isFuture) {
        cells.add(
          HeatmapCell(
            date: date,
            level: 0,
            completedCount: 0,
            scheduledCount: 0,
            hasRestDay: false,
            hasShield: false,
            isFuture: true,
          ),
        );
        continue;
      }

      final dayLogs = logsByDate[date] ?? const [];

      if (filterHabit != null) {
        final log = dayLogs.firstOrNull;
        final strategy = ScheduleStrategy.forSchedule(filterHabit.schedule);
        final scheduled = strategy.isScheduledOn(date) ? 1 : 0;
        final hasRest = log?.isRestDay == true;
        final hasShield =
            log?.isShieldUsed == true || shieldDates.contains(date);

        int level = 0;
        if (log != null && !hasRest) {
          if (filterHabit.type == HabitType.binary) {
            level = log.isCompleted ? 4 : 0;
          } else {
            final ratio =
                (log.value / filterHabit.targetValue).clamp(0.0, 1.0);
            level = ratioToLevel(ratio);
          }
        }

        cells.add(
          HeatmapCell(
            date: date,
            level: level,
            completedCount: log?.isCompleted == true ? 1 : 0,
            scheduledCount: scheduled,
            hasRestDay: hasRest,
            hasShield: hasShield,
            isFuture: false,
          ),
        );
      } else {
        var scheduled = 0;
        var completed = 0;
        var hasRest = false;

        for (final habit in activeHabits) {
          final strategy = ScheduleStrategy.forSchedule(habit.schedule);
          final log = dayLogs.where((l) => l.habitId == habit.id).firstOrNull;
          if (log?.isRestDay == true) {
            hasRest = true;
            continue;
          }
          if (strategy.isScheduledOn(date)) {
            scheduled++;
          }
          if (log?.isCompleted == true) {
            completed++;
          }
        }

        final ratio = scheduled == 0
            ? (completed > 0 ? 1.0 : 0.0)
            : (completed / scheduled).clamp(0.0, 1.0);

        cells.add(
          HeatmapCell(
            date: date,
            level: ratioToLevel(ratio),
            completedCount: completed,
            scheduledCount: scheduled,
            hasRestDay: hasRest && completed == 0,
            hasShield: shieldDates.contains(date),
            isFuture: false,
          ),
        );
      }
    }

    return cells;
  }

  static int ratioToLevel(double ratio) {
    if (ratio <= 0) return 0;
    if (ratio <= 0.25) return 1;
    if (ratio <= 0.50) return 2;
    if (ratio <= 0.75) return 3;
    return 4;
  }
}
