import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/rendez_vous.dart';
import '../../services/local_storage.dart';

/// 📊 Statistiques du salon
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<RendezVous> _rdvs = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final rdvs = await LocalStorage.charger();
    if (!mounted) return;
    setState(() => _rdvs = rdvs);
  }

  bool _memeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// RDV qui comptent (on ignore les annulés, partout)
  Iterable<RendezVous> get _actifs =>
      _rdvs.where((r) => r.statut != StatutRdv.annule);

  Iterable<RendezVous> get _actifsAujourdhui {
    final now = DateTime.now();
    return _actifs.where((r) => _memeJour(r.dateHeure, now));
  }

  double _somme(Iterable<RendezVous> rdvs) =>
      rdvs.fold(0.0, (total, r) => total + r.prestation.prix);

  String _euros(double montant) =>
      NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2)
          .format(montant);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CarteStat(
            titre: "Chiffre d'affaires du jour",
            valeur: _euros(_somme(_actifsAujourdhui)),
            icone: Icons.today,
          ),
          _CarteStat(
            titre: "Rendez-vous aujourd'hui",
            valeur: '${_actifsAujourdhui.length}',
            icone: Icons.event_available,
          ),
          _CarteStat(
            titre: "Chiffre d'affaires total",
            valeur: _euros(_somme(_actifs)),
            icone: Icons.euro,
          ),
        ],
      ),
    );
  }
}

/// 🃏 Une carte de statistique réutilisable
class _CarteStat extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icone;

  const _CarteStat({
    required this.titre,
    required this.valeur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(valeur,
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}