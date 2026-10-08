import 'package:flutter/material.dart';

/// Couleur des étoiles (ambre, pour qu'elles se voient bien sur le crème)
const Color couleurEtoile = Color(0xFFE3A21A);

/// ⭐ Affiche une note (de 0 à 5, demi-étoiles possibles)
class Etoiles extends StatelessWidget {
  final double note;
  final double taille;

  const Etoiles({super.key, required this.note, this.taille = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            note >= i + 0.75
                ? Icons.star_rounded
                : note >= i + 0.25
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: taille,
            color: couleurEtoile,
          ),
      ],
    );
  }
}

/// ⭐ Pour choisir une note en touchant les étoiles
class EtoilesChoix extends StatelessWidget {
  final int note;
  final ValueChanged<int> onChanged;

  const EtoilesChoix({super.key, required this.note, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$i sur 5',
            iconSize: 40,
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= note ? Icons.star_rounded : Icons.star_outline_rounded,
              color: couleurEtoile,
            ),
          ),
      ],
    );
  }
}