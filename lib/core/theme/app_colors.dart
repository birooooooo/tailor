import 'package:flutter/material.dart';

/// A full colour set. Two of them exist: [AppPalette.light] and
/// [AppPalette.dark]. The app swaps the active one when the theme changes.
///
/// Brand blues: Navy `#001D39`, Deep Blue `#0A4174`, Blue `#49769F`,
/// Teal `#4E8EA2`, Muted Teal `#6EA2B3`, Sky `#7BBDE8`, Pale `#BDD8E9`.
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
    primary: Color(0xFF0A4174), // Deep Blue
    primaryDark: Color(0xFF001D39), // Navy
    accent: Color(0xFF7BBDE8), // Sky
    accentSoft: Color(0xFFBDD8E9), // Pale blue
    lime: Color(0xFF6EA2B3), // Muted Teal
    background: Color(0xFFF2F7FB), // Ice
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFDCE9F2),
    border: Color(0xFFC6D9E8),
    textPrimary: Color(0xFF001D39), // Navy
    textSecondary: Color(0xFF49769F),
    textMuted: Color(0xFF7A93A6),
    success: Color(0xFF1E7A54),
    warning: Color(0xFFC08A2E),
    error: Color(0xFFB3402F),
    info: Color(0xFF49769F),
    stagePending: Color(0xFFC08A2E),
    stageAccepted: Color(0xFF49769F),
    stageProducing: Color(0xFF0A4174),
    stageTrial: Color(0xFF6EA2B3),
    stageReady: Color(0xFF1E7A54),
    stageDelivered: Color(0xFF6E7A85),
    stageCancelled: Color(0xFFB3402F),
    brandGradient: [Color(0xFF49769F), Color(0xFF0A4174), Color(0xFF001D39)],
    shadowBase: Color(0xFF0A4174),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF7BBDE8), // Sky (bright for dark)
    primaryDark: Color(0xFF0A4174),
    accent: Color(0xFF6EA2B3), // Muted Teal
    accentSoft: Color(0xFF16324A),
    lime: Color(0xFF7BBDE8),
    background: Color(0xFF07182A), // Deep navy-black
    surface: Color(0xFF0E2A44),
    surfaceMuted: Color(0xFF163A5A),
    border: Color(0xFF1F4A6E),
    textPrimary: Color(0xFFE6F0F8),
    textSecondary: Color(0xFFA9C4D8),
    textMuted: Color(0xFF7C97AC),
    success: Color(0xFF3DBB84),
    warning: Color(0xFFE0A93C),
    error: Color(0xFFE8735F),
    info: Color(0xFF7BBDE8),
    stagePending: Color(0xFFE0A93C),
    stageAccepted: Color(0xFF7BBDE8),
    stageProducing: Color(0xFF4E8EA2),
    stageTrial: Color(0xFF6EA2B3),
    stageReady: Color(0xFF3DBB84),
    stageDelivered: Color(0xFF9AA9B6),
    stageCancelled: Color(0xFFE8735F),
    brandGradient: [Color(0xFF49769F), Color(0xFF0A4174), Color(0xFF001D39)],
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
