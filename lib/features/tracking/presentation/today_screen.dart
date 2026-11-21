import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/di/providers.dart';
import 'package:hilo/core/theme/hilo_theme.dart';
import 'package:hilo/features/habits/domain/habit.dart';
import 'package:hilo/features/habits/presentation/habit_icons.dart';
import 'package:hilo/features/tracking/domain/habit_log.dart';
import 'package:hilo/features/tracking/domain/schedule_strategy.dart';
import 'package:hilo/features/tracking/domain/streak_engine.dart';
import 'package:intl/intl.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.onCreateHabit,
  });

  final VoidCallback onCreateHabit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.hiloColors;
    final today = ref.watch(clockProvider).today();
    final habitsAsync = ref.watch(activeHabitsProvider);
    final logsAsync = ref.watch(yearLogsProvider);
    final streakEngine = ref.watch(streakEngineProvider);

    final formattedDate = _formatSpanishHeader(today);

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar hábitos: $err')),
        data: (habits) {
          final logs = logsAsync.asData?.value ?? const <HabitLog>[];
          final todayLogs = <String, HabitLog>{
            for (final log in logs)
              if (log.date == today) log.habitId: log,
          };

          if (habits.isEmpty) {
            return _EmptyTodayView(onCreateHabit: onCreateHabit);
          }

          final scheduledHabits = habits.where((h) {
            final strategy = ScheduleStrategy.forSchedule(h.schedule);
            return strategy.isScheduledOn(today);
          }).toList();

          final completedCount = scheduledHabits
              .where((h) => todayLogs[h.id]?.isCompleted == true)
              .length;
          final totalCount = scheduledHabits.length;

          final globalStreak = streakEngine.evaluateGlobal(
            activeHabits: habits,
            logs: logs,
            today: today,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              _DailyProgressHeader(
                completed: completedCount,
                total: totalCount,
                streakSummary: globalStreak,
              ),
              const SizedBox(height: 20),
              Text(
                'TUS HÁBITOS DE HOY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              ...habits.map((habit) {
                final log = todayLogs[habit.id];
                final habitStreak = streakEngine.evaluateHabit(
                  habit: habit,
                  logs: logs,
                  today: today,
                );
                final isScheduled =
                    ScheduleStrategy.forSchedule(habit.schedule)
                        .isScheduledOn(today);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HabitCheckInCard(
                    habit: habit,
                    log: log,
                    streak: habitStreak,
                    isScheduledToday: isScheduled,
                    date: today,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  static String _formatSpanishHeader(LocalDate date) {
    final raw = DateFormat('EEEE d MMM', 'es').format(date.toUtcDateTime());
    if (raw.isEmpty) return 'Hoy';
    return 'Hoy · ${raw[0].toUpperCase()}${raw.substring(1)}';
  }
}

class _DailyProgressHeader extends StatelessWidget {
  const _DailyProgressHeader({
    required this.completed,
    required this.total,
    required this.streakSummary,
  });

  final int completed;
  final int total;
  final StreakSummary streakSummary;

  @override
  Widget build(BuildContext context) {
    final colors = context.hiloColors;
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              width: 112,
              height: 112,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: colors.border,
                      valueColor: AlwaysStoppedAnimation(colors.accentPrimary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$completed/$total',
                        style: HiloTheme.tabularMetric.copyWith(
                          fontSize: 28,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        progress >= 1.0 && total > 0 ? '¡Completo!' : 'Hoy',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 18,
                    color: colors.accentPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${streakSummary.currentStreak} días',
                    style: HiloTheme.tabularMetric.copyWith(
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '·',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: colors.shield,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${streakSummary.availableShields} escudos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCheckInCard extends ConsumerWidget {
  const _HabitCheckInCard({
    required this.habit,
    required this.log,
    required this.streak,
    required this.isScheduledToday,
    required this.date,
  });

  final Habit habit;
  final HabitLog? log;
  final StreakSummary streak;
  final bool isScheduledToday;
  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.hiloColors;
    final accent = HiloHabitPalette.fromHex(habit.colorHex);
    final isCompleted = log?.isCompleted == true;
    final isRestDay = log?.isRestDay == true;
    final controller = ref.read(trackingControllerProvider);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          HapticFeedback.lightImpact();
          if (habit.type == HabitType.binary) {
            await controller.toggleBinaryHabit(habit, date);
          } else {
            await controller.adjustQuantitativeHabit(habit, date, 1);
          }
        },
        onLongPress: () => _showQuickOptions(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? accent
                      : isRestDay
                          ? colors.shield.withValues(alpha: 0.16)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? accent
                        : isRestDay
                            ? colors.shield
                            : colors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : isRestDay
                          ? Icons.pause_rounded
                          : HiloHabitIcons.resolve(habit.iconKey),
                  size: 18,
                  color: isCompleted
                      ? Colors.white
                      : isRestDay
                          ? colors.shield
                          : colors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        decoration: isRestDay ? TextDecoration.none : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleText(isRestDay),
                      style: TextStyle(
                        fontSize: 12,
                        color: isRestDay ? colors.shield : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (habit.type == HabitType.quantitative) ...[
                IconButton(
                  tooltip: 'Restar 1',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    controller.adjustQuantitativeHabit(habit, date, -1);
                  },
                  icon: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  '${(log?.value ?? 0).toStringAsFixed(0)}/${habit.targetValue.toStringAsFixed(0)}',
                  style: HiloTheme.tabularMetric.copyWith(
                    fontSize: 14,
                    color: isCompleted ? accent : colors.textPrimary,
                  ),
                ),
                IconButton(
                  tooltip: 'Sumar 1',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.adjustQuantitativeHabit(habit, date, 1);
                  },
                  icon: Icon(
                    Icons.add_circle_rounded,
                    color: accent,
                  ),
                ),
              ] else ...[
                IconButton(
                  tooltip: 'Opciones del día',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showQuickOptions(context, ref),
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleText(bool isRestDay) {
    if (isRestDay) return 'Día de descanso · Racha protegida';
    if (!isScheduledToday) return 'Día libre · Opcional hoy';
    final parts = <String>[
      'Racha ${streak.currentStreak}d',
      if (habit.schedule is TimesPerWeekSchedule)
        '${streak.completedThisWeek}/${streak.weeklyTarget} esta semana',
      if (habit.unit != null && habit.unit!.isNotEmpty) habit.unit!,
    ];
    return parts.join(' · ');
  }

  void _showQuickOptions(BuildContext context, WidgetRef ref) {
    final controller = ref.read(trackingControllerProvider);
    final noteController = TextEditingController(text: log?.note ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                habit.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.pause_circle_outline_rounded),
                title: Text(
                  log?.isRestDay == true
                      ? 'Quitar día de descanso'
                      : 'Marcar como día de descanso',
                ),
                subtitle: const Text(
                  'Congela tu racha hoy sin penalizar tu consistencia.',
                ),
                onTap: () async {
                  await controller.toggleRestDay(habit, date);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Nota privada del día (cifrada en tu dispositivo)',
                  hintText: 'Ej. Entrené suave después del trabajo...',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  await controller.updateNote(habit, date, noteController.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Guardar nota'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyTodayView extends StatelessWidget {
  const _EmptyTodayView({required this.onCreateHabit});

  final VoidCallback onCreateHabit;

  @override
  Widget build(BuildContext context) {
    final colors = context.hiloColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.accentPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 34,
                color: colors.accentPrimary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Empieza tu primer hilo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea un hábito diario o semanal flexible. Cada día completado iluminará tu mapa de calor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreateHabit,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear mi primer hábito'),
            ),
          ],
        ),
      ),
    );
  }
}
