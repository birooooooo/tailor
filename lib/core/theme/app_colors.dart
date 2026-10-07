import 'package:flutter/material.dart';

/// A full colour set. Two of them exist: [AppPalette.light] and
/// [AppPalette.dark]. The app swaps the active one when the theme changes.
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
    primary: Color(0xFF4F46E5),
    primaryDark: Color(0xFF3730A3),
    accent: Color(0xFF8B5CF6),
    accentSoft: Color(0xFFEDE9FE),
    lime: Color(0xFFCBDD3C),
    background: Color(0xFFF6F5FC),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF1EFFB),
    border: Color(0xFFECEAF7),
    textPrimary: Color(0xFF17142B),
    textSecondary: Color(0xFF6B6785),
    textMuted: Color(0xFF9C99B3),
    success: Color(0xFF12B76A),
    warning: Color(0xFFF79009),
    error: Color(0xFFF04438),
    info: Color(0xFF3B82F6),
    stagePending: Color(0xFFF79009),
    stageAccepted: Color(0xFF3B82F6),
    stageProducing: Color(0xFF8B5CF6),
    stageTrial: Color(0xFFEC4899),
    stageReady: Color(0xFF12B76A),
    stageDelivered: Color(0xFF64748B),
    stageCancelled: Color(0xFFF04438),
    brandGradient: [Color(0xFF6D5BFF), Color(0xFF8B5CF6), Color(0xFFA855F7)],
    shadowBase: Color(0xFF4F46E5),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF8B7BFF),
    primaryDark: Color(0xFF5B4BE0),
    accent: Color(0xFFA78BFA),
    accentSoft: Color(0xFF2A2450),
    lime: Color(0xFFCBDD3C),
    background: Color(0xFF0E0C1B),
    surface: Color(0xFF1A1730),
    surfaceMuted: Color(0xFF221E3A),
    border: Color(0xFF2C2750),
    textPrimary: Color(0xFFF6F4FF),
    textSecondary: Color(0xFFB9B3D6),
    textMuted: Color(0xFF807AA3),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFFB7185),
    info: Color(0xFF60A5FA),
    stagePending: Color(0xFFFBBF24),
    stageAccepted: Color(0xFF60A5FA),
    stageProducing: Color(0xFFA78BFA),
    stageTrial: Color(0xFFF472B6),
    stageReady: Color(0xFF34D399),
    stageDelivered: Color(0xFF94A3B8),
    stageCancelled: Color(0xFFFB7185),
    brandGradient: [Color(0xFF7C6BFF), Color(0xFFA855F7), Color(0xFFC084FC)],
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
