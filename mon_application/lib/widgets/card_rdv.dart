import 'package:flutter/material.dart';
import '../models/rendez_vous.dart';
import '../screens/planning/rdv_detail_screen.dart';
import 'statut_rdv_style.dart';

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

  bool get _modifiable =>
      rdv.statut != StatutRdv.termine && rdv.statut != StatutRdv.annule;

  /// Demande confirmation avant d'annuler
  Future<void> _confirmerAnnulation(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler ce rendez-vous ?'),
        content: Text('${rdv.client.nomComplet} — ${rdv.dateFormatee}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirme == true) onAnnule?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final couleur = rdv.statut.couleur;

    return Card(
      color: couleur.withValues(alpha: 0.08),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      // clipBehavior : l'effet au toucher respecte les coins arrondis
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RdvDetailScreen(rdv: rdv),
            ),
          );
        },
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
                      rdv.heureFormatee,
                      style: textTheme.titleMedium!.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      rdv.jourCourt,
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
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rdv.prestation.nom,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                          color: couleur,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rdv.statut.libelle,
                        style: TextStyle(
                          color: couleur,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ─── Menu ⋯ (seulement si le RDV peut encore changer) ───
              if (_modifiable)
                PopupMenuButton<String>(
                  onSelected: (valeur) {
                    if (valeur == 'annuler') _confirmerAnnulation(context);
                    if (valeur == 'terminer') onTermine?.call();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'terminer',
                      child: Text('Marquer terminé'),
                    ),
                    PopupMenuItem(
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