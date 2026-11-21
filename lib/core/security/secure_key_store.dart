import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Port for secure key & privacy-preference persistence (Android Keystore / iOS Keychain).
abstract interface class SecureKeyStorePort {
  /// Returns the 64-char hex (256-bit) SQLCipher key, creating one securely if absent.
  Future<String> getOrCreateDatabaseKey();

  Future<bool> isBiometricLockEnabled();
  Future<void> setBiometricLockEnabled(bool enabled);

  Future<bool> isScreenPrivacyEnabled();
  Future<void> setScreenPrivacyEnabled(bool enabled);

  Future<bool> isWidgetPrivacyModeEnabled();
  Future<void> setWidgetPrivacyModeEnabled(bool enabled);
}

final class FlutterSecureKeyStore implements SecureKeyStorePort {
  FlutterSecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
            );

  static const _dbKeyName = 'hilo_sqlcipher_db_key_v1';
  static const _biometricKey = 'hilo_biometric_lock_v1';
  static const _screenPrivacyKey = 'hilo_screen_privacy_v1';
  static const _widgetPrivacyKey = 'hilo_widget_privacy_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<String> getOrCreateDatabaseKey() async {
    final existing = await _storage.read(key: _dbKeyName);
    if (existing != null && _isValidHexKey(existing)) {
      return existing;
    }
    final generated = _generate256BitHexKey();
    await _storage.write(key: _dbKeyName, value: generated);
    return generated;
  }

  @override
  Future<bool> isBiometricLockEnabled() async =>
      (await _storage.read(key: _biometricKey)) == 'true';

  @override
  Future<void> setBiometricLockEnabled(bool enabled) =>
      _storage.write(key: _biometricKey, value: enabled ? 'true' : 'false');

  @override
  Future<bool> isScreenPrivacyEnabled() async =>
      (await _storage.read(key: _screenPrivacyKey)) == 'true';

  @override
  Future<void> setScreenPrivacyEnabled(bool enabled) =>
      _storage.write(key: _screenPrivacyKey, value: enabled ? 'true' : 'false');

  @override
  Future<bool> isWidgetPrivacyModeEnabled() async =>
      (await _storage.read(key: _widgetPrivacyKey)) == 'true';

  @override
  Future<void> setWidgetPrivacyModeEnabled(bool enabled) =>
      _storage.write(key: _widgetPrivacyKey, value: enabled ? 'true' : 'false');

  static bool _isValidHexKey(String value) =>
      value.length == 64 && RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value);

  static String _generate256BitHexKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
