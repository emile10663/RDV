import 'package:flutter/material.dart';
import '../../models/salon.dart';
import '../../services/salon_service.dart';
import '../../theme/app_colors.dart';
import '../accueil_screen.dart';

/// 🔎 Le client choisit son salon (provisoire, avant le lien / QR code)
class ChoixSalonScreen extends StatefulWidget {
  final ValueChanged<Salon> onChoisi;

  const ChoixSalonScreen({super.key, required this.onChoisi});

  @override
  State<ChoixSalonScreen> createState() => _ChoixSalonScreenState();
}

class _ChoixSalonScreenState extends State<ChoixSalonScreen> {
  late Future<List<Salon>> _futur = SalonService.tous();

  void _recharger() {
    final nouveau = SalonService.tous();
    setState(() {
      _futur = nouveau;
    });
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8, haut + 8, 20, 26),
            decoration: const BoxDecoration(
              gradient: AppColors.enTete,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'Retour',
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AccueilScreen()),
                    (_) => false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'Choisis ton salon',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Salon>>(
              future: _futur,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Impossible de charger les salons.'),
                        TextButton(
                          onPressed: _recharger,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final salons = snap.data ?? [];
                if (salons.isEmpty) {
                  return const Center(
                    child: Text('Aucun salon pour l\'instant.'),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    for (final s in salons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            onTap: () => widget.onChoisi(s),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.goldSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.content_cut,
                                  color: AppColors.goldDark),
                            ),
                            title: Text(
                              s.nom,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(s.adresse),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}