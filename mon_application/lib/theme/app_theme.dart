import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🖌️ Thème global de l'application
/// Regroupe couleurs + polices + styles des composants (boutons, cartes...)
abstract final class AppTheme {
  static ThemeData get light {
    // 1️⃣ Schéma de couleurs Material 3
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      outline: AppColors.outline,
    );

    // 2️⃣ Polices : Inter pour le texte courant, Montserrat pour les titres
    final baseTextTheme = GoogleFonts.interTextTheme();
    final montserrat = GoogleFonts.montserratTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,

      // Texte : Inter par défaut, Montserrat pour les titres
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.onSurfaceVariant,
        displayColor: AppColors.onSurface,
      ).copyWith(
        headlineLarge: montserrat.headlineLarge,
        headlineMedium: montserrat.headlineMedium,
        titleLarge: montserrat.titleLarge,
        titleMedium: montserrat.titleMedium,
      ),

      // 3️⃣ Style de la barre du haut (AppBar)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),

      // 4️⃣ Style des boutons — noir plein, coins arrondis (le look "premium")
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(52), // largeur pleine, hauteur 52
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 5️⃣ Style des cartes (les RDV, les prestations...)
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 6️⃣ Style des champs de texte (formulaires de réservation)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}