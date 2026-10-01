import 'package:flutter/material.dart';
import '../models/rendez_vous.dart';
import '../theme/app_colors.dart';

/// 🎨 Texte + couleur de chaque statut, définis UNE seule fois
/// (utilisés par la carte et par l'écran de détail)
extension StatutRdvStyle on StatutRdv {
  String get libelle => switch (this) {
        StatutRdv.confirme => 'Confirmé',
        StatutRdv.enAttente => 'En attente',
        StatutRdv.annule => 'Annulé',
        StatutRdv.termine => 'Terminé',
      };

  Color get couleur => switch (this) {
        StatutRdv.confirme => AppColors.statutConfirme,
        StatutRdv.enAttente => AppColors.statutEnAttente,
        StatutRdv.annule => AppColors.statutAnnule,
        StatutRdv.termine => AppColors.statutTermine,
      };
}