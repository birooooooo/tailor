import 'package:flutter/material.dart';

/// "Vibrant Bento" palette: indigo → violet, lime accent, soft lilac surfaces.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color accent = Color(0xFF8B5CF6); // Violet
  static const Color accentSoft = Color(0xFFEDE9FE);
  static const Color lime = Color(0xFFCBDD3C); // Punch accent

  // Surfaces
  static const Color background = Color(0xFFF6F5FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1EFFB);
  static const Color border = Color(0xFFECEAF7);

  // Text
  static const Color textPrimary = Color(0xFF17142B);
  static const Color textSecondary = Color(0xFF6B6785);
  static const Color textMuted = Color(0xFF9C99B3);

  // Status
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFF04438);
  static const Color info = Color(0xFF3B82F6);

  // Order stage colors
  static const Color stagePending = Color(0xFFF79009);
  static const Color stageAccepted = Color(0xFF3B82F6);
  static const Color stageProducing = Color(0xFF8B5CF6);
  static const Color stageTrial = Color(0xFFEC4899);
  static const Color stageReady = Color(0xFF12B76A);
  static const Color stageDelivered = Color(0xFF64748B);
  static const Color stageCancelled = Color(0xFFF04438);

  // Gradients
  static const List<Color> brandGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
  ];
  static const List<Color> darkGradient = [
    Color(0xFF312E81),
    Color(0xFF4F46E5),
  ];
  static const List<Color> limeGradient = [
    Color(0xFFD9F24F),
    Color(0xFF9FE870),
  ];

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: brandGradient,
  );

  // Soft, colour-tinted shadows. Kept light on purpose: big blurs are the
  // most expensive thing to repaint on low-end phones.
  static List<BoxShadow> shadow({Color? color, double opacity = 0.10}) => [
        BoxShadow(
          color: (color ?? primary).withValues(alpha: opacity),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get softShadow => shadow(opacity: 0.05);

  // Radii
  static const double rSm = 14;
  static const double rMd = 22;
  static const double rLg = 28;
}
