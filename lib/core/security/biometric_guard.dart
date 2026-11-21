import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Coordinates optional biometric app lock and Android FLAG_SECURE screen protection.
final class BiometricGuard {
  BiometricGuard({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  static const _securityChannel = MethodChannel('nuviapps.co.hilo/security');
  final LocalAuthentication _localAuth;

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return true;
      return await _localAuth.authenticate(
        localizedReason: 'Desbloquea Hilo para acceder a tus hábitos',
      );
    } on PlatformException {
      return false;
    }
  }

  Future<void> setScreenPrivacy(bool enabled) async {
    try {
      await _securityChannel.invokeMethod<void>(
        'setFlagSecure',
        {'enabled': enabled},
      );
    } on MissingPluginException {
      // Safe no-op on non-Android platforms or widget tests.
    } on PlatformException {
      // Safe no-op if platform channel is unavailable.
    }
  }
}
