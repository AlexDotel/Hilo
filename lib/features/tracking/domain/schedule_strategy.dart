import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/features/habits/domain/habit.dart';

/// Strategy Pattern: encapsulates schedule-specific rules for flexible streaks.
abstract interface class ScheduleStrategy {
  /// Whether the habit is explicitly expected on [date].
  bool isScheduledOn(LocalDate date);

  /// Expected number of completions in a 7-day ISO week.
  int weeklyTarget();

  static ScheduleStrategy forSchedule(HabitSchedule schedule) {
    return switch (schedule) {
      DailySchedule() => const DailyScheduleStrategy(),
      SpecificDaysSchedule(:final weekdays) =>
        SpecificDaysScheduleStrategy(weekdays),
      TimesPerWeekSchedule(:final timesPerWeek) =>
        WeeklyQuotaScheduleStrategy(timesPerWeek),
    };
  }
}

final class DailyScheduleStrategy implements ScheduleStrategy {
  const DailyScheduleStrategy();

  @override
  bool isScheduledOn(LocalDate date) => true;

  @override
  int weeklyTarget() => 7;
}

final class SpecificDaysScheduleStrategy implements ScheduleStrategy {
  const SpecificDaysScheduleStrategy(this.weekdays);

  final Set<int> weekdays;

  @override
  bool isScheduledOn(LocalDate date) => weekdays.contains(date.weekday);

  @override
  int weeklyTarget() => weekdays.length;
}

final class WeeklyQuotaScheduleStrategy implements ScheduleStrategy {
  const WeeklyQuotaScheduleStrategy(this.timesPerWeek);

  final int timesPerWeek;

  /// Weekly-quota habits can be performed on any day of the week.
  @override
  bool isScheduledOn(LocalDate date) => true;

  @override
  int weeklyTarget() => timesPerWeek;
}
