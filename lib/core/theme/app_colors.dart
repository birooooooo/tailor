import 'package:flutter/material.dart';

/// Central color palette for the tailor app.
/// Elegant "atelier" feel: deep charcoal/navy + muted gold accent.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF14213D); // Deep navy
  static const Color primaryDark = Color(0xFF0B132B);
  static const Color accent = Color(0xFFC8A24A); // Muted gold
  static const Color accentSoft = Color(0xFFE9D9AE);

  // Surfaces (light)
  static const Color background = Color(0xFFFBF9F4); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1EDE4);
  static const Color border = Color(0xFFE3DED2);

  // Text
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF5A5A66);
  static const Color textMuted = Color(0xFF9A9AA5);

  // Status
  static const Color success = Color(0xFF2E7D4F);
  static const Color warning = Color(0xFFB7791F);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF2A6FDB);

  // Order stage colors
  static const Color stagePending = Color(0xFFB7791F);
  static const Color stageAccepted = Color(0xFF2A6FDB);
  static const Color stageProducing = Color(0xFF7A4FBF);
  static const Color stageTrial = Color(0xFFC8A24A);
  static const Color stageReady = Color(0xFF2E7D4F);
  static const Color stageDelivered = Color(0xFF4B5563);
  static const Color stageCancelled = Color(0xFFC0392B);
}
