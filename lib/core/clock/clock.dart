import 'package:flutter/foundation.dart';

/// Immutable calendar date without time-of-day or timezone offset.
///
/// Stored in SQLite as ISO-8601 `YYYY-MM-DD` to prevent daylight-saving
/// or travel timezone shifts from corrupting habit completion history.
@immutable
final class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime dt) =>
      LocalDate(dt.year, dt.month, dt.day);

  factory LocalDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      throw FormatException('Invalid LocalDate format: $iso');
    }
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = int.parse(parts[2]);
    final normalized = DateTime.utc(y, m, d);
    if (normalized.year != y || normalized.month != m || normalized.day != d) {
      throw FormatException('Invalid calendar date: $iso');
    }
    return LocalDate(y, m, d);
  }

  static LocalDate? tryParse(String iso) {
    try {
      return LocalDate.parse(iso);
    } on FormatException {
      return null;
    }
  }

  final int year;
  final int month;
  final int day;

  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  /// ISO weekday: 1 = Monday ... 7 = Sunday.
  int get weekday => toUtcDateTime().weekday;

  LocalDate addDays(int days) {
    final dt = toUtcDateTime().add(Duration(days: days));
    return LocalDate(dt.year, dt.month, dt.day);
  }

  LocalDate subtractDays(int days) => addDays(-days);

  /// Returns the Monday of the ISO week containing this date.
  LocalDate get startOfWeek => subtractDays(weekday - DateTime.monday);

  /// Signed difference in whole calendar days: `this - other`.
  int differenceInDays(LocalDate other) =>
      toUtcDateTime().difference(other.toUtcDateTime()).inDays;

  String toIsoString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(LocalDate other) => compareTo(other) < 0;
  bool operator <=(LocalDate other) => compareTo(other) <= 0;
  bool operator >(LocalDate other) => compareTo(other) > 0;
  bool operator >=(LocalDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIsoString();
}

/// Injectable clock port for deterministic domain and widget testing.
abstract interface class Clock {
  DateTime now();

  LocalDate today() => LocalDate.fromDateTime(now());
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  LocalDate today() => LocalDate.fromDateTime(DateTime.now());
}
