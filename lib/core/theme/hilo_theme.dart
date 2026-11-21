import 'package:material_ui/material_ui.dart';

/// Semantic design tokens for Hilo's Warm Minimalism visual system.
@immutable
final class HiloColors extends ThemeExtension<HiloColors> {
  const HiloColors({
    required this.canvas,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentPrimary,
    required this.shield,
    required this.danger,
    required this.heatmapLevels,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentPrimary;
  final Color shield;
  final Color danger;

  /// Exactly 5 colors: level 0 (empty) through level 4 (100%).
  final List<Color> heatmapLevels;

  static const light = HiloColors(
    canvas: Color(0xFFFAF9F6),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF3F1EC),
    border: Color(0xFFECEAE4),
    textPrimary: Color(0xFF1C1917),
    textSecondary: Color(0xFF78716C),
    accentPrimary: Color(0xFF158052),
    shield: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
    heatmapLevels: [
      Color(0xFFECEAE4),
      Color(0xFFC7E8D5),
      Color(0xFF7ED4A8),
      Color(0xFF34B37A),
      Color(0xFF158052),
    ],
  );

  static const dark = HiloColors(
    canvas: Color(0xFF111214),
    surface: Color(0xFF1A1C20),
    surfaceSubtle: Color(0xFF22252B),
    border: Color(0xFF282B32),
    textPrimary: Color(0xFFF5F5F4),
    textSecondary: Color(0xFFA1A1AA),
    accentPrimary: Color(0xFF3CD08B),
    shield: Color(0xFFF59E0B),
    danger: Color(0xFFF87171),
    heatmapLevels: [
      Color(0xFF24272E),
      Color(0xFF193D2D),
      Color(0xFF216646),
      Color(0xFF2B9462),
      Color(0xFF3CD08B),
    ],
  );

  /// Generates a 5-step intensity ramp for any custom habit accent color.
  List<Color> rampForAccent(Color accent) {
    final base = heatmapLevels[0];
    return [
      base,
      Color.lerp(base, accent, 0.30)!,
      Color.lerp(base, accent, 0.55)!,
      Color.lerp(base, accent, 0.78)!,
      accent,
    ];
  }

  @override
  HiloColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceSubtle,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? accentPrimary,
    Color? shield,
    Color? danger,
    List<Color>? heatmapLevels,
  }) {
    return HiloColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      shield: shield ?? this.shield,
      danger: danger ?? this.danger,
      heatmapLevels: heatmapLevels ?? this.heatmapLevels,
    );
  }

  @override
  HiloColors lerp(ThemeExtension<HiloColors>? other, double t) {
    if (other is! HiloColors) return this;
    return HiloColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      shield: Color.lerp(shield, other.shield, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      heatmapLevels: List<Color>.generate(
        5,
        (i) => Color.lerp(heatmapLevels[i], other.heatmapLevels[i], t)!,
      ),
    );
  }
}

/// Curated habit accent colors harmonious with both Light and Dark themes.
abstract final class HiloHabitPalette {
  static const List<String> hexColors = [
    '#158052', // Esmeralda Hilo
    '#E06D53', // Terracota
    '#6366F1', // Índigo
    '#0EA5E9', // Cian
    '#A855F7', // Ciruela
    '#D97706', // Ámbar
  ];

  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF158052);
    return Color(0xFF000000 | value);
  }
}

abstract final class HiloTheme {
  static const String displayFont = 'PlusJakartaSans';
  static const String bodyFont = 'Inter';

  static const TextStyle tabularMetric = TextStyle(
    fontFamily: displayFont,
    fontFeatures: [FontFeature.tabularFigures()],
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );

  static ThemeData light() => _build(Brightness.light, HiloColors.light);

  static ThemeData dark() => _build(Brightness.dark, HiloColors.dark);

  static ThemeData _build(Brightness brightness, HiloColors colors) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.accentPrimary,
      onPrimary: isDark ? const Color(0xFF0A1F14) : Colors.white,
      secondary: colors.shield,
      onSecondary: Colors.white,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      outline: colors.border,
      outlineVariant: colors.border,
    );

    final baseTextTheme = ThemeData(brightness: brightness).textTheme.apply(
          fontFamily: bodyFont,
          bodyColor: colors.textPrimary,
          displayColor: colors.textPrimary,
        );

    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(fontFamily: displayFont),
      displayMedium: baseTextTheme.displayMedium?.copyWith(fontFamily: displayFont),
      displaySmall: baseTextTheme.displaySmall?.copyWith(fontFamily: displayFont),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: displayFont,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: displayFont,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: displayFont,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: displayFont,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: displayFont,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: bodyFont,
      textTheme: textTheme,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.canvas,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFont,
          color: colors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.accentPrimary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? colors.accentPrimary : colors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.accentPrimary : colors.textSecondary,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accentPrimary,
        foregroundColor: isDark ? const Color(0xFF0A1F14) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accentPrimary, width: 1.5),
        ),
      ),
      dividerColor: colors.border,
    );
  }
}

extension HiloColorsContext on BuildContext {
  HiloColors get hiloColors =>
      Theme.of(this).extension<HiloColors>() ?? HiloColors.light;
}
