import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilo/core/di/providers.dart';
import 'package:hilo/core/theme/hilo_theme.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/presentation/habit_icons.dart';

Future<void> showHabitEditorSheet(
  BuildContext context, {
  Habit? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _HabitEditorSheet(existing: existing),
  );
}

class _HabitEditorSheet extends ConsumerStatefulWidget {
  const _HabitEditorSheet({this.existing});

  final Habit? existing;

  @override
  ConsumerState<_HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends ConsumerState<_HabitEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  late HabitType _type;
  late ScheduleType _scheduleType;
  late Set<int> _selectedWeekdays;
  late int _timesPerWeek;
  late String _iconKey;
  late String _colorHex;
  late bool _allowShields;
  String? _errorText;
  bool _saving = false;

  static const _dayChips = [
    (1, 'L'),
    (2, 'M'),
    (3, 'X'),
    (4, 'J'),
    (5, 'V'),
    (6, 'S'),
    (7, 'D'),
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    _nameController = TextEditingController(text: h?.name ?? '');
    _targetController = TextEditingController(
      text: h != null && h.type == HabitType.quantitative
          ? h.targetValue.toStringAsFixed(0)
          : '8',
    );
    _unitController = TextEditingController(text: h?.unit ?? 'vasos');

    _type = h?.type ?? HabitType.binary;
    _iconKey = h?.iconKey ?? 'check';
    _colorHex = h?.colorHex ?? HiloHabitPalette.hexColors.first;
    _allowShields = h?.allowShields ?? true;

    final sched = h?.schedule ?? const DailySchedule();
    _scheduleType = sched.type;
    _selectedWeekdays = switch (sched) {
      SpecificDaysSchedule(:final weekdays) => Set<int>.from(weekdays),
      _ => {1, 3, 5},
    };
    _timesPerWeek = switch (sched) {
      TimesPerWeekSchedule(:final timesPerWeek) => timesPerWeek,
      _ => 3,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.hiloColors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 4, 20, bottomInset + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Nuevo hábito' : 'Editar hábito',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: 'Nombre del hábito',
                hintText: 'Ej. Leer 20 minutos, Entrenar, Meditar',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<HabitType>(
              segments: const [
                ButtonSegment(
                  value: HabitType.binary,
                  label: Text('Sí / No'),
                  icon: Icon(Icons.check_circle_outline_rounded),
                ),
                ButtonSegment(
                  value: HabitType.quantitative,
                  label: Text('Cantidad'),
                  icon: Icon(Icons.pin_outlined),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            if (_type == HabitType.quantitative) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Meta diaria',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        hintText: 'min, vasos, km',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Text(
              'Frecuencia flexible',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ScheduleType>(
              segments: const [
                ButtonSegment(
                  value: ScheduleType.daily,
                  label: Text('Diario'),
                ),
                ButtonSegment(
                  value: ScheduleType.specificDays,
                  label: Text('Días'),
                ),
                ButtonSegment(
                  value: ScheduleType.timesPerWeek,
                  label: Text('Semanal'),
                ),
              ],
              selected: {_scheduleType},
              onSelectionChanged: (v) =>
                  setState(() => _scheduleType = v.first),
            ),
            if (_scheduleType == ScheduleType.specificDays) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: _dayChips.map((entry) {
                  final selected = _selectedWeekdays.contains(entry.$1);
                  return FilterChip(
                    label: Text(entry.$2),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedWeekdays.add(entry.$1);
                        } else if (_selectedWeekdays.length > 1) {
                          _selectedWeekdays.remove(entry.$1);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            if (_scheduleType == ScheduleType.timesPerWeek) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '$_timesPerWeek veces por semana',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: Slider(
                      value: _timesPerWeek.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      label: '$_timesPerWeek',
                      onChanged: (v) =>
                          setState(() => _timesPerWeek = v.round()),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Color e ícono',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: HiloHabitPalette.hexColors.map((hex) {
                final c = HiloHabitPalette.fromHex(hex);
                final selected = hex == _colorHex;
                return GestureDetector(
                  onTap: () => setState(() => _colorHex = hex),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: colors.textPrimary, width: 2.5)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HiloHabitIcons.registry.entries.map((entry) {
                final selected = entry.key == _iconKey;
                final accent = HiloHabitPalette.fromHex(_colorHex);
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _iconKey = entry.key),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? accent.withValues(alpha: 0.16)
                          : colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? accent : colors.border,
                      ),
                    ),
                    child: Icon(
                      entry.value,
                      size: 20,
                      color: selected ? accent : colors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _allowShields,
              onChanged: (v) => setState(() => _allowShields = v),
              title: const Text('Escudos de gracia automáticos'),
              subtitle: const Text(
                'Gana 1 escudo cada 7 días completados para proteger tu racha.',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: Text(
                widget.existing == null ? 'Crear hábito' : 'Guardar cambios',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    double target = 1.0;
    if (_type == HabitType.quantitative) {
      final parsed = double.tryParse(_targetController.text.trim());
      if (parsed == null || parsed <= 0 || parsed > 10000) {
        setState(() {
          _errorText = 'Ingresa una meta numérica válida mayor que 0.';
        });
        return;
      }
      target = parsed;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    final schedule = switch (_scheduleType) {
      ScheduleType.daily => const DailySchedule(),
      ScheduleType.specificDays => SpecificDaysSchedule(_selectedWeekdays),
      ScheduleType.timesPerWeek => TimesPerWeekSchedule(_timesPerWeek),
    };

    final res = await ref.read(trackingControllerProvider).saveHabit(
          existingId: widget.existing?.id,
          name: _nameController.text,
          iconKey: _iconKey,
          colorHex: _colorHex,
          type: _type,
          targetValue: target,
          unit: _unitController.text,
          schedule: schedule,
          allowShields: _allowShields,
          sortOrder: widget.existing?.sortOrder ?? 0,
          isArchived: widget.existing?.isArchived ?? false,
          createdAt: widget.existing?.createdAt,
        );

    if (!mounted) return;
    res.when(
      success: (_) => Navigator.pop(context),
      failure: (err) => setState(() {
        _saving = false;
        _errorText = err.message;
      }),
    );
  }
}
