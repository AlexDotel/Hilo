import 'package:flutter/foundation.dart';
import 'package:hilo/core/clock/clock.dart';
import 'package:hilo/core/error/result.dart';

enum LogStatus {
  completed,
  partial,
  restDay,
  shieldUsed;

  static LogStatus fromName(String raw) => switch (raw) {
        'completed' => LogStatus.completed,
        'partial' => LogStatus.partial,
        'rest_day' => LogStatus.restDay,
        'shield_used' => LogStatus.shieldUsed,
        _ => LogStatus.partial,
      };

  String toStorageKey() => switch (this) {
        LogStatus.completed => 'completed',
        LogStatus.partial => 'partial',
        LogStatus.restDay => 'rest_day',
        LogStatus.shieldUsed => 'shield_used',
      };
}

@immutable
final class HabitLog {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    required this.value,
    required this.updatedAtEpochMs,
    this.note,
  });

  final String id;
  final String habitId;
  final LocalDate date;
  final LogStatus status;
  final double value;
  final String? note;
  final int updatedAtEpochMs;

  bool get isCompleted => status == LogStatus.completed;
  bool get isRestDay => status == LogStatus.restDay;
  bool get isShieldUsed => status == LogStatus.shieldUsed;

  HabitLog copyWith({
    LogStatus? status,
    double? value,
    String? note,
    int? updatedAtEpochMs,
  }) {
    return HabitLog(
      id: id,
      habitId: habitId,
      date: date,
      status: status ?? this.status,
      value: value ?? this.value,
      note: note ?? this.note,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
    );
  }
}

/// Repository port for habit completion logs.
abstract interface class LogRepository {
  Stream<List<HabitLog>> watchLogsInRange(LocalDate from, LocalDate to);

  Future<List<HabitLog>> getLogsInRange(LocalDate from, LocalDate to);

  Future<List<HabitLog>> getAllLogs();

  Future<HabitLog?> getLogForHabitOnDate(String habitId, LocalDate date);

  Future<Result<HabitLog, AppFailure>> upsertLog(HabitLog log);

  Future<Result<void, AppFailure>> deleteLog(String habitId, LocalDate date);
}
