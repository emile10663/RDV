import 'package:flutter/material.dart';

/// 🎨 Palette "Barber premium" : noir profond, or, fond crème
abstract final class AppColors {
  // ─── Marque ───
  static const Color primary = Color(0xFF111111);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF8A6A12); // or foncé (texte lisible)
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFFD4AF37); // or (sur fond sombre)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFF8A6A12);
  static const Color goldSoft = Color(0xFFF6EFD8); // or très pâle

  // ─── Surfaces ───
  static const Color surface = Color(0xFFF5F3EF); // fond crème
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFEFECE6);
  static const Color border = Color(0xFFE7E3DA);

  // ─── Textes ───
  static const Color onSurface = Color(0xFF161616);
  static const Color onSurfaceVariant = Color(0xFF6B6760);

  // ─── Divers ───
  static const Color outline = Color(0xFFB5B0A6);
  static const Color error = Color(0xFFBA1A1A);

  // ─── Statuts des rendez-vous ───
  static const Color statutConfirme = Color(0xFF1E8E4E);
  static const Color statutEnAttente = Color(0xFFC77700);
  static const Color statutAnnule = Color(0xFFBA1A1A);
  static const Color statutTermine = Color(0xFF76777D);

  // ─── Dégradé sombre des en-têtes ───
  static const LinearGradient enTete = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A2A2A), Color(0xFF000000)],
  );
}