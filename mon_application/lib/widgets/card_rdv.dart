import 'package:flutter/material.dart';
import '../models/rendez_vous.dart';
import '../screens/planning/rdv_detail_screen.dart';

/// 🗓️ Carte affichant un rendez-vous (réutilisable partout)
class CardRdv extends StatelessWidget {
  final RendezVous rdv;
  final VoidCallback? onAnnule;
  final VoidCallback? onTermine;

  const CardRdv({
    super.key,
    required this.rdv,
    this.onAnnule,
    this.onTermine,
  });

  /// Renvoie la couleur du statut (rond + texte)
  Color _couleurStatut(StatutRdv statut) {
    switch (statut) {
      case StatutRdv.confirme:
        return Colors.green;
      case StatutRdv.enAttente:
        return Colors.orange;
      case StatutRdv.annule:
        return Colors.red;
      case StatutRdv.termine:
        return Colors.grey;
    }
  }

  /// Renvoie le texte du statut
  String _texteStatut(StatutRdv statut) {
    switch (statut) {
      case StatutRdv.confirme:
        return 'Confirmé';
      case StatutRdv.enAttente:
        return 'En attente';
      case StatutRdv.annule:
        return 'Annulé';
      case StatutRdv.termine:
        return 'Terminé';
    }
  }

  /// Renvoie la couleur de FOND de la carte (très pâle)
  Color _fondStatut(StatutRdv statut) {
    switch (statut) {
      case StatutRdv.confirme:
        return Colors.green.withValues(alpha: 0.08);
      case StatutRdv.enAttente:
        return Colors.orange.withValues(alpha: 0.08);
      case StatutRdv.annule:
        return Colors.red.withValues(alpha: 0.08);
      case StatutRdv.termine:
        return Colors.grey.withValues(alpha: 0.08);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RdvDetailScreen(rdv: rdv),
          ),
        );
      },
      child: Card(
        color: _fondStatut(rdv.statut),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ─── Bloc HEURE à gauche ───
              Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${rdv.dateHeure.hour.toString().padLeft(2, '0')}:${rdv.dateHeure.minute.toString().padLeft(2, '0')}',
                      style: textTheme.titleMedium!.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${rdv.dateHeure.day}/${rdv.dateHeure.month}',
                      style: textTheme.bodySmall!.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // ─── Infos au centre ───
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rdv.client.nomComplet,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rdv.prestation.nom,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── PRIX + STATUT à droite ───
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${rdv.prestation.prix.toStringAsFixed(2)} €',
                    style: textTheme.titleMedium!.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _couleurStatut(rdv.statut),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _texteStatut(rdv.statut),
                        style: TextStyle(
                          color: _couleurStatut(rdv.statut),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),


                            
                           // ─── Menu ⋯ tout à droite ───
              PopupMenuButton<String>(
                onSelected: (valeur) {
                  if (valeur == 'annuler') onAnnule?.call();
                  if (valeur == 'terminer') onTermine?.call();
                },
                itemBuilder: (context) => [
                  // 👇 ICI : cette ligne conditionnelle
                  if (rdv.statut != StatutRdv.termine &&
                      rdv.statut != StatutRdv.annule)
                    const PopupMenuItem(
                      value: 'terminer',
                      child: Text('Marquer terminé'),
                    ),
                  const PopupMenuItem(
                    value: 'annuler',
                    child: Text('Annuler le RDV'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}