import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilo/core/di/providers.dart';
import 'package:hilo/core/theme/hilo_theme.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/presentation/habit_editor_sheet.dart';
import 'package:hilo/features/habits/presentation/habit_icons.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.hiloColors;
    final allHabitsAsync = ref.watch(allHabitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hábitos'),
        actions: [
          IconButton(
            tooltip: 'Seguridad y Ajustes',
            icon: const Icon(Icons.shield_outlined),
            onPressed: () => _showSecuritySettings(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: allHabitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (habits) {
          final active = habits.where((h) => !h.isArchived).toList();
          final archived = habits.where((h) => h.isArchived).toList();

          if (habits.isEmpty) {
            return Center(
              child: Text(
                'Aún no has creado hábitos.',
                style: TextStyle(color: colors.textSecondary),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              if (active.isNotEmpty) ...[
                _SectionTitle('ACTIVOS (${active.length})'),
                const SizedBox(height: 8),
                ...active.map((h) => _HabitRow(habit: h)),
              ],
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SectionTitle('ARCHIVADOS (${archived.length})'),
                const SizedBox(height: 8),
                ...archived.map((h) => _HabitRow(habit: h)),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showSecuritySettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SecurityAndThemeSheet(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: context.hiloColors.textSecondary,
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.hiloColors;
    final accent = HiloHabitPalette.fromHex(habit.colorHex);
    final controller = ref.read(trackingControllerProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.15),
            child: Icon(
              HiloHabitIcons.resolve(habit.iconKey),
              color: accent,
              size: 20,
            ),
          ),
          title: Text(
            habit.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          subtitle: Text(
            _scheduleSummary(habit),
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (action) async {
              switch (action) {
                case 'edit':
                  await showHabitEditorSheet(context, existing: habit);
                case 'archive':
                  await controller.archiveHabit(habit.id, !habit.isArchived);
                case 'delete':
                  await controller.deleteHabit(habit.id);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(
                value: 'archive',
                child: Text(habit.isArchived ? 'Restaurar' : 'Archivar'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
          onTap: () => showHabitEditorSheet(context, existing: habit),
        ),
      ),
    );
  }

  String _scheduleSummary(Habit h) {
    final freq = switch (h.schedule) {
      DailySchedule() => 'Todos los días',
      SpecificDaysSchedule(:final weekdays) =>
        '${weekdays.length} días por semana',
      TimesPerWeekSchedule(:final timesPerWeek) =>
        '$timesPerWeek veces por semana',
    };
    final shield = h.allowShields ? ' · Escudos activos' : '';
    return '$freq$shield';
  }
}

class _SecurityAndThemeSheet extends ConsumerStatefulWidget {
  const _SecurityAndThemeSheet();

  @override
  ConsumerState<_SecurityAndThemeSheet> createState() =>
      _SecurityAndThemeSheetState();
}

class _SecurityAndThemeSheetState
    extends ConsumerState<_SecurityAndThemeSheet> {
  bool _biometric = false;
  bool _screenPrivacy = false;
  bool _widgetPrivacy = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final store = ref.read(secureKeyStoreProvider);
    final bio = await store.isBiometricLockEnabled();
    final screen = await store.isScreenPrivacyEnabled();
    final widgetPriv = await store.isWidgetPrivacyModeEnabled();
    if (!mounted) return;
    setState(() {
      _biometric = bio;
      _screenPrivacy = screen;
      _widgetPrivacy = widgetPriv;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final keyStore = ref.read(secureKeyStoreProvider);
    final biometricGuard = ref.read(biometricGuardProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Apariencia y Seguridad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
              ],
              selected: {themeMode},
              onSelectionChanged: (v) =>
                  ref.read(themeModeProvider.notifier).setThemeMode(v.first),
            ),
            const SizedBox(height: 16),
            if (!_loaded)
              const Center(child: CircularProgressIndicator())
            else ...[
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _biometric,
                title: const Text('Bloqueo biométrico'),
                subtitle: const Text(
                  'Solicita huella o rostro al abrir Hilo.',
                ),
                onChanged: (v) async {
                  await keyStore.setBiometricLockEnabled(v);
                  setState(() => _biometric = v);
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _screenPrivacy,
                title: const Text('Protección de pantalla (FLAG_SECURE)'),
                subtitle: const Text(
                  'Oculta el contenido en apps recientes y bloquea capturas.',
                ),
                onChanged: (v) async {
                  await keyStore.setScreenPrivacyEnabled(v);
                  await biometricGuard.setScreenPrivacy(v);
                  setState(() => _screenPrivacy = v);
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _widgetPrivacy,
                title: const Text('Modo privado en el widget Android'),
                subtitle: const Text(
                  'Oculta los nombres de hábitos en la pantalla de inicio.',
                ),
                onChanged: (v) async {
                  await keyStore.setWidgetPrivacyModeEnabled(v);
                  await ref.read(widgetSyncServiceProvider).syncNow();
                  setState(() => _widgetPrivacy = v);
                },
              ),
            ],
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.enhanced_encryption_outlined),
              title: const Text('Exportar respaldo cifrado (.hilo)'),
              subtitle: const Text('Cifrado local AES-256-GCM con tu contraseña.'),
              onTap: () => _exportBackupDialog(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restore_rounded),
              title: const Text('Importar respaldo cifrado'),
              subtitle: const Text('Restaura hábitos e historial desde texto .hilo.'),
              onTap: () => _importBackupDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBackupDialog(BuildContext context) async {
    final passController = TextEditingController();
    final passphrase = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contraseña del respaldo'),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mínimo 8 caracteres',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, passController.text),
            child: const Text('Cifrar'),
          ),
        ],
      ),
    );
    if (passphrase == null || !context.mounted) return;

    final result =
        await ref.read(backupServiceProvider).exportEncrypted(passphrase);
    if (!context.mounted) return;
    result.when(
      success: (envelope) async {
        await Clipboard.setData(ClipboardData(text: envelope));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Respaldo cifrado AES-256 copiado al portapapeles.'),
          ),
        );
      },
      failure: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        );
      },
    );
  }

  Future<void> _importBackupDialog(BuildContext context) async {
    final dataController = TextEditingController();
    final passController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar respaldo .hilo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dataController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Contenido cifrado (.hilo)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final res = await ref.read(backupServiceProvider).importEncrypted(
          encryptedEnvelope: dataController.text.trim(),
          passphrase: passController.text,
        );
    if (!context.mounted) return;
    res.when(
      success: (count) async {
        await ref.read(widgetSyncServiceProvider).syncNow();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se importaron $count hábitos correctamente.')),
        );
      },
      failure: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        );
      },
    );
  }
}
