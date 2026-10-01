import 'package:flutter/material.dart';
import '../../data/mock_rdvs.dart';
import '../../models/client.dart';
import '../../models/prestation.dart';
import '../../models/rendez_vous.dart';

/// ➕ Écran de création d'un rendez-vous
class NouveauRdvScreen extends StatefulWidget {
  const NouveauRdvScreen({super.key});

  @override
  State<NouveauRdvScreen> createState() => _NouveauRdvScreenState();
}

class _NouveauRdvScreenState extends State<NouveauRdvScreen> {
  // 🧠 CERVEAU : tout ce qui change vit ici
  final _nomController = TextEditingController();
  final _telController = TextEditingController();
  Prestation? _prestationChoisie;   // nullable = rien choisi au départ
  DateTime? _dateChoisie;
  TimeOfDay? _heureChoisie;

  // 📅 Sélecteur de date fourni par Flutter
  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: maintenant,
      firstDate: maintenant,                          // pas de RDV dans le passé
      lastDate: maintenant.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dateChoisie = date);  // setState = "redessine l'écran !"
    }
  }

  // 🕐 Sélecteur d'heure
  Future<void> _choisirHeure() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (heure != null) {
      setState(() => _heureChoisie = heure);
    }
  }

  // ✅ Validation : crée le RDV et retourne au planning
  void _valider() {
    if (_prestationChoisie == null || _dateChoisie == null || _heureChoisie == null) {
      // SnackBar = petite bannière d'erreur en bas d'écran
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prestation, date et heure sont obligatoires')),
      );
      return;
    }

    final rdv = RendezVous(
      id: 'r${mockRdvs.length + 1}',
      client: Client(
        id: 'c${mockRdvs.length + 1}',
        nom: _nomController.text,
        prenom: '',
        telephone: _telController.text,
        email: '',
      ),
      prestation: _prestationChoisie!,
      dateHeure: DateTime(
        _dateChoisie!.year, _dateChoisie!.month, _dateChoisie!.day,
        _heureChoisie!.hour, _heureChoisie!.minute,
      ),
    );

     Navigator.of(context).pop(rdv);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau rendez-vous')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Champs texte ───
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: 'Nom du client',
              hintText: 'Ex : Sophie Martin',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _telController,
            keyboardType: TextInputType.phone,   // clavier téléphone
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          const SizedBox(height: 16),

          // ─── Liste déroulante des prestations ───
          DropdownButtonFormField<Prestation>(
            initialValue: _prestationChoisie,
            decoration: const InputDecoration(labelText: 'Prestation'),
            items: mockPrestations.map((p) {
              return DropdownMenuItem(value: p, child: Text('${p.nom} — ${p.prix} €'));
            }).toList(),
            onChanged: (p) => setState(() => _prestationChoisie = p),
          ),
          const SizedBox(height: 16),

          // ─── Date + heure sur la même ligne ───
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _choisirDate,
                  icon: const Icon(Icons.calendar_today),
                  // Affiche la date choisie, ou "Date" si rien
                  label: Text(_dateChoisie == null
                      ? 'Date'
                      : '${_dateChoisie!.day}/${_dateChoisie!.month}/${_dateChoisie!.year}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _choisirHeure,
                  icon: const Icon(Icons.schedule),
                  label: Text(_heureChoisie == null
                      ? 'Heure'
                      : '${_heureChoisie!.hour.toString().padLeft(2, '0')}:${_heureChoisie!.minute.toString().padLeft(2, '0')}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ─── Bouton valider (pleine largeur, déjà stylé par ton thème) ───
          ElevatedButton(
            onPressed: _valider,
            child: const Text('Valider le rendez-vous'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telController.dispose();
    super.dispose();
  }
}