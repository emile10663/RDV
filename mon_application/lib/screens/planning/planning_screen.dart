import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/rendez_vous.dart';
import '../../services/local_storage.dart';
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
  late DateTime _jourChoisi;
  late final ScrollController _bandeau;

  static DateTime _jour(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _jourChoisi = _jour(DateTime.now());
    // Au départ, "aujourd'hui" est le premier jour visible dans la bande
    _bandeau = ScrollController(initialScrollOffset: _joursAvant * _pas);
    _charger();
  }

  @override
  void dispose() {
    _bandeau.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final charges = await LocalStorage.charger();

    // 🩹 Répare les anciennes sauvegardes où plusieurs RDV avaient le même id
    final idsVus = <String>{};
    var repare = false;
    final rdvs = <RendezVous>[];
    for (var i = 0; i < charges.length; i++) {
      final r = charges[i];
      if (idsVus.add(r.id)) {
        rdvs.add(r);
      } else {
        repare = true;
        final nouvelId = '${RendezVous.nouvelId()}_$i';
        idsVus.add(nouvelId);
        rdvs.add(r.copyWith(id: nouvelId));
      }
    }

    if (!mounted) return;
    setState(() => _rdvs = rdvs);
    if (repare) await _sauvegarder();
  }

  Future<void> _sauvegarder() => LocalStorage.sauvegarder(_rdvs);

  Future<void> _ajouterRdv() async {
    final rdv = await Navigator.of(context).push<RendezVous>(
      MaterialPageRoute(
        builder: (context) => NouveauRdvScreen(
          rdvsExistants: _rdvs,
          jourInitial: _jourChoisi,
        ),
      ),
    );
    if (rdv == null || !mounted) return;
    setState(() {
      // Un RDV saisi par le coiffeur est directement confirmé
      _rdvs.add(rdv.copyWith(statut: StatutRdv.confirme));
      _jourChoisi = _jour(rdv.dateHeure);
    });
    await _sauvegarder();
  }

  Future<void> _changerStatut(String id, StatutRdv statut) async {
    final i = _rdvs.indexWhere((r) => r.id == id);
    if (i == -1) return;
    setState(() => _rdvs[i] = _rdvs[i].copyWith(statut: statut));
    await _sauvegarder();
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
          _Entete(jour: _jourChoisi, nbRdv: actifs.length, ca: ca),

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
            child: duJour.isEmpty
                ? _JourneeLibre(onAjouter: _ajouterRdv)
                : ListView(
                    padding: const EdgeInsets.only(top: 12, bottom: 110),
                    children: [
                      for (final rdv in duJour)
                        CardRdv(
                          rdv: rdv,
                          onConfirme: () =>
                              _changerStatut(rdv.id, StatutRdv.confirme),
                          onAnnule: () =>
                              _changerStatut(rdv.id, StatutRdv.annule),
                          onTermine: () =>
                              _changerStatut(rdv.id, StatutRdv.termine),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// 🖤 En-tête sombre : date du jour + résumé
class _Entete extends StatelessWidget {
  final DateTime jour;
  final int nbRdv;
  final double ca;

  const _Entete({required this.jour, required this.nbRdv, required this.ca});

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
          const Text(
            'MON SALON',
            style: TextStyle(
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