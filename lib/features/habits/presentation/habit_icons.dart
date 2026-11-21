import 'package:material_ui/material_ui.dart';

abstract final class HiloHabitIcons {
  static const Map<String, IconData> registry = {
    'check': Icons.check_circle_outline_rounded,
    'book': Icons.menu_book_rounded,
    'fitness': Icons.fitness_center_rounded,
    'meditation': Icons.self_improvement_rounded,
    'water': Icons.water_drop_rounded,
    'sleep': Icons.bedtime_rounded,
    'walk': Icons.directions_walk_rounded,
    'code': Icons.code_rounded,
    'leaf': Icons.eco_rounded,
    'music': Icons.music_note_rounded,
    'write': Icons.edit_note_rounded,
    'no_phone': Icons.phonelink_off_rounded,
  };

  static IconData resolve(String key) =>
      registry[key] ?? Icons.check_circle_outline_rounded;
}
