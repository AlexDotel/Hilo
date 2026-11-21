import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'hilo_database.g.dart';

class HabitsTable extends Table {
  @override
  String get tableName => 'habits';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get iconKey => text().withDefault(const Constant('check'))();
  TextColumn get colorHex => text().withDefault(const Constant('#158052'))();
  TextColumn get habitType => text().withDefault(const Constant('binary'))();
  RealColumn get targetValue => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().nullable()();
  TextColumn get scheduleType => text().withDefault(const Constant('daily'))();
  TextColumn get scheduleConfigJson =>
      text().withDefault(const Constant('{}'))();
  BoolColumn get allowShields => boolean().withDefault(const Constant(true))();
  TextColumn get reminderTime => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get createdAtDate => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class HabitLogsTable extends Table {
  @override
  String get tableName => 'habit_logs';

  TextColumn get id => text()();
  TextColumn get habitId => text().references(
        HabitsTable,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get localDate => text()();
  TextColumn get status => text()();
  RealColumn get value => real().withDefault(const Constant(1.0))();
  TextColumn get note => text().nullable()();
  IntColumn get updatedAtEpochMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {habitId, localDate},
      ];
}

@DriftDatabase(tables: [HabitsTable, HabitLogsTable])
class HiloDatabase extends _$HiloDatabase {
  HiloDatabase(super.executor);

  /// Opens the production SQLCipher-encrypted SQLite database.
  factory HiloDatabase.encrypted({required String hexKey}) {
    return HiloDatabase(_openEncryptedConnection(hexKey));
  }

  /// Opens an isolated in-memory SQLite database for deterministic tests.
  factory HiloDatabase.inMemory() {
    return HiloDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_habit_logs_date '
            'ON habit_logs(local_date);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_habit_logs_habit_date '
            'ON habit_logs(habit_id, local_date);',
          );
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );
}

QueryExecutor _openEncryptedConnection(String hexKey) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hilo_encrypted.sqlite'));

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        // Apply 256-bit raw hex key via SQLCipher (validated 64 hex chars).
        if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hexKey)) {
          rawDb.execute("PRAGMA key = \"x'$hexKey'\";");
          rawDb.execute('PRAGMA cipher_memory_security = ON;');
        }
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}
