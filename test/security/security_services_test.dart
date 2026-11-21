import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hilo/core/security/backup_crypto_service.dart';
import 'package:hilo/features/widget_sync/domain/widget_snapshot.dart';

void main() {
  group('BackupCryptoService (AES-256-GCM + PBKDF2)', () {
    // Lower iterations in unit tests for fast execution while verifying full AEAD flow.
    final crypto = BackupCryptoService(pbkdf2Iterations: 10000);

    test('encrypts and decrypts payload cleanly with valid passphrase', () async {
      final original = {
        'habits': [
          {'id': '1', 'name': 'Meditar'},
        ],
        'logs': [],
      };

      final encrypted = await crypto.encryptJson(
        payload: original,
        passphrase: 'mi-clave-segura-2026',
      );
      expect(encrypted.isSuccess, isTrue);

      final decrypted = await crypto.decryptJson(
        encryptedEnvelope: encrypted.valueOrNull!,
        passphrase: 'mi-clave-segura-2026',
      );
      expect(decrypted.isSuccess, isTrue);
      expect(decrypted.valueOrNull, equals(original));
    });

    test('rejects wrong passphrase and tampered ciphertext', () async {
      final encrypted = await crypto.encryptJson(
        payload: {'secret': 'nota privada'},
        passphrase: 'correct-password',
      );
      final envelope = encrypted.valueOrNull!;

      final wrongPass = await crypto.decryptJson(
        encryptedEnvelope: envelope,
        passphrase: 'wrong-password',
      );
      expect(wrongPass.isFailure, isTrue);

      final tamperedMap = jsonDecode(envelope) as Map<String, dynamic>;
      tamperedMap['ciphertext'] = base64Encode([1, 2, 3, 4, 5]);
      final tampered = await crypto.decryptJson(
        encryptedEnvelope: jsonEncode(tamperedMap),
        passphrase: 'correct-password',
      );
      expect(tampered.isFailure, isTrue);
    });

    test('rejects weak passphrases shorter than 8 characters', () async {
      final res = await crypto.encryptJson(
        payload: {'a': 1},
        passphrase: '1234',
      );
      expect(res.isFailure, isTrue);
    });
  });

  group('WidgetActionValidator', () {
    const validUuid = '550e8400-e29b-41d4-a716-446655440000';

    test('accepts valid toggle and increment widget URIs', () {
      final toggle = WidgetActionValidator.parseUri(
        Uri.parse('hilo://widget/toggle?id=$validUuid'),
      );
      expect(toggle.isSuccess, isTrue);
      expect(toggle.valueOrNull!.type, WidgetActionType.toggleHabit);
      expect(toggle.valueOrNull!.habitId, validUuid);

      final inc = WidgetActionValidator.parseUri(
        Uri.parse('hilo://widget/increment?id=$validUuid'),
      );
      expect(inc.isSuccess, isTrue);
      expect(inc.valueOrNull!.type, WidgetActionType.incrementHabit);
    });

    test('rejects spoofed scheme, unknown action, or malformed IDs', () {
      expect(
        WidgetActionValidator.parseUri(
          Uri.parse('https://evil.com/toggle?id=$validUuid'),
        ).isFailure,
        isTrue,
      );
      expect(
        WidgetActionValidator.parseUri(
          Uri.parse('hilo://widget/deleteAll?id=$validUuid'),
        ).isFailure,
        isTrue,
      );
      expect(
        WidgetActionValidator.parseUri(
          Uri.parse("hilo://widget/toggle?id=' OR 1=1--"),
        ).isFailure,
        isTrue,
      );
    });
  });
}
