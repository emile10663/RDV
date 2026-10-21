import 'package:flutter/material.dart';

/// 🎨 Palette "Barber premium" : noir profond, or, fond crème.
/// Les noms des couleurs sont ceux du projet actuel (primary, accent, secondary…),
/// donc tous les écrans changent de couleur sans être modifiés.
abstract final class AppColors {
  // ─── Marque ───
  static const Color primary = Color(0xFF111111); // noir profond (boutons, titres)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFF6EFD8); // or très pâle (pastilles, fonds d'icônes)
  static const Color onSecondary = Color(0xFF111111);
  static const Color accent = Color(0xFFD4AF37); // or (accent principal)
  static const Color gold = Color(0xFFD4AF37);

  // ─── Surfaces ───
  static const Color surface = Color(0xFFF5F3EF); // fond crème
  static const Color card = Color(0xFFFFFFFF);
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

  // ─── Mode sombre (pas activé pour l'instant) ───
  static const Color darkPrimary = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkCard = Color(0xFF222222);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkOnSurface = Color(0xFFF5F3EF);
  static const Color darkOnSurfaceVariant = Color(0xFFB5B0A6);

  // ─── Dégradé sombre des en-têtes ───
  static const LinearGradient enTete = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A2A2A), Color(0xFF000000)],
  );
}