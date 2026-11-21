import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hilo/core/error/result.dart';

/// Privacy-minimized snapshot projected to Android Home Screen widgets.
///
/// Security invariant: NEVER contains private user notes or full history.
@immutable
final class WidgetHabitItem {
  const WidgetHabitItem({
    required this.id,
    required this.title,
    required this.isCompletedToday,
    required this.isQuantitative,
    required this.progressLabel,
    required this.weeklySummary,
    required this.currentStreak,
    required this.colorHex,
    required this.compactHeatmapLevels,
  });

  final String id;
  final String title;
  final bool isCompletedToday;
  final bool isQuantitative;
  final String progressLabel;
  final String weeklySummary;
  final int currentStreak;
  final String colorHex;

  /// 35-day (5-week) intensity levels [0..4] for the 2x2 single-habit widget.
  final List<int> compactHeatmapLevels;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': isCompletedToday,
        'quant': isQuantitative,
        'progress': progressLabel,
        'weekly': weeklySummary,
        'streak': currentStreak,
        'color': colorHex,
        'miniGrid': compactHeatmapLevels,
      };
}

@immutable
final class WidgetSnapshot {
  const WidgetSnapshot({
    required this.dateIso,
    required this.globalStreak,
    required this.availableShields,
    required this.consistency30Days,
    required this.completedToday,
    required this.totalToday,
    required this.heatmapLevels,
    required this.todayHabits,
    required this.privacyMode,
  });

  final String dateIso;
  final int globalStreak;
  final int availableShields;
  final int consistency30Days;
  final int completedToday;
  final int totalToday;

  /// 112-day (16-week) intensity levels [0..4] in column-major order for Android Canvas.
  final List<int> heatmapLevels;

  /// Up to 3 highlighted habits for quick check-in directly from the Home Screen.
  final List<WidgetHabitItem> todayHabits;

  final bool privacyMode;

  String toJsonString() => jsonEncode({
        'date': dateIso,
        'streak': globalStreak,
        'shields': availableShields,
        'consistency': consistency30Days,
        'completedToday': completedToday,
        'totalToday': totalToday,
        'privacy': privacyMode,
        'heatmap': heatmapLevels,
        'habits': todayHabits.map((h) => h.toJson()).toList(),
      });
}

enum WidgetActionType { toggleHabit, incrementHabit }

@immutable
final class ValidatedWidgetAction {
  const ValidatedWidgetAction({
    required this.type,
    required this.habitId,
  });

  final WidgetActionType type;
  final String habitId;
}

/// Validates URIs sent from Android Home Screen widget PendingIntents
/// to prevent spoofed actions or malformed IDs.
abstract final class WidgetActionValidator {
  static const String allowedScheme = 'hilo';
  static const String allowedHost = 'widget';
  static final RegExp _uuidV4Pattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static Result<ValidatedWidgetAction, AppFailure> parseUri(Uri? uri) {
    if (uri == null) {
      return const Failure(ValidationFailure('URI de acción vacía.'));
    }
    if (uri.scheme != allowedScheme || uri.host != allowedHost) {
      return const Failure(
        SecurityFailure('Origen de intención de widget no autorizado.'),
      );
    }

    final action = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    final habitId = uri.queryParameters['id'] ?? '';

    if (!_uuidV4Pattern.hasMatch(habitId)) {
      return const Failure(
        SecurityFailure('Identificador de hábito inválido en acción de widget.'),
      );
    }

    return switch (action) {
      'toggle' => Success(
          ValidatedWidgetAction(
            type: WidgetActionType.toggleHabit,
            habitId: habitId,
          ),
        ),
      'increment' => Success(
          ValidatedWidgetAction(
            type: WidgetActionType.incrementHabit,
            habitId: habitId,
          ),
        ),
      _ => const Failure(
          SecurityFailure('Acción de widget no permitida.'),
        ),
    };
  }
}

/// Hexagonal Port decoupling domain sync from the `home_widget` plugin.
abstract interface class WidgetBridgePort {
  Future<Result<void, AppFailure>> pushSnapshot(WidgetSnapshot snapshot);
}
