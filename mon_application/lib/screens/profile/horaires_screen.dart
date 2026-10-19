import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/horaires_salon.dart';
import '../../models/salon.dart';
import '../../services/salon_service.dart';
import '../../theme/app_colors.dart';

const _noms = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

/// 🕘 Le coiffeur règle ses horaires par jour et ses jours de congé.
/// Renvoie les nouveaux horaires (HorairesSalon) quand ils sont enregistrés.
class HorairesScreen extends StatefulWidget {
  final Salon salon;

  const HorairesScreen({super.key, required this.salon});

  @override
  State<HorairesScreen> createState() => _HorairesScreenState();
}

class _HorairesScreenState extends State<HorairesScreen> {
  static const _plageParDefaut = PlageHoraire(540, 1140);

  late Map<int, PlageHoraire?> _semaine;
  late Set<String> _conges;
  bool _envoi = false;

  @override
  void initState() {
    super.initState();
    _semaine = Map.of(widget.salon.horaires.semaine);
    // On ne garde que les congés d'aujourd'hui et à venir
    final aujourdhui = HorairesSalon.cleJour(DateTime.now());
    _conges = widget.salon.horaires.conges
        .where((c) => c.compareTo(aujourdhui) >= 0)
        .toSet();
  }

  /// Heures proposées : toutes les 30 min
  static List<int> _heures(int min, int max) =>
      [for (var m = min; m <= max; m += 30) m];

  void _copierLundi() {
    final lundi = _semaine[1];
    if (lundi == null) return;
    setState(() {
      for (var j = 2; j <= 7; j++) {
        if (_semaine[j] != null) _semaine[j] = lundi;
      }
    });
  }

  /// Regroupe les jours de congé qui se suivent : "25 déc. → 31 déc."
  List<(DateTime, DateTime)> _plages() {
    final jours = _conges.map(DateTime.parse).toList()..sort();
    final resultat = <(DateTime, DateTime)>[];
    for (final jour in jours) {
      if (resultat.isNotEmpty) {
        final (debut, fin) = resultat.last;
        final suivant = DateTime(fin.year, fin.month, fin.day + 1);
        if (jour == suivant) {
          resultat[resultat.length - 1] = (debut, jour);
          continue;
        }
      }
      resultat.add((jour, jour));
    }
    return resultat;
  }

  String _texteConge(DateTime debut, DateTime fin) {
    final f = DateFormat('EEE d MMM', 'fr_FR');
    return debut == fin ? f.format(debut) : '${f.format(debut)} → ${f.format(fin)}';
  }

  Future<void> _ajouterConge() async {
    final aujourdhui = DateTime.now();
    final debutPossible = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    final plage = await showDateRangePicker(
      context: context,
      firstDate: debutPossible,
      lastDate: DateTime(debutPossible.year + 2, debutPossible.month, debutPossible.day),
      helpText: 'Choisis le premier et le dernier jour de congé',
      saveText: 'Ajouter',
    );
    if (plage == null) return;

    final jours = <String>{};
    var jour = DateTime(plage.start.year, plage.start.month, plage.start.day);
    final fin = DateTime(plage.end.year, plage.end.month, plage.end.day);
    while (!jour.isAfter(fin)) {
      jours.add(HorairesSalon.cleJour(jour));
      jour = DateTime(jour.year, jour.month, jour.day + 1);
    }

    if (_conges.length + jours.length > 366) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trop de jours de congé (366 maximum).')),
      );
      return;
    }
    setState(() => _conges.addAll(jours));
  }

  void _supprimerConge(DateTime debut, DateTime fin) {
    setState(() {
      var jour = debut;
      while (!jour.isAfter(fin)) {
        _conges.remove(HorairesSalon.cleJour(jour));
        jour = DateTime(jour.year, jour.month, jour.day + 1);
      }
    });
  }

  Future<void> _enregistrer() async {
    final horaires = HorairesSalon(
      semaine: Map.of(_semaine),
      conges: (_conges.toList()..sort()),
    );

    setState(() => _envoi = true);
    try {
      await SalonService.mettreAJourHoraires(widget.salon.id, horaires);
      if (!mounted) return;
      Navigator.of(context).pop(horaires);
    } catch (e) {
      debugPrint('Erreur enregistrement horaires : $e');
      if (!mounted) return;
      setState(() => _envoi = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'enregistrer les horaires.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plages = _plages();

    return Scaffold(
      appBar: AppBar(title: const Text('Horaires et congés')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text('Horaires par jour',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (var j = 1; j <= 7; j++) _ligneJour(j),
          if (_semaine[1] != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _copierLundi,
                icon: const Icon(Icons.copy_all, size: 18),
                label: const Text('Copier les horaires du lundi sur les autres jours'),
              ),
            ),
          const SizedBox(height: 20),
          Text('Jours de congé',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Les clients ne pourront pas réserver ces jours-là. '
            'Les rendez-vous déjà pris ne sont pas modifiés.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          if (plages.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Aucun congé prévu.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (debut, fin) in plages)
                InputChip(
                  label: Text(_texteConge(debut, fin)),
                  onDeleted: () => _supprimerConge(debut, fin),
                ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _ajouterConge,
            icon: const Icon(Icons.event_busy),
            label: const Text('Ajouter un congé'),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _envoi ? null : _enregistrer,
            child: _envoi
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _ligneJour(int jour) {
    final plage = _semaine[jour];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _noms[jour - 1],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  plage == null ? 'Fermé' : 'Ouvert',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Switch(
                  value: plage != null,
                  onChanged: (ouvert) => setState(() {
                    _semaine[jour] = ouvert ? _plageParDefaut : null;
                  }),
                ),
              ],
            ),
            if (plage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _choixHeure(
                        valeur: plage.ouverture,
                        heures: _heures(360, plage.fermeture - 30),
                        onChanged: (m) => setState(
                          () => _semaine[jour] = PlageHoraire(m, plage.fermeture),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('à'),
                    ),
                    Expanded(
                      child: _choixHeure(
                        valeur: plage.fermeture,
                        heures: _heures(plage.ouverture + 30, 1410),
                        onChanged: (m) => setState(
                          () => _semaine[jour] = PlageHoraire(plage.ouverture, m),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _choixHeure({
    required int valeur,
    required List<int> heures,
    required ValueChanged<int> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      // La clé change avec la valeur : le champ se met à jour (ex. « copier le lundi »)
      key: ValueKey(valeur),
      initialValue: valeur,
      isDense: true,
      items: [
        for (final m in heures)
          DropdownMenuItem(value: m, child: Text(PlageHoraire.texteMinutes(m))),
      ],
      onChanged: (m) {
        if (m != null) onChanged(m);
      },
    );
  }
}