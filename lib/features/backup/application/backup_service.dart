import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/core/security/backup_crypto_service.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/domain/habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';

/// Application service exporting and importing encrypted `.hilo` local backups.
final class BackupService {
  const BackupService({
    required this.habitRepository,
    required this.logRepository,
    required this.cryptoService,
    required this.clock,
  });

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

    var importedHabits = 0;
    for (final item in rawHabits) {
      if (item is! Map<String, dynamic>) continue;
      final habit = Habit(
        id: item['id'] as String,
        name: item['name'] as String,
        iconKey: (item['iconKey'] as String?) ?? 'check',
        colorHex: (item['colorHex'] as String?) ?? '#158052',
        type: HabitType.fromName((item['type'] as String?) ?? 'binary'),
        targetValue: ((item['targetValue'] as num?) ?? 1.0).toDouble(),
        unit: item['unit'] as String?,
        schedule: HabitSchedule.fromStorage(
          (item['scheduleType'] as String?) ?? 'daily',
          (item['scheduleConfig'] as String?) ?? '{}',
        ),
        allowShields: (item['allowShields'] as bool?) ?? true,
        reminderTime: item['reminderTime'] as String?,
        sortOrder: ((item['sortOrder'] as num?) ?? 0).toInt(),
        isArchived: (item['isArchived'] as bool?) ?? false,
        createdAt: LocalDate.tryParse((item['createdAt'] as String?) ?? '') ??
            clock.today(),
      );
      final res = await habitRepository.save(habit);
      if (res.isSuccess) importedHabits++;
    }

    for (final item in rawLogs) {
      if (item is! Map<String, dynamic>) continue;
      final parsedDate = LocalDate.tryParse((item['date'] as String?) ?? '');
      if (parsedDate == null) continue;
      await logRepository.upsertLog(
        HabitLog(
          id: item['id'] as String,
          habitId: item['habitId'] as String,
          date: parsedDate,
          status: LogStatus.fromName((item['status'] as String?) ?? 'completed'),
          value: ((item['value'] as num?) ?? 1.0).toDouble(),
          note: item['note'] as String?,
          updatedAtEpochMs: ((item['updatedAtEpochMs'] as num?) ??
                  clock.now().millisecondsSinceEpoch)
              .toInt(),
        ),
      );
    }

    return Success(importedHabits);
  }
}
