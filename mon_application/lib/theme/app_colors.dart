import 'package:flutter/material.dart';

/// 🎨 Palette "Premium Grooming & Lifestyle"
abstract final class AppColors {
  // ─── Marque ───
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF0051D5);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFF735C00);

  // ─── Surfaces ───
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);

  // ─── Textes ───
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF45464D);

  // ─── Divers ───
  static const Color outline = Color(0xFF76777D);
  static const Color error = Color(0xFFBA1A1A);

  // ─── Statuts des rendez-vous ───
  static const Color statutConfirme = Color(0xFF1B7F3B);
  static const Color statutEnAttente = Color(0xFFB26A00);
  static const Color statutAnnule = Color(0xFFBA1A1A);
  static const Color statutTermine = Color(0xFF76777D);
}