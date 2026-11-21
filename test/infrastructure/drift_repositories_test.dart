import 'package:flutter_test/flutter_test.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/database/hilo_database.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/infrastructure/drift_habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/infrastructure/drift_log_repository.dart';

void main() {
  test('DriftHabitRepository and DriftLogRepository persist and stream data', () async {
    final db = HiloDatabase.inMemory();
    addTearDown(db.close);

    final habitRepo = DriftHabitRepository(db);
    final logRepo = DriftLogRepository(db);

    const habit = Habit(
      id: '550e8400-e29b-41d4-a716-446655440000',
      name: 'Meditar',
      iconKey: 'meditation',
      colorHex: '#158052',
      type: HabitType.binary,
      targetValue: 1,
      schedule: DailySchedule(),
      allowShields: true,
      sortOrder: 0,
      isArchived: false,
      createdAt: LocalDate(2026, 11, 21),
    );

    final saved = await habitRepo.save(habit);
    expect(saved.isSuccess, isTrue);

    final loaded = await habitRepo.getActiveHabits();
    expect(loaded.length, 1);
    expect(loaded.first.name, 'Meditar');

    const log = HabitLog(
      id: 'log-1',
      habitId: '550e8400-e29b-41d4-a716-446655440000',
      date: LocalDate(2026, 11, 21),
      status: LogStatus.completed,
      value: 1.0,
      note: 'Sesión tranquila',
      updatedAtEpochMs: 1000,
    );
    final upserted = await logRepo.upsertLog(log);
    expect(upserted.isSuccess, isTrue);

    final fetched = await logRepo.getLogForHabitOnDate(
      habit.id,
      const LocalDate(2026, 11, 21),
    );
    expect(fetched, isNotNull);
    expect(fetched!.isCompleted, isTrue);
    expect(fetched.note, 'Sesión tranquila');
  });
}
