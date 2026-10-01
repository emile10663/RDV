import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/prestation.dart';
import '../../models/rendez_vous.dart';
import '../../models/salon.dart';
import '../../services/auth_service.dart';
import '../../services/prestation_service.dart';
import '../../services/rdv_service.dart';
import '../../services/salon_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/card_rdv.dart';
import '../../widgets/puce_jour.dart';
import '../booking/nouveau_rdv_screen.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  static const _joursAvant = 7;
  static const _joursApres = 30;
  static const _pas = PuceJour.largeur + PuceJour.espace;

  List<RendezVous> _rdvs = [];
  Salon? _salon;
  String? _erreur;
  StreamSubscription<List<RendezVous>>? _abonnement;
  late DateTime _jourChoisi;
  late final ScrollController _bandeau;

  static DateTime _jour(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _jourChoisi = _jour(DateTime.now());
    // Au départ, "aujourd'hui" est le premier jour visible dans la bande
    _bandeau = ScrollController(initialScrollOffset: _joursAvant * _pas);
    _demarrer();
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    _bandeau.dispose();
    super.dispose();
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texte)));
  }

  /// Charge le salon puis écoute ses rendez-vous en direct
  Future<void> _demarrer() async {
    await _abonnement?.cancel();
    _abonnement = null;
    if (mounted) {
      setState(() {
        _erreur = null;
      });
    }

    try {
      final salon = await SalonService.salonDuCoiffeur();
      if (!mounted) return;
      if (salon == null) {
        setState(() {
          _erreur = 'Salon introuvable.';
        });
        return;
      }
      setState(() {
        _salon = salon;
      });

      _abonnement = RdvService.ecouterSalon(salon.id).listen(
        (liste) {
          if (!mounted) return;
          setState(() {
            _rdvs = liste;
            _erreur = null;
          });
        },
        onError: (Object e) {
          debugPrint('Erreur écoute rendez-vous : $e');
          if (!mounted) return;
          setState(() {
            _erreur = 'Impossible de charger les rendez-vous.';
          });
        },
      );
    } catch (e) {
      debugPrint('Erreur chargement planning : $e');
      if (!mounted) return;
      setState(() {
        _erreur = 'Impossible de charger le planning.';
      });
    }
  }

  Future<void> _ajouterRdv() async {
    final salon = _salon;
    if (salon == null) {
      _message('Salon introuvable.');
      return;
    }

    // On relit les prestations à chaque fois, pour être à jour
    final List<Prestation> prestations;
    try {
      prestations = await PrestationService.charger(salon.id);
    } catch (e) {
      debugPrint('Erreur chargement prestations : $e');
      if (mounted) _message('Impossible de charger les prestations.');
      return;
    }
    if (!mounted) return;

    if (prestations.isEmpty) {
      _message('Ajoute d\'abord une prestation dans l\'onglet Profil.');
      return;
    }

    final rdv = await Navigator.of(context).push<RendezVous>(
      MaterialPageRoute(
        builder: (context) => NouveauRdvScreen(
          prestations: prestations,
          rdvsExistants: _rdvs,
          jourInitial: _jourChoisi,
        ),
      ),
    );
    if (rdv == null || !mounted) return;

    final uid = AuthService.utilisateur?.uid;
    if (uid == null) {
      _message('Session expirée. Reconnecte-toi.');
      return;
    }

    try {
      // Un RDV saisi par le coiffeur est directement confirmé
      await RdvService.creer(
        rdv.copyWith(statut: StatutRdv.confirme, salonId: salon.id),
        clientUid: uid,
      );
      if (!mounted) return;
      setState(() {
        _jourChoisi = _jour(rdv.dateHeure);
      });
    } catch (e) {
      debugPrint('Erreur création rendez-vous : $e');
      if (mounted) _message('Impossible d\'enregistrer le rendez-vous.');
    }
  }

  Future<void> _changerStatut(RendezVous rdv, StatutRdv statut) async {
    try {
      await RdvService.changerStatut(rdv, statut);
      // Pas de setState : l'écoute en direct met la liste à jour
    } catch (e) {
      debugPrint('Erreur changement de statut : $e');
      if (mounted) _message('Impossible de modifier le rendez-vous.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final aujourdhui = _jour(DateTime.now());

    final duJour = _rdvs.where((r) => _jour(r.dateHeure) == _jourChoisi).toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    final actifs = duJour.where((r) => r.statut != StatutRdv.annule);
    final ca = actifs.fold<double>(0, (t, r) => t + r.prestation.prix);
    final joursAvecRdv = {
      for (final r in _rdvs)
        if (r.statut != StatutRdv.annule) _jour(r.dateHeure),
    };

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterRdv,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau RDV'),
      ),
      body: Column(
        children: [
          _Entete(
            nomSalon: _salon?.nom ?? 'Mon salon',
            jour: _jourChoisi,
            nbRdv: actifs.length,
            ca: ca,
          ),

          // ─── Bande des jours ───
          SizedBox(
            height: 88,
            child: ListView.builder(
              controller: _bandeau,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 14, 6, 6),
              itemCount: _joursAvant + 1 + _joursApres,
              itemBuilder: (context, i) {
                final jour = DateTime(
                  aujourdhui.year,
                  aujourdhui.month,
                  aujourdhui.day - _joursAvant + i,
                );
                return PuceJour(
                  jour: jour,
                  selected: jour == _jourChoisi,
                  pastille: joursAvecRdv.contains(jour),
                  onTap: () => setState(() => _jourChoisi = jour),
                );
              },
            ),
          ),

          // ─── Liste du jour ───
          Expanded(
            child: _erreur != null && _rdvs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_erreur!),
                        TextButton(
                          onPressed: _demarrer,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : duJour.isEmpty
                    ? _JourneeLibre(onAjouter: _ajouterRdv)
                    : ListView(
                        padding: const EdgeInsets.only(top: 12, bottom: 110),
                        children: [
                          for (final rdv in duJour)
                            CardRdv(
                              rdv: rdv,
                              onConfirme: () =>
                                  _changerStatut(rdv, StatutRdv.confirme),
                              onAnnule: () =>
                                  _changerStatut(rdv, StatutRdv.annule),
                              onTermine: () =>
                                  _changerStatut(rdv, StatutRdv.termine),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

/// 🖤 En-tête sombre : nom du salon, date du jour + résumé
class _Entete extends StatelessWidget {
  final String nomSalon;
  final DateTime jour;
  final int nbRdv;
  final double ca;

  const _Entete({
    required this.nomSalon,
    required this.jour,
    required this.nbRdv,
    required this.ca,
  });

  String get _titre {
    final t = DateFormat('EEEE d MMMM', 'fr_FR').format(jour);
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;
    final euros =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2)
            .format(ca);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, haut + 18, 20, 22),
      decoration: const BoxDecoration(
        gradient: AppColors.enTete,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nomSalon.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 12,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _titre,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Pastille(
                icone: Icons.event_available,
                texte: '$nbRdv rendez-vous',
              ),
              _Pastille(icone: Icons.payments_outlined, texte: euros),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  final IconData icone;
  final String texte;

  const _Pastille({required this.icone, required this.texte});

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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌿 État vide : aucun rendez-vous ce jour-là
class _JourneeLibre extends StatelessWidget {
  final VoidCallback onAjouter;

  const _JourneeLibre({required this.onAjouter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.goldSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.content_cut,
                  size: 36, color: AppColors.goldDark),
            ),
            const SizedBox(height: 18),
            Text('Journée libre',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Aucun rendez-vous ce jour-là.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onAjouter,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un rendez-vous'),
              style: TextButton.styleFrom(foregroundColor: AppColors.goldDark),
            ),
          ],
        ),
      ),
    );
  }
}