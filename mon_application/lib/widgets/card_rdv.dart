import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/rendez_vous.dart';
import '../screens/planning/rdv_detail_screen.dart';
import '../theme/app_colors.dart';
import 'statut_rdv_style.dart';

/// 🗓️ Carte d'un rendez-vous : bandeau de couleur = statut
class CardRdv extends StatelessWidget {
  final RendezVous rdv;
  final VoidCallback? onConfirme;
  final VoidCallback? onAnnule;
  final VoidCallback? onTermine;

  const CardRdv({
    super.key,
    required this.rdv,
    this.onConfirme,
    this.onAnnule,
    this.onTermine,
  });

  bool get _modifiable =>
      rdv.statut != StatutRdv.termine && rdv.statut != StatutRdv.annule;

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
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirme == true) onAnnule?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final couleur = rdv.statut.couleur;
    final annule = rdv.statut == StatutRdv.annule;
    final heureFin = DateFormat('HH:mm').format(rdv.fin);
    final prix = rdv.prestation.prix.toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RdvDetailScreen(rdv: rdv),
                ),
              );
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Bandeau de statut ───
                  Container(width: 6, color: couleur),

                  // ─── Heure ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rdv.heureFormatee,
                          style: textTheme.titleLarge!.copyWith(fontSize: 19),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          heureFin,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Container(width: 1, color: AppColors.border),
                  ),

                  // ─── Client + prestation + statut ───
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            rdv.client.nomComplet,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: annule
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.onSurface,
                              decoration:
                                  annule ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${rdv.prestation.nom} · ${rdv.prestation.duree.inMinutes} min',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: couleur.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              rdv.statut.libelle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: couleur,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Prix + menu ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 4, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8, top: 2),
                          child: Text(
                            '$prix €',
                            style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                        if (_modifiable)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz,
                                color: AppColors.onSurfaceVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            onSelected: (valeur) {
                              if (valeur == 'annuler') {
                                _confirmerAnnulation(context);
                              }
                              if (valeur == 'confirmer') onConfirme?.call();
                              if (valeur == 'terminer') onTermine?.call();
                            },
                            itemBuilder: (context) => [
                              if (rdv.statut == StatutRdv.enAttente)
                                const PopupMenuItem(
                                  value: 'confirmer',
                                  child: Text('Confirmer le RDV'),
                                ),
                              if (rdv.statut == StatutRdv.confirme)
                                const PopupMenuItem(
                                  value: 'terminer',
                                  child: Text('Marquer terminé'),
                                ),
                              PopupMenuItem(
                                value: 'annuler',
                                child: Text(
                                  rdv.statut == StatutRdv.enAttente
                                      ? 'Refuser'
                                      : 'Annuler le RDV',
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}