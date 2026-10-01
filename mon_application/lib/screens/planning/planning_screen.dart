import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/rendez_vous.dart';
import '../../services/local_storage.dart';
import '../../widgets/card_rdv.dart';
import '../booking/nouveau_rdv_screen.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  List<RendezVous> _rdvs = [];

  @override
  void initState() {
    super.initState();
    _charger();
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
        builder: (context) => NouveauRdvScreen(rdvsExistants: _rdvs),
      ),
    );
    if (rdv == null || !mounted) return;
    setState(() => _rdvs.add(rdv));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Planning')),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterRdv,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: _construireListe(),
      ),
    );
  }

  List<Widget> _construireListe() {
    if (_rdvs.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 140),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.calendar_today_outlined, size: 64),
                SizedBox(height: 16),
                Text('Aucun rendez-vous',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text('Tape sur + pour créer le premier !'),
              ],
            ),
          ),
        ),
      ];
    }

    final rdvsTries = [..._rdvs]
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    final List<Widget> widgets = [];
    DateTime? jourCourant;

    for (final rdv in rdvsTries) {
      final jour = DateTime(
        rdv.dateHeure.year,
        rdv.dateHeure.month,
        rdv.dateHeure.day,
      );
      if (jourCourant == null || jour != jourCourant) {
        jourCourant = jour;
        widgets.add(_EnTeteJour(titre: _libelleJour(jour)));
      }
      widgets.add(
        CardRdv(
          rdv: rdv,
          onAnnule: () => _changerStatut(rdv.id, StatutRdv.annule),
          onTermine: () => _changerStatut(rdv.id, StatutRdv.termine),
        ),
      );
    }
    return widgets;
  }

  /// "Aujourd'hui", "Demain", ou "Vendredi 25 sept."
  String _libelleJour(DateTime jour) {
    final maintenant = DateTime.now();
    final aujourdhui =
        DateTime(maintenant.year, maintenant.month, maintenant.day);
    final demain = aujourdhui.add(const Duration(days: 1));

    if (jour == aujourdhui) return "Aujourd'hui";
    if (jour == demain) return 'Demain';

    final date = DateFormat('EEEE d MMM', 'fr_FR').format(jour);
    return date[0].toUpperCase() + date.substring(1);
  }
}

/// 🏷️ En-tête de section : "Aujourd'hui", "Demain"...
class _EnTeteJour extends StatelessWidget {
  final String titre;
  const _EnTeteJour({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        titre,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}