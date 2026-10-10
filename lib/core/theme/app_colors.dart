import 'package:flutter/material.dart';

/// A full colour set. Two of them exist: [AppPalette.light] and
/// [AppPalette.dark]. The app swaps the active one when the theme changes.
///
/// Brand: Emerald `#0F5B4C` (main), Forest Green `#1E4738`,
/// Cream `#F5F0E6`, Warm Sand `#D9CDBA`, Gold `#C9A84C`.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.accentSoft,
    required this.lime,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.stagePending,
    required this.stageAccepted,
    required this.stageProducing,
    required this.stageTrial,
    required this.stageReady,
    required this.stageDelivered,
    required this.stageCancelled,
    required this.brandGradient,
    required this.shadowBase,
  });

  final Brightness brightness;
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color accentSoft;
  final Color lime;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color stagePending;
  final Color stageAccepted;
  final Color stageProducing;
  final Color stageTrial;
  final Color stageReady;
  final Color stageDelivered;
  final Color stageCancelled;
  final List<Color> brandGradient;
  final Color shadowBase;

  bool get isDark => brightness == Brightness.dark;

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF0F5B4C), // Emerald
    primaryDark: Color(0xFF1E4738), // Forest Green
    accent: Color(0xFFC9A84C), // Gold
    accentSoft: Color(0xFFE7DCC5), // Sand tint
    lime: Color(0xFFC9A84C), // Gold
    background: Color(0xFFF5F0E6), // Cream
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEFE8D9), // Warm Sand tint
    border: Color(0xFFE3D9C6),
    textPrimary: Color(0xFF1A1F1B),
    textSecondary: Color(0xFF5A655D),
    textMuted: Color(0xFF8A9188),
    success: Color(0xFF1E7A54),
    warning: Color(0xFFC08A2E),
    error: Color(0xFFB3402F),
    info: Color(0xFF2F6F8F),
    stagePending: Color(0xFFC08A2E),
    stageAccepted: Color(0xFF2F6F8F),
    stageProducing: Color(0xFF0F5B4C),
    stageTrial: Color(0xFFC9A84C),
    stageReady: Color(0xFF1E7A54),
    stageDelivered: Color(0xFF6E6A60),
    stageCancelled: Color(0xFFB3402F),
    brandGradient: [Color(0xFF1E7A5F), Color(0xFF0F5B4C), Color(0xFF1E4738)],
    shadowBase: Color(0xFF0F5B4C),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF2E9E7C), // Emerald (brighter for dark)
    primaryDark: Color(0xFF14634F),
    accent: Color(0xFFD9B85C), // Gold
    accentSoft: Color(0xFF1E3A31),
    lime: Color(0xFFC9A84C),
    background: Color(0xFF0A1512), // Deep forest-black
    surface: Color(0xFF13231D),
    surfaceMuted: Color(0xFF1B3028),
    border: Color(0xFF254237),
    textPrimary: Color(0xFFF5F0E6), // Cream
    textSecondary: Color(0xFFC7BFAE), // Warm Sand
    textMuted: Color(0xFF8FA096),
    success: Color(0xFF3DBB84),
    warning: Color(0xFFE0A93C),
    error: Color(0xFFE8735F),
    info: Color(0xFF5FA8C9),
    stagePending: Color(0xFFE0A93C),
    stageAccepted: Color(0xFF5FA8C9),
    stageProducing: Color(0xFF2E9E7C),
    stageTrial: Color(0xFFD9B85C),
    stageReady: Color(0xFF3DBB84),
    stageDelivered: Color(0xFF9AA39C),
    stageCancelled: Color(0xFFE8735F),
    brandGradient: [Color(0xFF2E9E7C), Color(0xFF14634F), Color(0xFF0F4738)],
    shadowBase: Color(0xFF000000),
  );
}

/// Global colour accessor. Widgets keep using `AppColors.surface` etc., and
/// the values change automatically when the theme toggles.
class AppColors {
  AppColors._();

  static AppPalette palette = AppPalette.light;

  static bool get isDark => palette.isDark;

  static Color get primary => palette.primary;
  static Color get primaryDark => palette.primaryDark;
  static Color get accent => palette.accent;
  static Color get accentSoft => palette.accentSoft;
  static Color get lime => palette.lime;

  static Color get background => palette.background;
  static Color get surface => palette.surface;
  static Color get surfaceMuted => palette.surfaceMuted;
  static Color get border => palette.border;

  static Color get textPrimary => palette.textPrimary;
  static Color get textSecondary => palette.textSecondary;
  static Color get textMuted => palette.textMuted;

  static Color get success => palette.success;
  static Color get warning => palette.warning;
  static Color get error => palette.error;
  static Color get info => palette.info;

  static Color get stagePending => palette.stagePending;
  static Color get stageAccepted => palette.stageAccepted;
  static Color get stageProducing => palette.stageProducing;
  static Color get stageTrial => palette.stageTrial;
  static Color get stageReady => palette.stageReady;
  static Color get stageDelivered => palette.stageDelivered;
  static Color get stageCancelled => palette.stageCancelled;

  static List<Color> get brandGradient => palette.brandGradient;

  static LinearGradient get brand => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: palette.brandGradient,
  );

  static List<BoxShadow> shadow({Color? color, double opacity = 0.10}) => [
    BoxShadow(
      color: (color ?? palette.shadowBase).withValues(alpha: opacity),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get softShadow => shadow(opacity: 0.05);

  static const double rSm = 14;
  static const double rMd = 22;
  static const double rLg = 28;
}
