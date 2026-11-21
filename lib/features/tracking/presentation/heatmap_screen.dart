import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilo/core/di/providers.dart';
import 'package:hilo/core/theme/hilo_theme.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/heatmap_builder.dart';
import 'package:hilo/features/tracking/presentation/widgets/heatmap_grid.dart';
import 'package:intl/intl.dart';

class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  String? _selectedHabitId;
  int _weeks = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.hiloColors;
    final today = ref.watch(currentDateProvider);
    final habits = ref.watch(activeHabitsProvider).asData?.value ?? const [];
    final logs = ref.watch(yearLogsProvider).asData?.value ?? const [];
    final streakEngine = ref.watch(streakEngineProvider);
    final heatmapBuilder = ref.watch(heatmapBuilderProvider);

    final selectedHabit = _selectedHabitId == null
        ? null
        : habits.where((h) => h.id == _selectedHabitId).firstOrNull;

    final streakSummary = selectedHabit == null
        ? streakEngine.evaluateGlobal(
            activeHabits: habits,
            logs: logs,
            today: today,
          )
        : streakEngine.evaluateHabit(
            habit: selectedHabit,
            logs: logs,
            today: today,
          );

    final cells = heatmapBuilder.buildGrid(
      activeHabits: habits,
      logs: logs,
      today: today,
      weeks: _weeks,
      filterHabit: selectedHabit,
      shieldDates: streakSummary.autoShieldDates,
    );

    final accentColor = selectedHabit != null
        ? HiloHabitPalette.fromHex(selectedHabit.colorHex)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Calor'),
        actions: [
          SegmentedButton<int>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              side: WidgetStatePropertyAll(BorderSide(color: colors.border)),
            ),
            segments: const [
              ButtonSegment(value: 16, label: Text('16s')),
              ButtonSegment(value: 52, label: Text('1 año')),
            ],
            selected: {_weeks},
            onSelectionChanged: (v) => setState(() => _weeks = v.first),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Global'),
                  selected: selectedHabit == null,
                  onSelected: (_) => setState(() => _selectedHabitId = null),
                ),
                const SizedBox(width: 8),
                ...habits.map((h) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(h.name),
                      selected: selectedHabit?.id == h.id,
                      onSelected: (_) =>
                          setState(() => _selectedHabitId = h.id),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedHabit?.name ?? 'Tu Hilo Global',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Toca un día para editar',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HeatmapGrid(
                    cells: cells,
                    weeks: _weeks,
                    accentColor: accentColor,
                    onCellTap: (cell) => _openDayInspector(
                      context: context,
                      cell: cell,
                      habits: selectedHabit != null ? [selectedHabit] : habits,
                      logs: logs,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _HeatmapLegend(accentColor: accentColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Consistencia',
                  value: '${streakSummary.consistency30Days}%',
                  caption: 'Últimos 30 días',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Racha actual',
                  value: '${streakSummary.currentStreak}d',
                  caption: '${streakSummary.availableShields} escudos',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Mejor racha',
                  value: '${streakSummary.bestStreak}d',
                  caption: 'Histórico',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDayInspector({
    required BuildContext context,
    required HeatmapCell cell,
    required List<Habit> habits,
    required List<HabitLog> logs,
  }) {
    final dayLabel =
        DateFormat('EEEE d MMMM yyyy', 'es').format(cell.date.toUtcDateTime());
    final controller = ref.read(trackingControllerProvider);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, innerRef, _) {
            final liveLogs = innerRef.watch(yearLogsProvider).asData?.value ?? logs;
            final dayLogs = {
              for (final l in liveLogs)
                if (l.date == cell.date) l.habitId: l,
            };

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel[0].toUpperCase() + dayLabel.substring(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edición retroactiva · Toca para marcar o desmarcar',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.hiloColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (habits.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No hay hábitos activos.'),
                      )
                    else
                      ...habits.map((habit) {
                        final log = dayLogs[habit.id];
                        final done = log?.isCompleted == true;
                        final rest = log?.isRestDay == true;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            done
                                ? Icons.check_circle_rounded
                                : rest
                                    ? Icons.pause_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                            color: done
                                ? HiloHabitPalette.fromHex(habit.colorHex)
                                : rest
                                    ? context.hiloColors.shield
                                    : context.hiloColors.textSecondary,
                          ),
                          title: Text(habit.name),
                          subtitle: log?.note != null ? Text(log!.note!) : null,
                          trailing: TextButton(
                            onPressed: () =>
                                controller.toggleRestDay(habit, cell.date),
                            child: Text(rest ? 'Quitar pausa' : 'Descanso'),
                          ),
                          onTap: () {
                            if (habit.type == HabitType.binary) {
                              controller.toggleBinaryHabit(habit, cell.date);
                            } else {
                              controller.adjustQuantitativeHabit(
                                habit,
                                cell.date,
                                done ? -habit.targetValue : habit.targetValue,
                              );
                            }
                          },
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend({this.accentColor});

  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.hiloColors;
    final ramp = accentColor != null
        ? colors.rampForAccent(accentColor!)
        : colors.heatmapLevels;

    return Row(
      children: [
        Text(
          'Menos',
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
        const SizedBox(width: 6),
        ...ramp.map(
          (c) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          'Más',
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
        const Spacer(),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colors.shield,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'Escudo',
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.hiloColors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: HiloTheme.tabularMetric.copyWith(
                fontSize: 22,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
