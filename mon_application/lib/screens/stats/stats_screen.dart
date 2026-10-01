import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/rendez_vous.dart';
import '../../services/local_storage.dart';
import '../../theme/app_colors.dart';

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
    final haut = MediaQuery.of(context).padding.top;
    final aujourdhui = DateTime.now();
    final nbAujourdhui = _actifsAujourdhui.length;

    // CA des 7 derniers jours (le dernier = aujourd'hui)
    final jours = List.generate(7, (i) {
      final d = DateTime(aujourdhui.year, aujourdhui.month,
          aujourdhui.day - (6 - i));
      final ca = _somme(_actifs.where((r) => _memeJour(r.dateHeure, d)));
      return (jour: d, ca: ca);
    });
    var maxCa = jours.map((j) => j.ca).reduce((a, b) => a > b ? a : b);
    if (maxCa == 0) maxCa = 1;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, haut + 16, 16, 24),
        children: [
          Text('Statistiques',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),

          // ─── Carte principale : CA du jour ───
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.enTete,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chiffre d'affaires du jour",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _euros(_somme(_actifsAujourdhui)),
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: AppColors.gold,
                        fontSize: 34,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.event_available,
                        size: 18, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      "$nbAujourdhui rendez-vous aujourd'hui",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── Deux petites cartes ───
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icone: Icons.payments_outlined,
                  titre: "CA total",
                  valeur: _euros(_somme(_actifs)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icone: Icons.calendar_month_outlined,
                  titre: 'Rendez-vous',
                  valeur: '${_actifs.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ─── Graphique 7 jours ───
          Text('7 derniers jours',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < jours.length; i++)
                      Expanded(
                        child: _Barre(
                          ca: jours[i].ca,
                          ratio: jours[i].ca / maxCa,
                          lettre: DateFormat('E', 'fr_FR')
                              .format(jours[i].jour)[0]
                              .toUpperCase(),
                          aujourdhui: i == jours.length - 1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Une colonne du graphique
class _Barre extends StatelessWidget {
  final double ca;
  final double ratio;
  final String lettre;
  final bool aujourdhui;

  const _Barre({
    required this.ca,
    required this.ratio,
    required this.lettre,
    required this.aujourdhui,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 14,
          child: ca > 0
              ? Text(
                  ca.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 22,
          height: 4 + ratio * 90,
          decoration: BoxDecoration(
            color: aujourdhui ? AppColors.gold : AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lettre,
          style: TextStyle(
            fontSize: 12,
            fontWeight: aujourdhui ? FontWeight.w700 : FontWeight.w500,
            color: aujourdhui ? AppColors.goldDark : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Petite carte de stat (icône + titre + valeur)
class _MiniStat extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String valeur;

  const _MiniStat({
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, size: 20, color: AppColors.goldDark),
            ),
            const SizedBox(height: 12),
            Text(
              titre,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valeur,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}