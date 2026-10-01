import 'package:flutter/material.dart';
import '../../models/rendez_vous.dart';
import '../../widgets/statut_rdv_style.dart';

/// 📄 Détail d'un rendez-vous
class RdvDetailScreen extends StatelessWidget {
  final RendezVous rdv;

  const RdvDetailScreen({super.key, required this.rdv});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tel = rdv.client.telephone;
    final email = rdv.client.email;

    return Scaffold(
      appBar: AppBar(title: Text(rdv.prestation.nom)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(rdv.client.nomComplet, style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _BadgeStatut(statut: rdv.statut),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Ligne(icone: Icons.event, texte: rdv.dateFormatee),
                  _Ligne(
                    icone: Icons.schedule,
                    texte: '${rdv.prestation.duree.inMinutes} minutes',
                  ),
                  _Ligne(
                    icone: Icons.euro,
                    texte: '${rdv.prestation.prix.toStringAsFixed(2)} €',
                  ),
                  if (tel.isNotEmpty)
                    _Ligne(icone: Icons.phone_outlined, texte: tel),
                  if (email.isNotEmpty)
                    _Ligne(icone: Icons.mail_outline, texte: email),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une ligne "icône + texte"
class _Ligne extends StatelessWidget {
  final IconData icone;
  final String texte;

  const _Ligne({required this.icone, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icone, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texte, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

/// Pastille de statut (Confirmé, En attente...)
class _BadgeStatut extends StatelessWidget {
  final StatutRdv statut;

  const _BadgeStatut({required this.statut});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statut.couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statut.libelle,
        style: TextStyle(
          color: statut.couleur,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}