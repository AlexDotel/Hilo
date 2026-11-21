import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/database/hilo_database.dart';
import 'package:hilo/core/error/result.dart';
import 'package:hilo/core/security/backup_crypto_service.dart';
import 'package:hilo/core/security/secure_key_store.dart';
import 'package:hilo/features/backup/application/backup_service.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/infrastructure/drift_habit_repository.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/heatmap_builder.dart';
import 'package:hilo/features/tracking/domain/streak_engine.dart';
import 'package:hilo/features/tracking/infrastructure/drift_log_repository.dart';
import 'package:hilo/features/widget_sync/application/widget_sync_service.dart';
import 'package:hilo/features/widget_sync/domain/widget_snapshot.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;

  @override
  DateTime now() => _now;

  @override
  LocalDate today() => LocalDate.fromDateTime(_now);
}

final class _CapturingWidgetBridge implements WidgetBridgePort {
  WidgetSnapshot? captured;

  @override
  Future<Result<void, AppFailure>> pushSnapshot(WidgetSnapshot snapshot) async {
    captured = snapshot;
    return const Success(null);
  }
}

final class _PrivacyKeyStore implements SecureKeyStorePort {
  _PrivacyKeyStore({this.widgetPrivacy = true});
  bool widgetPrivacy;

  @override
  Future<String> getOrCreateDatabaseKey() async =>
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  @override
  Future<bool> isBiometricLockEnabled() async => false;

  @override
  Future<bool> isScreenPrivacyEnabled() async => false;

  @override
  Future<bool> isWidgetPrivacyModeEnabled() async => widgetPrivacy;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}

  @override
  Future<void> setScreenPrivacyEnabled(bool enabled) async {}

  @override
  Future<void> setWidgetPrivacyModeEnabled(bool enabled) async =>
      widgetPrivacy = enabled;
}

void main() {
  group('Security Hardening Regression Tests', () {
    test('HiloDatabase.encrypted fails closed on invalid SQLCipher key', () {
      expect(
        () => HiloDatabase.encrypted(hexKey: 'not-a-valid-64-hex-key'),
        throwsStateError,
      );
      expect(
        () => HiloDatabase.encrypted(hexKey: ''),
        throwsStateError,
      );
    });

    test('BackupCryptoService rejects invalid nonce/salt lengths without throwing', () async {
      final crypto = BackupCryptoService(pbkdf2Iterations: 10000);
      final malformedEnvelope = jsonEncode({
        'app': 'nuviapps.co.hilo',
        'version': 1,
        'kdf': 'PBKDF2-HMAC-SHA256',
        'iterations': 10000,
        'cipher': 'AES-256-GCM',
        'salt': base64Encode([1, 2, 3]), // invalid: must be 16 bytes
        'nonce': base64Encode([1, 2, 3]), // invalid: must be 12 bytes
        'mac': base64Encode([1, 2, 3]), // invalid: must be 16 bytes
        'ciphertext': base64Encode([1, 2, 3]),
      });

      final res = await crypto.decryptJson(
        encryptedEnvelope: malformedEnvelope,
        passphrase: 'valid-passphrase',
      );
      expect(res.isFailure, isTrue);
    });

    test('BackupService drops orphan logs, truncates huge notes, and rejects malformed habits', () async {
      final db = HiloDatabase.inMemory();
      addTearDown(db.close);

      final habitRepo = DriftHabitRepository(db);
      final logRepo = DriftLogRepository(db);
      final crypto = BackupCryptoService(pbkdf2Iterations: 10000);
      final service = BackupService(
        habitRepository: habitRepo,
        logRepository: logRepo,
        cryptoService: crypto,
        clock: _FixedClock(DateTime(2026, 11, 21)),
      );

      // Crafted payload with 1 valid habit, 1 valid log with 2000-char note, 1 orphan log
      final craftedPayload = <String, dynamic>{
        'habits': [
          {
            'id': '550e8400-e29b-41d4-a716-446655440000',
            'name': 'Leer',
            'colorHex': '#158052',
            'type': 'binary',
            'targetValue': 1,
          },
        ],
        'logs': [
          {
            'id': 'log-valid',
            'habitId': '550e8400-e29b-41d4-a716-446655440000',
            'date': '2026-11-21',
            'status': 'completed',
            'value': 1,
            'note': 'A' * 2000,
          },
          {
            'id': 'log-orphan',
            'habitId': 'non-existent-habit-id',
            'date': '2026-11-21',
            'status': 'completed',
            'value': 1,
          },
        ],
      };

      final encrypted = await crypto.encryptJson(
        payload: craftedPayload,
        passphrase: 'strong-passphrase-123',
      );
      final imported = await service.importEncrypted(
        encryptedEnvelope: encrypted.valueOrNull!,
        passphrase: 'strong-passphrase-123',
      );

      expect(imported.isSuccess, isTrue);
      expect(imported.valueOrNull, 1);

      final storedLogs = await logRepo.getAllLogs();
      expect(storedLogs.length, 1);
      expect(storedLogs.first.id, 'log-valid');
      expect(storedLogs.first.note!.length, BackupService.maxNoteLength);

      // Crafted payload with invalid habit type (int instead of String for name)
      final badHabitPayload = <String, dynamic>{
        'habits': [
          {'id': 'h-bad', 'name': 12345},
        ],
        'logs': <dynamic>[],
      };
      final badEnc = await crypto.encryptJson(
        payload: badHabitPayload,
        passphrase: 'strong-passphrase-123',
      );
      final badImport = await service.importEncrypted(
        encryptedEnvelope: badEnc.valueOrNull!,
        passphrase: 'strong-passphrase-123',
      );
      expect(badImport.isFailure, isTrue);
    });

    test('WidgetSyncService privacy mode masks habit names and never leaks private notes', () async {
      final db = HiloDatabase.inMemory();
      addTearDown(db.close);

      final habitRepo = DriftHabitRepository(db);
      final logRepo = DriftLogRepository(db);
      final bridge = _CapturingWidgetBridge();
      final clock = _FixedClock(DateTime(2026, 11, 21));

      await habitRepo.save(
        const Habit(
          id: '550e8400-e29b-41d4-a716-446655440000',
          name: 'Terapia personal',
          iconKey: 'meditation',
          colorHex: '#158052',
          type: HabitType.binary,
          targetValue: 1,
          schedule: DailySchedule(),
          allowShields: true,
          sortOrder: 0,
          isArchived: false,
          createdAt: LocalDate(2026, 11, 20),
        ),
      );

      await logRepo.upsertLog(
        const HabitLog(
          id: 'l1',
          habitId: '550e8400-e29b-41d4-a716-446655440000',
          date: LocalDate(2026, 11, 21),
          status: LogStatus.completed,
          value: 1,
          note: 'SECRETO_CONFIDENCIAL_NO_EXPONER',
          updatedAtEpochMs: 1000,
        ),
      );

      final syncService = WidgetSyncService(
        habitRepository: habitRepo,
        logRepository: logRepo,
        widgetBridge: bridge,
        keyStore: _PrivacyKeyStore(widgetPrivacy: true),
        clock: clock,
        streakEngine: const StreakEngine(),
        heatmapBuilder: const HeatmapBuilder(),
      );

      await syncService.syncNow();
      expect(bridge.captured, isNotNull);

      final rawJson = bridge.captured!.toJsonString();
      expect(rawJson.contains('SECRETO_CONFIDENCIAL_NO_EXPONER'), isFalse);
      expect(rawJson.contains('Terapia personal'), isFalse);
      expect(bridge.captured!.todayHabits.first.title, 'Hábito 1');
    });
  });

  group('Domain Consistency & Heatmap Regression Tests', () {
    test('evaluateGlobal and HeatmapBuilder do not penalize weekly-quota habits once quota is met', () {
      const engine = StreakEngine();
      const builder = HeatmapBuilder();
      // ISO week: Mon Nov 16 .. Sun Nov 22, 2026
      const today = LocalDate(2026, 11, 21);

      final dailyHabit = const Habit(
        id: 'daily',
        name: 'Leer',
        iconKey: 'book',
        colorHex: '#158052',
        type: HabitType.binary,
        targetValue: 1,
        schedule: DailySchedule(),
        allowShields: true,
        sortOrder: 0,
        isArchived: false,
        createdAt: LocalDate(2026, 11, 16),
      );
      final weeklyHabit = Habit(
        id: 'weekly',
        name: 'Entrenar',
        iconKey: 'fitness',
        colorHex: '#E06D53',
        type: HabitType.binary,
        targetValue: 1,
        schedule: TimesPerWeekSchedule(3),
        allowShields: true,
        sortOrder: 1,
        isArchived: false,
        createdAt: const LocalDate(2026, 11, 16),
      );

      final logs = <HabitLog>[
        // Daily habit done every day Nov 16..21
        for (var d = 16; d <= 21; d++)
          HabitLog(
            id: 'd-$d',
            habitId: 'daily',
            date: LocalDate(2026, 11, d),
            status: LogStatus.completed,
            value: 1,
            updatedAtEpochMs: 0,
          ),
        // Weekly 3x habit done Mon(16), Wed(18), Fri(20) -> 3/3 quota met!
        for (final d in [16, 18, 20])
          HabitLog(
            id: 'w-$d',
            habitId: 'weekly',
            date: LocalDate(2026, 11, d),
            status: LogStatus.completed,
            value: 1,
            updatedAtEpochMs: 0,
          ),
      ];

      final globalSummary = engine.evaluateGlobal(
        activeHabits: [dailyHabit, weeklyHabit],
        logs: logs,
        today: today,
      );
      expect(globalSummary.consistency30Days, 100);

      final grid = builder.buildGrid(
        activeHabits: [dailyHabit, weeklyHabit],
        logs: logs,
        today: today,
        weeks: 2,
      );
      final satCell = grid.firstWhere((c) => c.date == today);
      expect(satCell.level, 4);
    });
  });
}
