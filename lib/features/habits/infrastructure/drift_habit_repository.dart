import 'package:drift/drift.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/database/hilo_database.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/domain/habit_repository.dart';

final class DriftHabitRepository implements HabitRepository {
  DriftHabitRepository(this._db);

  final HiloDatabase _db;

  @override
  Stream<List<Habit>> watchActiveHabits() {
    final query = _db.select(_db.habitsTable)
      ..where((t) => t.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.createdAtDate),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Habit>> watchAllHabits() {
    final query = _db.select(_db.habitsTable)
      ..orderBy([
        (t) => OrderingTerm.asc(t.isArchived),
        (t) => OrderingTerm.asc(t.sortOrder),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    final rows = await (_db.select(_db.habitsTable)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final rows = await (_db.select(_db.habitsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Habit?> getById(String id) async {
    final row = await (_db.select(_db.habitsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Result<Habit, AppFailure>> save(Habit habit) async {
    final validation = Habit.validateDraft(
      name: habit.name,
      type: habit.type,
      targetValue: habit.targetValue,
      colorHex: habit.colorHex,
    );
    if (validation.isFailure) {
      return Failure(validation.errorOrNull!);
    }

    try {
      await _db.into(_db.habitsTable).insertOnConflictUpdate(_toCompanion(habit));
      return Success(habit);
    } catch (e) {
      return Failure(StorageFailure('No se pudo guardar el hábito.', e));
    }
  }

  @override
  Future<Result<void, AppFailure>> setArchived(String id, bool archived) async {
    try {
      await (_db.update(_db.habitsTable)..where((t) => t.id.equals(id))).write(
        HabitsTableCompanion(isArchived: Value(archived)),
      );
      return const Success(null);
    } catch (e) {
      return Failure(StorageFailure('No se pudo actualizar el estado.', e));
    }
  }

  @override
  Future<Result<void, AppFailure>> delete(String id) async {
    try {
      await (_db.delete(_db.habitsTable)..where((t) => t.id.equals(id))).go();
      return const Success(null);
    } catch (e) {
      return Failure(StorageFailure('No se pudo eliminar el hábito.', e));
    }
  }

  Habit _toDomain(HabitsTableData row) {
    return Habit(
      id: row.id,
      name: row.name,
      iconKey: row.iconKey,
      colorHex: row.colorHex,
      type: HabitType.fromName(row.habitType),
      targetValue: row.targetValue,
      unit: row.unit,
      schedule: HabitSchedule.fromStorage(
        row.scheduleType,
        row.scheduleConfigJson,
      ),
      allowShields: row.allowShields,
      reminderTime: row.reminderTime,
      sortOrder: row.sortOrder,
      isArchived: row.isArchived,
      createdAt:
          LocalDate.tryParse(row.createdAtDate) ?? LocalDate.fromDateTime(DateTime.now()),
    );
  }

  HabitsTableCompanion _toCompanion(Habit habit) {
    return HabitsTableCompanion(
      id: Value(habit.id),
      name: Value(habit.name.trim()),
      iconKey: Value(habit.iconKey),
      colorHex: Value(habit.colorHex),
      habitType: Value(habit.type.name),
      targetValue: Value(habit.targetValue),
      unit: Value(habit.unit),
      scheduleType: Value(habit.schedule.type.toStorageKey()),
      scheduleConfigJson: Value(habit.schedule.toConfigJson()),
      allowShields: Value(habit.allowShields),
      reminderTime: Value(habit.reminderTime),
      sortOrder: Value(habit.sortOrder),
      isArchived: Value(habit.isArchived),
      createdAtDate: Value(habit.createdAt.toIsoString()),
    );
  }
}
