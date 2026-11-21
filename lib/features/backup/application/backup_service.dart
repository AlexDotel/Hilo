import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/core/security/backup_crypto_service.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/domain/habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';

/// Application service exporting and importing encrypted `.hilo` local backups
/// with strict schema validation, DoS bounds, and referential integrity checks.
final class BackupService {
  const BackupService({
    required this.habitRepository,
    required this.logRepository,
    required this.cryptoService,
    required this.clock,
  });

  static const int maxHabits = 500;
  static const int maxLogs = 50000;
  static const int maxNoteLength = 500;
  static const int maxIdLength = 64;

  final HabitRepository habitRepository;
  final LogRepository logRepository;
  final BackupCryptoService cryptoService;
  final Clock clock;

  Future<Result<String, AppFailure>> exportEncrypted(String passphrase) async {
    final habits = await habitRepository.getAllHabits();
    final logs = await logRepository.getAllLogs();

    final payload = <String, dynamic>{
      'exportedAt': clock.now().toUtc().toIso8601String(),
      'habits': habits
          .map(
            (h) => {
              'id': h.id,
              'name': h.name,
              'iconKey': h.iconKey,
              'colorHex': h.colorHex,
              'type': h.type.name,
              'targetValue': h.targetValue,
              'unit': h.unit,
              'scheduleType': h.schedule.type.toStorageKey(),
              'scheduleConfig': h.schedule.toConfigJson(),
              'allowShields': h.allowShields,
              'reminderTime': h.reminderTime,
              'sortOrder': h.sortOrder,
              'isArchived': h.isArchived,
              'createdAt': h.createdAt.toIsoString(),
            },
          )
          .toList(),
      'logs': logs
          .map(
            (l) => {
              'id': l.id,
              'habitId': l.habitId,
              'date': l.date.toIsoString(),
              'status': l.status.toStorageKey(),
              'value': l.value,
              'note': l.note,
              'updatedAtEpochMs': l.updatedAtEpochMs,
            },
          )
          .toList(),
    };

    return cryptoService.encryptJson(payload: payload, passphrase: passphrase);
  }

  Future<Result<int, AppFailure>> importEncrypted({
    required String encryptedEnvelope,
    required String passphrase,
  }) async {
    final decrypted = await cryptoService.decryptJson(
      encryptedEnvelope: encryptedEnvelope,
      passphrase: passphrase,
    );
    if (decrypted.isFailure) {
      return Failure(decrypted.errorOrNull!);
    }

    final payload = decrypted.valueOrNull!;
    final rawHabits = payload['habits'];
    final rawLogs = payload['logs'];
    if (rawHabits is! List || rawLogs is! List) {
      return const Failure(
        ValidationFailure('Estructura interna del respaldo inválida.'),
      );
    }

    if (rawHabits.length > maxHabits || rawLogs.length > maxLogs) {
      return const Failure(
        ValidationFailure(
          'El respaldo excede los límites seguros de registros permitidos.',
        ),
      );
    }

    // Phase 1: Validate all habits before writing anything to storage.
    final validatedHabits = <Habit>[];
    final validHabitIds = <String>{};

    for (final item in rawHabits) {
      if (item is! Map<String, dynamic>) {
        return const Failure(
          ValidationFailure('Elemento de hábito malformado en el respaldo.'),
        );
      }
      final id = item['id'];
      final name = item['name'];
      if (id is! String ||
          id.trim().isEmpty ||
          id.length > maxIdLength ||
          name is! String) {
        return const Failure(
          ValidationFailure('Hábito con identificador o nombre inválido.'),
        );
      }

      final typeRaw = item['type'] is String ? item['type'] as String : 'binary';
      final type = HabitType.fromName(typeRaw);
      final targetRaw = item['targetValue'];
      final targetValue = targetRaw is num ? targetRaw.toDouble() : 1.0;
      final colorHex =
          item['colorHex'] is String ? item['colorHex'] as String : '#158052';

      final draftCheck = Habit.validateDraft(
        name: name,
        type: type,
        targetValue: targetValue,
        colorHex: colorHex,
      );
      if (draftCheck.isFailure) {
        return Failure(draftCheck.errorOrNull!);
      }

      final scheduleType = item['scheduleType'] is String
          ? item['scheduleType'] as String
          : 'daily';
      final scheduleConfig = item['scheduleConfig'] is String
          ? item['scheduleConfig'] as String
          : '{}';

      final createdAtRaw =
          item['createdAt'] is String ? item['createdAt'] as String : '';

      validatedHabits.add(
        Habit(
          id: id.trim(),
          name: name.trim(),
          iconKey:
              item['iconKey'] is String ? item['iconKey'] as String : 'check',
          colorHex: colorHex,
          type: type,
          targetValue: targetValue,
          unit: item['unit'] is String ? item['unit'] as String : null,
          schedule: HabitSchedule.fromStorage(scheduleType, scheduleConfig),
          allowShields:
              item['allowShields'] is bool ? item['allowShields'] as bool : true,
          reminderTime: item['reminderTime'] is String
              ? item['reminderTime'] as String
              : null,
          sortOrder: item['sortOrder'] is num
              ? (item['sortOrder'] as num).toInt()
              : 0,
          isArchived:
              item['isArchived'] is bool ? item['isArchived'] as bool : false,
          createdAt: LocalDate.tryParse(createdAtRaw) ?? clock.today(),
        ),
      );
      validHabitIds.add(id.trim());
    }

    // Also allow logs referencing habits already existing in the local DB.
    final existingHabits = await habitRepository.getAllHabits();
    for (final h in existingHabits) {
      validHabitIds.add(h.id);
    }

    // Phase 2: Validate logs and enforce referential integrity & note length.
    final validatedLogs = <HabitLog>[];
    for (final item in rawLogs) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['id'];
      final habitId = item['habitId'];
      final dateRaw = item['date'];
      if (id is! String ||
          id.trim().isEmpty ||
          id.length > maxIdLength ||
          habitId is! String ||
          !validHabitIds.contains(habitId.trim()) ||
          dateRaw is! String) {
        continue;
      }

      final parsedDate = LocalDate.tryParse(dateRaw);
      if (parsedDate == null) continue;

      final rawNote = item['note'];
      final safeNote = rawNote is String && rawNote.trim().isNotEmpty
          ? rawNote.trim().substring(
                0,
                rawNote.trim().length > maxNoteLength
                    ? maxNoteLength
                    : rawNote.trim().length,
              )
          : null;

      final valueRaw = item['value'];
      final value =
          valueRaw is num ? valueRaw.toDouble().clamp(0.0, 100000.0) : 1.0;

      validatedLogs.add(
        HabitLog(
          id: id.trim(),
          habitId: habitId.trim(),
          date: parsedDate,
          status: LogStatus.fromName(
            item['status'] is String ? item['status'] as String : 'completed',
          ),
          value: value,
          note: safeNote,
          updatedAtEpochMs: item['updatedAtEpochMs'] is num
              ? (item['updatedAtEpochMs'] as num).toInt()
              : clock.now().millisecondsSinceEpoch,
        ),
      );
    }

    // Phase 3: Persist validated records.
    var importedHabits = 0;
    for (final habit in validatedHabits) {
      final res = await habitRepository.save(habit);
      if (res.isSuccess) importedHabits++;
    }

    for (final log in validatedLogs) {
      await logRepository.upsertLog(log);
    }

    return Success(importedHabits);
  }
}
