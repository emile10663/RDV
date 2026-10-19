import 'package:flutter/material.dart';

/// 🎨 Palette "Fresh & Clean" – Blanc lumineux, Bleu marine, Corail + Dark Mode
abstract final class AppColors {
  // ─── Light Mode ───
  static const Color primary = Color(0xFF1E3A8A);     // Bleu marine
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF0EA5E9);   // Bleu ciel
  static const Color onSecondary = Color(0xFF0F172A);
  static const Color accent = Color(0xFFF97316);      // Corail (accent principal)
  static const Color gold = Color(0xFFFB923C);        // Orange doux

  // ─── Surfaces Light ───
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // ─── Textes Light ───
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  // ─── Divers ───
  static const Color outline = Color(0xFFCBD5E1);
  static const Color error = Color(0xFFEF4444);

  // ─── Statuts ───
  static const Color statutConfirme = Color(0xFF10B981);
  static const Color statutEnAttente = Color(0xFFF97316);
  static const Color statutAnnule = Color(0xFFEF4444);
  static const Color statutTermine = Color(0xFF6B7280);

  // ─── Dark Mode ───
  static const Color darkPrimary = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E2937);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkOnSurface = Color(0xFFF1F5F9);
  static const Color darkOnSurfaceVariant = Color(0xFFCBD5E1);

  // ─── Dégradé en-têtes ───
  static const LinearGradient enTete = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
  );
}