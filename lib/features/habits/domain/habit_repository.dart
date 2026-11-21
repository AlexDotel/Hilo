import 'package:hilo/core/error/result.dart';
import 'package:hilo/features/habits/domain/habit.dart';

/// Repository port for managing Habit aggregates.
abstract interface class HabitRepository {
  Stream<List<Habit>> watchActiveHabits();

  Stream<List<Habit>> watchAllHabits();

  Future<List<Habit>> getActiveHabits();

  Future<List<Habit>> getAllHabits();

  Future<Habit?> getById(String id);

  Future<Result<Habit, AppFailure>> save(Habit habit);

  Future<Result<void, AppFailure>> setArchived(String id, bool archived);

  Future<Result<void, AppFailure>> delete(String id);
}
