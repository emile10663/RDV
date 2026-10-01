import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../models/rendez_vous.dart';
import '../../theme/app_colors.dart';
import '../../widgets/statut_rdv_style.dart';

/// 📄 Détail d'un rendez-vous
class RdvDetailScreen extends StatelessWidget {
  final RendezVous rdv;

  const RdvDetailScreen({super.key, required this.rdv});

  String _initiales(Client c) {
    final p = c.prenom.isNotEmpty ? c.prenom[0] : '';
    final n = c.nom.isNotEmpty ? c.nom[0] : '';
    final s = '$p$n'.toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  @override
  Widget build(BuildContext context) {
    final tel = rdv.client.telephone;
    final email = rdv.client.email;
    final prix = rdv.prestation.prix.toStringAsFixed(2).replaceAll('.', ',');

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du rendez-vous')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Carte sombre : le client ───
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.enTete,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    _initiales(rdv.client),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  rdv.client.nomComplet,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  rdv.prestation.nom,
                  style: const TextStyle(color: AppColors.gold, fontSize: 15),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rdv.statut.libelle,
                    style: TextStyle(
                      color: rdv.statut.couleur,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Infos ───
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _Ligne(
                    icone: Icons.event,
                    titre: 'Date',
                    texte: rdv.dateFormatee,
                  ),
                  _Ligne(
                    icone: Icons.schedule,
                    titre: 'Durée',
                    texte: '${rdv.prestation.duree.inMinutes} minutes',
                  ),
                  _Ligne(
                    icone: Icons.payments_outlined,
                    titre: 'Prix',
                    texte: '$prix €',
                  ),
                  if (tel.isNotEmpty)
                    _Ligne(
                      icone: Icons.phone_outlined,
                      titre: 'Téléphone',
                      texte: tel,
                    ),
                  if (email.isNotEmpty)
                    _Ligne(
                      icone: Icons.mail_outline,
                      titre: 'E-mail',
                      texte: email,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une ligne "icône dorée + titre + valeur"
class _Ligne extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String texte;

  const _Ligne({required this.icone, required this.titre, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, size: 20, color: AppColors.goldDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  texte,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}