import 'package:drift/drift.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/database/hilo_database.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';

final class DriftLogRepository implements LogRepository {
  DriftLogRepository(this._db);

  final HiloDatabase _db;

  @override
  Stream<List<HabitLog>> watchLogsInRange(LocalDate from, LocalDate to) {
    final fromIso = from.toIsoString();
    final toIso = to.toIsoString();
    final query = _db.select(_db.habitLogsTable)
      ..where(
        (t) =>
            t.localDate.isBiggerOrEqualValue(fromIso) &
            t.localDate.isSmallerOrEqualValue(toIso),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.localDate)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<HabitLog>> getLogsInRange(LocalDate from, LocalDate to) async {
    final fromIso = from.toIsoString();
    final toIso = to.toIsoString();
    final rows = await (_db.select(_db.habitLogsTable)
          ..where(
            (t) =>
                t.localDate.isBiggerOrEqualValue(fromIso) &
                t.localDate.isSmallerOrEqualValue(toIso),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.localDate)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<HabitLog>> getAllLogs() async {
    final rows = await (_db.select(_db.habitLogsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.localDate)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<HabitLog?> getLogForHabitOnDate(String habitId, LocalDate date) async {
    final row = await (_db.select(_db.habitLogsTable)
          ..where(
            (t) =>
                t.habitId.equals(habitId) &
                t.localDate.equals(date.toIsoString()),
          ))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Result<HabitLog, AppFailure>> upsertLog(HabitLog log) async {
    try {
      await _db.transaction(() async {
        final existing = await getLogForHabitOnDate(log.habitId, log.date);
        final companion = HabitLogsTableCompanion(
          id: Value(existing?.id ?? log.id),
          habitId: Value(log.habitId),
          localDate: Value(log.date.toIsoString()),
          status: Value(log.status.toStorageKey()),
          value: Value(log.value),
          note: Value(log.note),
          updatedAtEpochMs: Value(log.updatedAtEpochMs),
        );
        await _db
            .into(_db.habitLogsTable)
            .insertOnConflictUpdate(companion);
      });
      return Success(log);
    } catch (e) {
      return Failure(StorageFailure('No se pudo guardar el registro.', e));
    }
  }

  @override
  Future<Result<void, AppFailure>> deleteLog(
    String habitId,
    LocalDate date,
  ) async {
    try {
      await (_db.delete(_db.habitLogsTable)
            ..where(
              (t) =>
                  t.habitId.equals(habitId) &
                  t.localDate.equals(date.toIsoString()),
            ))
          .go();
      return const Success(null);
    } catch (e) {
      return Failure(StorageFailure('No se pudo eliminar el registro.', e));
    }
  }

  HabitLog _toDomain(HabitLogsTableData row) {
    return HabitLog(
      id: row.id,
      habitId: row.habitId,
      date: LocalDate.parse(row.localDate),
      status: LogStatus.fromName(row.status),
      value: row.value,
      note: row.note,
      updatedAtEpochMs: row.updatedAtEpochMs,
    );
  }
}
