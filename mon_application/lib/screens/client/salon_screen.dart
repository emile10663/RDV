import 'package:flutter/material.dart';
import '../../data/horaires.dart';
import '../../data/mock_rdvs.dart';
import '../../models/prestation.dart';
import '../../models/rendez_vous.dart';
import '../../services/local_storage.dart';
import '../../theme/app_colors.dart';
import '../accueil_screen.dart';
import '../booking/nouveau_rdv_screen.dart';

/// 💈 Page du salon vue par le client : présentation + prestations
class SalonScreen extends StatefulWidget {
  const SalonScreen({super.key});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  Future<void> _reserver() async {
    final existants = await LocalStorage.charger();
    if (!mounted) return;

    final rdv = await Navigator.of(context).push<RendezVous>(
      MaterialPageRoute(
        builder: (context) => NouveauRdvScreen(
          rdvsExistants: existants,
          modeClient: true,
        ),
      ),
    );
    if (rdv == null || !mounted) return;

    // On relit la liste au cas où elle a changé, puis on ajoute la demande
    final tous = await LocalStorage.charger();
    tous.add(rdv);
    await LocalStorage.sauvegarder(tous);
    await LocalStorage.ajouterMonRdv(rdv.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demande envoyée ! Le salon va la confirmer.'),
      ),
    );
  }

  String _h(int heure) => '${heure.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reserver,
        icon: const Icon(Icons.event_available),
        label: const Text('Prendre rendez-vous'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          // ─── En-tête du salon ───
          Container(
            padding: EdgeInsets.fromLTRB(20, haut + 12, 12, 26),
            decoration: const BoxDecoration(
              gradient: AppColors.enTete,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'BIENVENUE CHEZ',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Changer de mode',
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      onPressed: () =>
                          Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const AccueilScreen(),
                        ),
                        (_) => false,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Mon Salon',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Coiffeur & Barbier',
                  style: TextStyle(color: AppColors.gold, fontSize: 15),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule,
                          size: 16, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        'Ouvert de ${_h(heureOuverture)} à ${_h(heureFermeture)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Prestations ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Nos prestations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final p in mockPrestations)
            _CartePrestation(prestation: p, onTap: _reserver),
        ],
      ),
    );
  }
}

class _CartePrestation extends StatelessWidget {
  final Prestation prestation;
  final VoidCallback onTap;

  const _CartePrestation({required this.prestation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prix = prestation.prix.toStringAsFixed(2).replaceAll('.', ',');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.content_cut,
                      color: AppColors.goldDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prestation.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (prestation.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            prestation.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${prestation.duree.inMinutes} min',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$prix €',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}