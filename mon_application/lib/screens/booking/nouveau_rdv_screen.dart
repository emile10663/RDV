import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_rdvs.dart';
import '../../models/client.dart';
import '../../models/prestation.dart';
import '../../models/rendez_vous.dart';

/// ➕ Écran de création d'un rendez-vous
class NouveauRdvScreen extends StatefulWidget {
  /// RDV déjà pris : sert à empêcher deux RDV au même créneau
  final List<RendezVous> rdvsExistants;

  const NouveauRdvScreen({super.key, this.rdvsExistants = const []});

  @override
  State<NouveauRdvScreen> createState() => _NouveauRdvScreenState();
}

class _NouveauRdvScreenState extends State<NouveauRdvScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _telController = TextEditingController();
  Prestation? _prestationChoisie;
  DateTime? _dateChoisie;
  TimeOfDay? _heureChoisie;

  String? _obligatoire(String? valeur) =>
      (valeur == null || valeur.trim().isEmpty) ? 'Champ obligatoire' : null;

  void _message(String texte) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texte)));
  }

  Future<void> _choisirDate() async {
    final now = DateTime.now();
    final aujourdhui = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: _dateChoisie ?? aujourdhui,
      firstDate: aujourdhui, // pas de RDV dans le passé
      lastDate: aujourdhui.add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _dateChoisie = date);
  }

  Future<void> _choisirHeure() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: _heureChoisie ?? TimeOfDay.now(),
    );
    if (heure != null) setState(() => _heureChoisie = heure);
  }

  void _valider() {
    // 1. Champs texte (prénom, nom)
    if (!_formKey.currentState!.validate()) return;

    // 2. Prestation, date, heure
    if (_prestationChoisie == null ||
        _dateChoisie == null ||
        _heureChoisie == null) {
      _message('Prestation, date et heure sont obligatoires');
      return;
    }

    final debut = DateTime(
      _dateChoisie!.year,
      _dateChoisie!.month,
      _dateChoisie!.day,
      _heureChoisie!.hour,
      _heureChoisie!.minute,
    );

    // 3. Pas de créneau déjà passé
    if (debut.isBefore(DateTime.now())) {
      _message('Ce créneau est déjà passé');
      return;
    }

    final rdv = RendezVous(
      id: RendezVous.nouvelId(),
      client: Client(
        id: 'c${RendezVous.nouvelId()}',
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telController.text.trim(),
        email: '',
      ),
      prestation: _prestationChoisie!,
      dateHeure: debut,
    );

    // 4. Pas de chevauchement avec un RDV non annulé
    final conflit = widget.rdvsExistants
        .where((r) => r.statut != StatutRdv.annule)
        .any((r) => r.chevauche(rdv));
    if (conflit) {
      _message('Ce créneau chevauche un autre rendez-vous');
      return;
    }

    Navigator.of(context).pop(rdv);
  }

  String _heureTexte(TimeOfDay h) =>
      '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final prestation = _prestationChoisie;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau rendez-vous')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _prenomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                hintText: 'Ex : Sophie',
              ),
              validator: _obligatoire,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex : Martin',
              ),
              validator: _obligatoire,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
            const SizedBox(height: 16),

            // ─── Prestation ───
            DropdownButtonFormField<Prestation>(
              initialValue: _prestationChoisie,
              decoration: const InputDecoration(labelText: 'Prestation'),
              items: mockPrestations.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text('${p.nom} — ${p.prix.toStringAsFixed(2)} €'),
                );
              }).toList(),
              onChanged: (p) => setState(() => _prestationChoisie = p),
            ),
            if (prestation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'Durée : ${prestation.duree.inMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),

            // ─── Date + heure ───
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _choisirDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dateChoisie == null
                        ? 'Date'
                        : DateFormat('dd/MM/yyyy').format(_dateChoisie!)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _choisirHeure,
                    icon: const Icon(Icons.schedule),
                    label: Text(_heureChoisie == null
                        ? 'Heure'
                        : _heureTexte(_heureChoisie!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _valider,
              child: const Text('Valider le rendez-vous'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telController.dispose();
    super.dispose();
  }
}