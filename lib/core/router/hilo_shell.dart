import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilo/core/di/providers.dart';
import 'package:hilo/features/habits/presentation/habit_editor_sheet.dart';
import 'package:hilo/features/habits/presentation/habits_screen.dart';
import 'package:hilo/features/tracking/presentation/heatmap_screen.dart';
import 'package:hilo/features/tracking/presentation/today_screen.dart';

class HiloShell extends ConsumerStatefulWidget {
  const HiloShell({super.key, this.requireBiometricOnStart = false});

  final bool requireBiometricOnStart;

  @override
  ConsumerState<HiloShell> createState() => _HiloShellState();
}

class _HiloShellState extends ConsumerState<HiloShell> {
  int _currentIndex = 0;
  late bool _locked;

  @override
  void initState() {
    super.initState();
    _locked = widget.requireBiometricOnStart;
    if (_locked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  Future<void> _unlock() async {
    final ok = await ref.read(biometricGuardProvider).authenticate();
    if (mounted && ok) {
      setState(() => _locked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Hilo está bloqueado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _unlock,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Desbloquear'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TodayScreen(
            onCreateHabit: () => showHabitEditorSheet(context),
          ),
          const HeatmapScreen(),
          const HabitsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo hábito',
        onPressed: () => showHabitEditorSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Hábitos',
          ),
        ],
      ),
    );
  }
}
