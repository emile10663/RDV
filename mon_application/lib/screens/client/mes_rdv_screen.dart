import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/rendez_vous.dart';
import '../../services/local_storage.dart';
import '../../theme/app_colors.dart';
import '../../widgets/statut_rdv_style.dart';

/// 📋 Les rendez-vous pris par le client (sur cet appareil)
class MesRdvScreen extends StatefulWidget {
  const MesRdvScreen({super.key});

  @override
  State<MesRdvScreen> createState() => _MesRdvScreenState();
}

class _MesRdvScreenState extends State<MesRdvScreen> {
  List<RendezVous> _mes = [];
  bool _charge = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final tous = await LocalStorage.charger();
    final ids = await LocalStorage.chargerMesIds();
    final mes = tous.where((r) => ids.contains(r.id)).toList();
    if (!mounted) return;
    setState(() {
      _mes = mes;
      _charge = true;
    });
  }

  Future<void> _annuler(RendezVous rdv) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler ce rendez-vous ?'),
        content: Text(rdv.dateFormatee),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    final tous = await LocalStorage.charger();
    final i = tous.indexWhere((r) => r.id == rdv.id);
    if (i == -1) return;
    tous[i] = tous[i].copyWith(statut: StatutRdv.annule);
    await LocalStorage.sauvegarder(tous);
    await _charger();
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;
    final maintenant = DateTime.now();

    final aVenir = _mes
        .where((r) =>
            r.dateHeure.isAfter(maintenant) &&
            (r.statut == StatutRdv.enAttente ||
                r.statut == StatutRdv.confirme))
        .toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    final passes = _mes.where((r) => !aVenir.contains(r)).toList()
      ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, haut + 16, 16, 24),
        children: [
          Text('Mes rendez-vous',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          if (_charge && _mes.isEmpty) const _Vide(),
          if (aVenir.isNotEmpty) ...[
            Text('À venir', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final r in aVenir)
              _CarteMonRdv(rdv: r, onAnnuler: () => _annuler(r)),
          ],
          if (passes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Historique', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final r in passes) _CarteMonRdv(rdv: r),
          ],
        ],
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  const _Vide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.goldSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_note,
                size: 36, color: AppColors.goldDark),
          ),
          const SizedBox(height: 18),
          Text('Aucun rendez-vous',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'Va sur « Le salon » pour réserver.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Carte d'un rendez-vous côté client
class _CarteMonRdv extends StatelessWidget {
  final RendezVous rdv;
  final VoidCallback? onAnnuler;

  const _CarteMonRdv({required this.rdv, this.onAnnuler});

  @override
  Widget build(BuildContext context) {
    final couleur = rdv.statut.couleur;
    final jour = DateFormat('EEEE d MMMM', 'fr_FR').format(rdv.dateHeure);
    final jourMaj = jour[0].toUpperCase() + jour.substring(1);
    final prix = rdv.prestation.prix.toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: couleur),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              jourMaj,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '$prix €',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'à ${rdv.heureFormatee} · ${rdv.prestation.nom}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: couleur.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rdv.statut.libelle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: couleur,
                          ),
                        ),
                      ),
                      if (rdv.statut == StatutRdv.enAttente &&
                          onAnnuler != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'En attente de confirmation par le salon.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (onAnnuler != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: onAnnuler,
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Annuler'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}