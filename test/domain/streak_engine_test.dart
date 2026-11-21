import 'package:flutter_test/flutter_test.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/heatmap_builder.dart';
import 'package:hilo/features/tracking/domain/streak_engine.dart';

void main() {
  const engine = StreakEngine();
  const heatmapBuilder = HeatmapBuilder();

  Habit buildHabit({
    String id = 'h1',
    HabitSchedule schedule = const DailySchedule(),
    bool allowShields = true,
    HabitType type = HabitType.binary,
    double targetValue = 1.0,
    required LocalDate createdAt,
  }) {
    return Habit(
      id: id,
      name: 'Entrenar',
      iconKey: 'fitness',
      colorHex: '#158052',
      type: type,
      targetValue: targetValue,
      schedule: schedule,
      allowShields: allowShields,
      sortOrder: 0,
      isArchived: false,
      createdAt: createdAt,
    );
  }

  HabitLog buildLog(
    String habitId,
    LocalDate date, {
    LogStatus status = LogStatus.completed,
    double value = 1.0,
  }) {
    return HabitLog(
      id: '$habitId-${date.toIsoString()}',
      habitId: habitId,
      date: date,
      status: status,
      value: value,
      updatedAtEpochMs: 0,
    );
  }

  group('LocalDate', () {
    test('parses, compares, and computes ISO Monday startOfWeek accurately', () {
      final sat = LocalDate.parse('2026-11-21');
      expect(sat.weekday, DateTime.saturday);
      expect(sat.startOfWeek, const LocalDate(2026, 11, 16));
      expect(sat.addDays(2), const LocalDate(2026, 11, 23));
      expect(sat.differenceInDays(const LocalDate(2026, 11, 16)), 5);
    });
  });

  group('StreakEngine', () {
    test('earns a grace shield after 7 completions and protects an unexpected miss', () {
      const start = LocalDate(2026, 11, 1);
      const today = LocalDate(2026, 11, 10);
      final habit = buildHabit(createdAt: start, allowShields: true);

      // Days 1..7 completed -> earns 1 shield. Day 8 missed -> shield protects!
      // Days 9..10 completed -> streak reaches 9 without breaking.
      final logs = <HabitLog>[
        for (var d = 1; d <= 7; d++) buildLog('h1', LocalDate(2026, 11, d)),
        buildLog('h1', const LocalDate(2026, 11, 9)),
        buildLog('h1', const LocalDate(2026, 11, 10)),
      ];

      final summary = engine.evaluateHabit(
        habit: habit,
        logs: logs,
        today: today,
      );

      expect(summary.currentStreak, 9);
      expect(summary.bestStreak, 9);
      expect(summary.availableShields, 0);
      expect(summary.autoShieldDates, contains(const LocalDate(2026, 11, 8)));
    });

    test('restDay freezes streak without consuming shields or breaking streak', () {
      const start = LocalDate(2026, 11, 1);
      const today = LocalDate(2026, 11, 4);
      final habit = buildHabit(createdAt: start, allowShields: false);

      final logs = [
        buildLog('h1', const LocalDate(2026, 11, 1)),
        buildLog('h1', const LocalDate(2026, 11, 2)),
        buildLog(
          'h1',
          const LocalDate(2026, 11, 3),
          status: LogStatus.restDay,
          value: 0,
        ),
        buildLog('h1', const LocalDate(2026, 11, 4)),
      ];

      final summary = engine.evaluateHabit(
        habit: habit,
        logs: logs,
        today: today,
      );

      expect(summary.currentStreak, 3);
      expect(summary.consistency30Days, 100);
    });

    test('specificDays schedule ignores unscheduled days', () {
      // Mon (2), Wed (4), Fri (6) in Nov 2026
      const start = LocalDate(2026, 11, 2);
      const today = LocalDate(2026, 11, 6);
      final habit = buildHabit(
        createdAt: start,
        schedule: SpecificDaysSchedule({DateTime.monday, DateTime.wednesday, DateTime.friday}),
        allowShields: false,
      );

      final logs = [
        buildLog('h1', const LocalDate(2026, 11, 2)),
        buildLog('h1', const LocalDate(2026, 11, 4)),
        buildLog('h1', const LocalDate(2026, 11, 6)),
      ];

      final summary = engine.evaluateHabit(
        habit: habit,
        logs: logs,
        today: today,
      );

      expect(summary.currentStreak, 3);
      expect(summary.consistency30Days, 100);
    });

    test('weeklyQuota schedule preserves streak across weeks when quota is met', () {
      // Week 1: Nov 2..8 (3 completions), Week 2: Nov 9..15 (2 so far on Nov 12)
      const start = LocalDate(2026, 11, 2);
      const today = LocalDate(2026, 11, 12);
      final habit = buildHabit(
        createdAt: start,
        schedule: TimesPerWeekSchedule(3),
      );

      final logs = [
        buildLog('h1', const LocalDate(2026, 11, 2)),
        buildLog('h1', const LocalDate(2026, 11, 5)),
        buildLog('h1', const LocalDate(2026, 11, 7)),
        buildLog('h1', const LocalDate(2026, 11, 10)),
        buildLog('h1', const LocalDate(2026, 11, 12)),
      ];

      final summary = engine.evaluateHabit(
        habit: habit,
        logs: logs,
        today: today,
      );

      expect(summary.currentStreak, 5);
      expect(summary.completedThisWeek, 2);
      expect(summary.weeklyTarget, 3);
      expect(summary.availableShields, 1);
    });
  });

  group('HeatmapBuilder', () {
    test('maps quantitative progress ratio to 5 intensity levels [0..4]', () {
      const today = LocalDate(2026, 11, 21);
      final habit = buildHabit(
        createdAt: const LocalDate(2026, 11, 1),
        type: HabitType.quantitative,
        targetValue: 8,
      );

      final logs = [
        buildLog('h1', const LocalDate(2026, 11, 19), status: LogStatus.partial, value: 2), // 25% -> 1
        buildLog('h1', const LocalDate(2026, 11, 20), status: LogStatus.partial, value: 4), // 50% -> 2
        buildLog('h1', const LocalDate(2026, 11, 21), status: LogStatus.completed, value: 8), // 100% -> 4
      ];

      final cells = heatmapBuilder.buildGrid(
        activeHabits: [habit],
        logs: logs,
        today: today,
        weeks: 2,
        filterHabit: habit,
      );

      expect(cells.length, 14);
      final cell19 = cells.firstWhere((c) => c.date == const LocalDate(2026, 11, 19));
      final cell20 = cells.firstWhere((c) => c.date == const LocalDate(2026, 11, 20));
      final cell21 = cells.firstWhere((c) => c.date == const LocalDate(2026, 11, 21));

      expect(cell19.level, 1);
      expect(cell20.level, 2);
      expect(cell21.level, 4);
    });
  });
}
