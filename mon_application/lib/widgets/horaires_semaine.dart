import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/horaires_salon.dart';
import '../theme/app_colors.dart';

const _noms = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

/// 🕘 Fenêtre qui montre les horaires de la semaine et les prochains congés
Future<void> afficherHoraires(BuildContext context, HorairesSalon horaires) {
  final aujourdhui = DateTime.now();
  final cleAujourdhui = HorairesSalon.cleJour(aujourdhui);
  final conges = horaires.conges.where((c) => c.compareTo(cleAujourdhui) >= 0).toList()
    ..sort();

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Horaires d\'ouverture'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 1; j <= 7; j++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _noms[j - 1],
                        style: TextStyle(
                          fontWeight: j == aujourdhui.weekday
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      horaires.semaine[j]?.texte ?? 'Fermé',
                      style: TextStyle(
                        fontWeight: j == aujourdhui.weekday
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: horaires.semaine[j] == null
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            if (conges.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Fermé exceptionnellement',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                conges
                    .take(10)
                    .map((c) => DateFormat('d MMM', 'fr_FR')
                        .format(DateTime.parse(c)))
                    .join(', '),
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Fermer'),
        ),
      ],
    ),
  );
}