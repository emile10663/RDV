import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// 📆 Petite pastille verticale : "jeu." + "1" (+ point si des RDV ce jour-là)
class PuceJour extends StatelessWidget {
  final DateTime jour;
  final bool selected;
  final bool pastille;
  final VoidCallback onTap;

  const PuceJour({
    super.key,
    required this.jour,
    required this.selected,
    required this.onTap,
    this.pastille = false,
  });

  /// Largeur + espace : utile pour positionner le défilement
  static const double largeur = 56;
  static const double espace = 10;

  @override
  Widget build(BuildContext context) {
    final jourSemaine =
        DateFormat('E', 'fr_FR').format(jour).replaceAll('.', '');
    final texte = selected ? Colors.white : AppColors.onSurface;
    final discret = selected ? Colors.white70 : AppColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: largeur,
        margin: const EdgeInsets.only(right: espace),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(jourSemaine, style: TextStyle(fontSize: 12, color: discret)),
            const SizedBox(height: 4),
            Text(
              '${jour.day}',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: texte,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pastille
                    ? (selected ? AppColors.gold : AppColors.goldDark)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}