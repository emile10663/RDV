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
import '../../utils/prix.dart';
import '../../widgets/card_rdv.dart';
import '../../widgets/logo_salon.dart';
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
  bool _annulesVisibles = false;

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

  /// Revient sur aujourd'hui et fait défiler la bande des jours
  void _allerAujourdhui() {
    setState(() => _jourChoisi = _jour(DateTime.now()));
    if (_bandeau.hasClients) {
      _bandeau.animateTo(
        _joursAvant * _pas,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
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
          horaires: salon.horaires,
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
    } on CreneauPrisException catch (e) {
      if (mounted) _message(e.message);
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

    final duJour =
        _rdvs.where((r) => _jour(r.dateHeure) == _jourChoisi).toList()
          ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    final actifs = duJour.where((r) => r.statut != StatutRdv.annule).toList();
    final annules = duJour.where((r) => r.statut == StatutRdv.annule).toList();
    final ca = actifs.fold<double>(0, (t, r) => t + r.prestation.prix);
    final ferme = _salon?.horaires.estOuvert(_jourChoisi) == false;

    // Le prochain rendez-vous à venir (tous jours confondus)
    final maintenant = DateTime.now();
    final aVenir = _rdvs
        .where(
          (r) =>
              (r.statut == StatutRdv.confirme ||
                  r.statut == StatutRdv.enAttente) &&
              r.fin.isAfter(maintenant),
        )
        .toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    String? prochain;
    if (aVenir.isNotEmpty) {
      final r = aVenir.first;
      final quand = _jour(r.dateHeure) == aujourdhui
          ? ''
          : '${DateFormat('E', 'fr_FR').format(r.dateHeure).replaceAll('.', '')} ';
      final prenom =
          r.client.prenom.trim().isEmpty ? r.client.nom : r.client.prenom;
      prochain = 'Prochain : $quand${r.heureFormatee} · $prenom';
    }
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
            logo: _salon?.logo,
            prochain: prochain,
          ),

          // ─── Mois + retour à aujourd'hui ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              children: [
                Text(
                  () {
                    final m = DateFormat('MMMM y', 'fr_FR').format(_jourChoisi);
                    return m[0].toUpperCase() + m.substring(1);
                  }(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_jourChoisi != aujourdhui)
                  TextButton.icon(
                    onPressed: _allerAujourdhui,
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Aujourd\'hui'),
                  ),
              ],
            ),
          ),

          // ─── Bande des jours ───
          SizedBox(
            height: 82,
            child: ListView.builder(
              controller: _bandeau,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 6, 6),
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
                  ferme: _salon?.horaires.estOuvert(jour) == false,
                  aujourdhui: jour == aujourdhui,
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
                ? _JourneeLibre(ferme: ferme, onAjouter: _ajouterRdv)
                : ListView(
                    padding: const EdgeInsets.only(top: 12, bottom: 110),
                    children: [
                      if (actifs.isEmpty)
                        _CarteJourLibre(ferme: ferme, onAjouter: _ajouterRdv),
                      for (final rdv in actifs)
                        CardRdv(
                          rdv: rdv,
                          onConfirme: () =>
                              _changerStatut(rdv, StatutRdv.confirme),
                          onAnnule: () => _changerStatut(rdv, StatutRdv.annule),
                          onTermine: () =>
                              _changerStatut(rdv, StatutRdv.termine),
                        ),
                      // Les rendez-vous annulés sont repliés en bas
                      if (annules.isNotEmpty) ...[
                        _EnteteAnnules(
                          nombre: annules.length,
                          ouvert: _annulesVisibles,
                          onTap: () => setState(
                            () => _annulesVisibles = !_annulesVisibles,
                          ),
                        ),
                        if (_annulesVisibles)
                          for (final rdv in annules) CardRdv(rdv: rdv),
                      ],
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
  final String? logo;
  final String? prochain;

  const _Entete({
    required this.nomSalon,
    required this.jour,
    required this.nbRdv,
    required this.ca,
    this.logo,
    this.prochain,
  });

  String get _titre {
    final t = DateFormat('EEEE d MMMM', 'fr_FR').format(jour);
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;
    final euros = formatPrix(ca);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomSalon.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _titre,
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              if (logo != null) ...[
                const SizedBox(width: 12),
                LogoSalon(
                  logo: logo,
                  taille: 48,
                  fond: Colors.white24,
                  couleurIcone: AppColors.accent,
                  bordure: AppColors.accent,
                ),
              ],
            ],
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
              if (prochain != null)
                _Pastille(icone: Icons.schedule, texte: prochain!),
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
          Icon(icone, size: 16, color: AppColors.accent),
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
  final bool ferme;
  final VoidCallback onAjouter;

  const _JourneeLibre({required this.ferme, required this.onAjouter});

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
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ferme ? Icons.event_busy : Icons.content_cut,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              ferme ? 'Salon fermé' : 'Journée libre',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              ferme
                  ? 'Le salon est fermé ce jour-là.'
                  : 'Aucun rendez-vous ce jour-là.\n'
                        'Appuie sur « Nouveau RDV » pour en ajouter un.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            if (!ferme) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onAjouter,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un rendez-vous'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Petite carte « journée libre » quand il ne reste que des RDV annulés
class _CarteJourLibre extends StatelessWidget {
  final bool ferme;
  final VoidCallback onAjouter;

  const _CarteJourLibre({required this.ferme, required this.onAjouter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            ferme ? Icons.event_busy : Icons.event_available,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ferme
                  ? 'Le salon est fermé ce jour-là.'
                  : 'Aucun rendez-vous actif ce jour-là.',
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          if (!ferme)
            TextButton(onPressed: onAjouter, child: const Text('Ajouter')),
        ],
      ),
    );
  }
}

/// Ligne « 2 annulés » qui plie / déplie les rendez-vous annulés
class _EnteteAnnules extends StatelessWidget {
  final int nombre;
  final bool ouvert;
  final VoidCallback onTap;

  const _EnteteAnnules({
    required this.nombre,
    required this.ouvert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 16, 14),
        child: Row(
          children: [
            Text(
              nombre > 1 ? '$nombre annulés' : '1 annulé',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              ouvert ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}