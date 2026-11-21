import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilo/core/database/hilo_database.dart';
import 'package:hilo/core/di/providers.dart';
import 'package:hilo/core/router/hilo_shell.dart';
import 'package:hilo/core/security/biometric_guard.dart';
import 'package:hilo/core/security/secure_key_store.dart';
import 'package:hilo/core/theme/hilo_theme.dart';
import 'package:hilo/features/widget_sync/infrastructure/android_home_widget_adapter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final keyStore = FlutterSecureKeyStore();
  final dbKey = await keyStore.getOrCreateDatabaseKey();
  final database = HiloDatabase.encrypted(hexKey: dbKey);

  final biometricEnabled = await keyStore.isBiometricLockEnabled();
  final screenPrivacyEnabled = await keyStore.isScreenPrivacyEnabled();
  if (screenPrivacyEnabled) {
    await BiometricGuard().setScreenPrivacy(true);
  }

  await HomeWidget.registerInteractivityCallback(hiloWidgetBackgroundCallback);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        secureKeyStoreProvider.overrideWithValue(keyStore),
      ],
      child: HiloApp(requireBiometricOnStart: biometricEnabled),
    ),
  );
}

class HiloApp extends ConsumerWidget {
  const HiloApp({
    super.key,
    this.requireBiometricOnStart = false,
  });

  final bool requireBiometricOnStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Hilo',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: HiloTheme.light(),
      darkTheme: HiloTheme.dark(),
      home: HiloShell(requireBiometricOnStart: requireBiometricOnStart),
    );
  }
}
