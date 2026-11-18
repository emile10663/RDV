import 'package:flutter/material.dart';

/// 🎨 Palette "Premium Grooming & Lifestyle"
/// Source : DESIGN.md — chaque couleur a un RÔLE précis (logique Material 3)
abstract final class AppColors {
  // ─── Marque ───
  static const Color primary = Color(0xFF000000);       // Noir = actions principales
  static const Color onPrimary = Color(0xFFFFFFFF);     // Texte SUR le noir = blanc
  static const Color secondary = Color(0xFF0051D5);     // Bleu = accent (liens, sélection)
  static const Color onSecondary = Color(0xFFFFFFFF);   // Texte SUR le bleu
  static const Color tertiary = Color(0xFF735C00);      // Or = touches premium (badges, étoiles)

  // ─── Surfaces (les "fonds" d'écran et de cartes) ───
  static const Color surface = Color(0xFFF7F9FB);               // Fond principal (blanc cassé)
  static const Color surfaceContainer = Color(0xFFECEEF0);      // Fond des cartes
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);  // Cartes survolées/pressées

  // ─── Textes ───
  static const Color onSurface = Color(0xFF191C1E);        // Texte principal (presque noir)
  static const Color onSurfaceVariant = Color(0xFF45464D); // Texte secondaire (gris)

  // ─── Divers ───
  static const Color outline = Color(0xFF76777D);  // Bordures, séparateurs
  static const Color error = Color(0xFFBA1A1A);    // Erreurs de formulaire
}