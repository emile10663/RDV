import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/horaires.dart';
import '../../models/prestation.dart';
import '../../models/rendez_vous.dart';
import '../../models/salon.dart';
import '../../services/auth_service.dart';
import '../../services/prestation_service.dart';
import '../../services/rdv_service.dart';
import '../../theme/app_colors.dart';
import '../accueil_screen.dart';
import '../booking/nouveau_rdv_screen.dart';

/// 💈 Page du salon vue par le client : présentation + prestations
class SalonScreen extends StatefulWidget {
  final Salon salon;
  final VoidCallback onChangerSalon;

  const SalonScreen({
    super.key,
    required this.salon,
    required this.onChangerSalon,
  });

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  List<Prestation> _prestations = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texte)));
  }

  String _texteErreur(Object e, String parDefaut) =>
      e is FirebaseAuthException ? AuthService.messageErreur(e) : parDefaut;

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final liste = await PrestationService.charger(widget.salon.id);
      if (!mounted) return;
      setState(() {
        _prestations = liste;
        _chargement = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement prestations : $e');
      if (!mounted) return;
      setState(() {
        _erreur = 'Impossible de charger les prestations.';
        _chargement = false;
      });
    }
  }

  Future<void> _reserver() async {
    if (_prestations.isEmpty) {
      _message('Ce salon n\'a pas encore de prestations.');
      return;
    }

    // 1. Session du client + créneaux déjà pris (sans aucun nom)
    final String uid;
    final List<RendezVous> occupes;
    try {
      uid = await AuthService.assurerSessionClient();
      occupes = await RdvService.creneauxOccupes(widget.salon.id);
    } catch (e) {
      debugPrint('Erreur préparation réservation : $e');
      if (mounted) {
        _message(_texteErreur(e, 'Impossible de joindre le salon. Réessaie.'));
      }
      return;
    }
    if (!mounted) return;

    // 2. Formulaire de réservation
    final rdv = await Navigator.of(context).push<RendezVous>(
      MaterialPageRoute(
        builder: (context) => NouveauRdvScreen(
          prestations: _prestations,
          rdvsExistants: occupes,
          modeClient: true,
        ),
      ),
    );
    if (rdv == null || !mounted) return;

    // 3. Envoi de la demande au salon
    try {
      await RdvService.creer(
        rdv.copyWith(salonId: widget.salon.id),
        clientUid: uid,
      );
      if (!mounted) return;
      _message('Demande envoyée ! Le salon va la confirmer.');
    } catch (e) {
      debugPrint('Erreur envoi demande : $e');
      if (mounted) {
        _message(_texteErreur(e, 'Impossible d\'envoyer la demande. Réessaie.'));
      }
    }
  }

  String _h(int heure) => '${heure.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;
    final salon = widget.salon;

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
                      tooltip: 'Changer de salon',
                      icon: const Icon(Icons.storefront_outlined,
                          color: Colors.white),
                      onPressed: widget.onChangerSalon,
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
                  salon.nom,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  salon.adresse,
                  style: const TextStyle(color: AppColors.gold, fontSize: 15),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _PastilleEntete(
                      icone: Icons.schedule,
                      texte:
                          'Ouvert de ${_h(heureOuverture)} à ${_h(heureFermeture)}',
                    ),
                    _PastilleEntete(
                      icone: Icons.phone_outlined,
                      texte: salon.telephone,
                    ),
                  ],
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
          if (_chargement)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_erreur != null)
            Column(
              children: [
                Text(_erreur!),
                TextButton(
                  onPressed: _charger,
                  child: const Text('Réessayer'),
                ),
              ],
            )
          else if (_prestations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ce salon n\'a pas encore ajouté de prestations.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            )
          else
            for (final p in _prestations)
              _CartePrestation(prestation: p, onTap: _reserver),
        ],
      ),
    );
  }
}

class _PastilleEntete extends StatelessWidget {
  final IconData icone;
  final String texte;

  const _PastilleEntete({required this.icone, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(
            texte,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
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