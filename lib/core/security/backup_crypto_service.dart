import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:hilo/core/error/result.dart';

/// Encrypts and decrypts `.hilo` backup payloads using AES-256-GCM
/// with keys derived via PBKDF2-HMAC-SHA256.
final class BackupCryptoService {
  BackupCryptoService({
    this.pbkdf2Iterations = 100000,
  });

  static const int formatVersion = 1;
  static const int maxBackupBytes = 10 * 1024 * 1024; // 10 MB DoS guard
  static const int minPassphraseLength = 8;

  final int pbkdf2Iterations;
  final AesGcm _cipher = AesGcm.with256bits();

  Future<Result<String, AppFailure>> encryptJson({
    required Map<String, dynamic> payload,
    required String passphrase,
  }) async {
    if (passphrase.length < minPassphraseLength) {
      return const Failure(
        ValidationFailure(
          'La contraseña debe tener al menos $minPassphraseLength caracteres.',
        ),
      );
    }

    try {
      final salt = _randomBytes(16);
      final nonce = _randomBytes(12);
      final secretKey = await _deriveKey(passphrase, salt);

      final plaintext = utf8.encode(jsonEncode(payload));
      final secretBox = await _cipher.encrypt(
        plaintext,
        secretKey: secretKey,
        nonce: nonce,
      );

      final envelope = <String, dynamic>{
        'app': 'nuviapps.co.hilo',
        'version': formatVersion,
        'kdf': 'PBKDF2-HMAC-SHA256',
        'iterations': pbkdf2Iterations,
        'cipher': 'AES-256-GCM',
        'salt': base64Encode(salt),
        'nonce': base64Encode(secretBox.nonce),
        'mac': base64Encode(secretBox.mac.bytes),
        'ciphertext': base64Encode(secretBox.cipherText),
      };

      return Success(jsonEncode(envelope));
    } catch (e) {
      return Failure(SecurityFailure('Error al cifrar el respaldo.', e));
    }
  }

  Future<Result<Map<String, dynamic>, AppFailure>> decryptJson({
    required String encryptedEnvelope,
    required String passphrase,
  }) async {
    if (encryptedEnvelope.length > maxBackupBytes) {
      return const Failure(
        ValidationFailure('El archivo de respaldo excede el tamaño permitido.'),
      );
    }

    try {
      final decoded = jsonDecode(encryptedEnvelope);
      if (decoded is! Map<String, dynamic>) {
        return const Failure(
          ValidationFailure('Formato de respaldo inválido.'),
        );
      }

      if (decoded['app'] != 'nuviapps.co.hilo' ||
          decoded['version'] != formatVersion ||
          decoded['cipher'] != 'AES-256-GCM') {
        return const Failure(
          ValidationFailure('Archivo de respaldo no compatible con Hilo.'),
        );
      }

      final iterations = decoded['iterations'];
      if (iterations is! int || iterations < 10000 || iterations > 1000000) {
        return const Failure(
          SecurityFailure('Parámetros criptográficos inválidos en el respaldo.'),
        );
      }

      final salt = base64Decode(decoded['salt'] as String);
      final nonce = base64Decode(decoded['nonce'] as String);
      final macBytes = base64Decode(decoded['mac'] as String);
      final cipherText = base64Decode(decoded['ciphertext'] as String);

      final pbkdf2 = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      );
      final secretKey = await pbkdf2.deriveKeyFromPassword(
        password: passphrase,
        nonce: salt,
      );

      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: Mac(macBytes),
      );

      final clearBytes = await _cipher.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      final jsonPayload = jsonDecode(utf8.decode(clearBytes));
      if (jsonPayload is! Map<String, dynamic>) {
        return const Failure(
          ValidationFailure('Contenido del respaldo corrupto.'),
        );
      }
      return Success(jsonPayload);
    } on SecretBoxAuthenticationError {
      return const Failure(
        SecurityFailure(
          'Contraseña incorrecta o archivo de respaldo alterado.',
        ),
      );
    } catch (e) {
      return Failure(
        SecurityFailure('No se pudo descifrar el respaldo.', e),
      );
    }
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: pbkdf2Iterations,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(password: passphrase, nonce: salt);
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
