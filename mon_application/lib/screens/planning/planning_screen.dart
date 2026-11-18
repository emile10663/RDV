import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mon_application/screens/booking/nouveau_rdv_screen.dart';


import '../../models/rendez_vous.dart';
import '../../widgets/card_rdv.dart';
import '../../services/local_storage.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  List<RendezVous> _rdvs = []; // 👈 vraies données, plus mockRdvs !

  @override
  void initState() {
    super.initState();
    _charger(); // au démarrage : lit la sauvegarde
  }

  Future<void> _charger() async {
    final rdvs = await LocalStorage.charger();
    setState(() => _rdvs = rdvs);
  }

  Future<void> _sauvegarder() => LocalStorage.sauvegarder(_rdvs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planning')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Le formulaire RENVOIE le nouveau RDV (pop(rdv) — à modifier à l'étape 5)
          final rdv = await Navigator.of(context).push<RendezVous>(
            MaterialPageRoute(builder: (context) => const NouveauRdvScreen()),
          );
          if (rdv != null) {
            setState(() => _rdvs.add(rdv));
            await _sauvegarder(); // 💾 sauvegarde après chaque ajout
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: _construireListe(),
      ),
    );
  }

    List<Widget> _construireListe() {
    // 👇 ÉTAT VIDE : aucun RDV
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text('Tape sur + pour créer le premier !'),
              ],
            ),
          ),
        ),
      ];
    }

    // ... le reste (tri + en-têtes + cartes) inchangé


    
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
          onAnnule: () async {
            final i = _rdvs.indexWhere((r) => r.id == rdv.id);
            setState(
              () => _rdvs[i] = _rdvs[i].copyWith(statut: StatutRdv.annule),
            );
            await _sauvegarder(); // 💾 sauvegarde après annulation
          },
          onTermine: () async {
            final i = _rdvs.indexWhere((r) => r.id == rdv.id);
            setState(() => _rdvs[i] = _rdvs[i].copyWith(statut: StatutRdv.termine));
            await _sauvegarder();
          },
        ),
      );
    }
    return widgets;
  }
  // ... _libelleJour et _EnTeteJour inchangés

    /// 🗓️ Libellé du jour : "Aujourd'hui", "Demain", ou "ven. 25 sept. 2026"
  String _libelleJour(DateTime jour) {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);
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
        style: Theme.of(context).textTheme.titleMedium!
            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

