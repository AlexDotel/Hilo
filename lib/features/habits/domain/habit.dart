import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/error/result.dart';

enum HabitType {
  binary,
  quantitative;

  static HabitType fromName(String raw) => switch (raw) {
        'quantitative' => HabitType.quantitative,
        _ => HabitType.binary,
      };
}

enum ScheduleType {
  daily,
  specificDays,
  timesPerWeek;

  static ScheduleType fromName(String raw) => switch (raw) {
        'specific_days' => ScheduleType.specificDays,
        'times_per_week' => ScheduleType.timesPerWeek,
        _ => ScheduleType.daily,
      };

  String toStorageKey() => switch (this) {
        ScheduleType.daily => 'daily',
        ScheduleType.specificDays => 'specific_days',
        ScheduleType.timesPerWeek => 'times_per_week',
      };
}

@immutable
sealed class HabitSchedule {
  const HabitSchedule();

  ScheduleType get type;

  String toConfigJson();

  static HabitSchedule fromStorage(String typeKey, String configJson) {
    final scheduleType = ScheduleType.fromName(typeKey);
    try {
      final decoded = jsonDecode(configJson) as Map<String, dynamic>;
      return switch (scheduleType) {
        ScheduleType.daily => const DailySchedule(),
        ScheduleType.specificDays => SpecificDaysSchedule(
            (decoded['weekdays'] as List<dynamic>? ?? const [1, 2, 3, 4, 5])
                .map((e) => (e as num).toInt())
                .where((d) => d >= 1 && d <= 7)
                .toSet(),
          ),
        ScheduleType.timesPerWeek => TimesPerWeekSchedule(
            ((decoded['times'] as num?)?.toInt() ?? 3).clamp(1, 7),
          ),
      };
    } catch (_) {
      return const DailySchedule();
    }
  }
}

final class DailySchedule extends HabitSchedule {
  const DailySchedule();

  @override
  ScheduleType get type => ScheduleType.daily;

  @override
  String toConfigJson() => '{}';

  @override
  bool operator ==(Object other) => other is DailySchedule;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// ISO weekdays: 1 = Monday .. 7 = Sunday.
final class SpecificDaysSchedule extends HabitSchedule {
  SpecificDaysSchedule(Set<int> weekdays)
      : weekdays = Set.unmodifiable(
          weekdays.where((d) => d >= 1 && d <= 7).isEmpty
              ? const {1, 2, 3, 4, 5}
              : weekdays.where((d) => d >= 1 && d <= 7),
        );

  final Set<int> weekdays;

  @override
  ScheduleType get type => ScheduleType.specificDays;

  @override
  String toConfigJson() {
    final sorted = weekdays.toList()..sort();
    return jsonEncode({'weekdays': sorted});
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecificDaysSchedule && setEquals(weekdays, other.weekdays);

  @override
  int get hashCode => Object.hashAllUnordered(weekdays);
}

final class TimesPerWeekSchedule extends HabitSchedule {
  TimesPerWeekSchedule(int timesPerWeek)
      : timesPerWeek = timesPerWeek.clamp(1, 7);

  final int timesPerWeek;

  @override
  ScheduleType get type => ScheduleType.timesPerWeek;

  @override
  String toConfigJson() => jsonEncode({'times': timesPerWeek});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimesPerWeekSchedule && timesPerWeek == other.timesPerWeek;

  @override
  int get hashCode => timesPerWeek.hashCode;
}

@immutable
final class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.type,
    required this.targetValue,
    required this.schedule,
    required this.allowShields,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    this.unit,
    this.reminderTime,
  });

  final String id;
  final String name;
  final String iconKey;
  final String colorHex;
  final HabitType type;
  final double targetValue;
  final String? unit;
  final HabitSchedule schedule;
  final bool allowShields;
  final String? reminderTime;
  final int sortOrder;
  final bool isArchived;
  final LocalDate createdAt;

  static Result<void, AppFailure> validateDraft({
    required String name,
    required HabitType type,
    required double targetValue,
    required String colorHex,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Failure(
        ValidationFailure('El nombre del hábito no puede estar vacío.'),
      );
    }
    if (trimmed.length > 60) {
      return const Failure(
        ValidationFailure('El nombre no debe superar los 60 caracteres.'),
      );
    }
    if (type == HabitType.quantitative &&
        (targetValue <= 0 || targetValue > 10000)) {
      return const Failure(
        ValidationFailure('La meta diaria debe ser mayor que 0.'),
      );
    }
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(colorHex)) {
      return const Failure(ValidationFailure('Color hexadecimal inválido.'));
    }
    return const Success(null);
  }

  Habit copyWith({
    String? name,
    String? iconKey,
    String? colorHex,
    HabitType? type,
    double? targetValue,
    String? unit,
    HabitSchedule? schedule,
    bool? allowShields,
    String? reminderTime,
    int? sortOrder,
    bool? isArchived,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      schedule: schedule ?? this.schedule,
      allowShields: allowShields ?? this.allowShields,
      reminderTime: reminderTime ?? this.reminderTime,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }
}
