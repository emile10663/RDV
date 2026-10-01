import 'package:flutter/material.dart';
import '../../models/prestation.dart';

/// Ouvre le formulaire d'ajout / de modification d'une prestation.
/// Renvoie la prestation saisie, ou null si l'utilisateur annule.
Future<Prestation?> afficherFormulairePrestation(
  BuildContext context, {
  Prestation? existante,
}) {
  return showModalBottomSheet<Prestation>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FormulairePrestation(existante: existante),
  );
}

class _FormulairePrestation extends StatefulWidget {
  final Prestation? existante;

  const _FormulairePrestation({this.existante});

  @override
  State<_FormulairePrestation> createState() => _FormulairePrestationState();
}

class _FormulairePrestationState extends State<_FormulairePrestation> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _description;
  late final TextEditingController _duree;
  late final TextEditingController _prix;

  @override
  void initState() {
    super.initState();
    final p = widget.existante;
    _nom = TextEditingController(text: p?.nom ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _duree = TextEditingController(text: p == null ? '30' : '${p.duree.inMinutes}');
    _prix = TextEditingController(
      text: p == null ? '' : p.prix.toStringAsFixed(2).replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _duree.dispose();
    _prix.dispose();
    super.dispose();
  }

  String? _obligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

  String? _validerDuree(String? v) {
    final minutes = int.tryParse((v ?? '').trim());
    if (minutes == null || minutes < 5 || minutes > 480) {
      return 'Entre 5 et 480 minutes';
    }
    return null;
  }

  String? _validerPrix(String? v) {
    final prix = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (prix == null || prix < 0) return 'Prix invalide';
    return null;
  }

  void _valider() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      Prestation(
        id: widget.existante?.id ?? '',
        nom: _nom.text.trim(),
        description: _description.text.trim(),
        duree: Duration(minutes: int.parse(_duree.text.trim())),
        prix: double.parse(_prix.text.trim().replaceAll(',', '.')),
        imageUrl: widget.existante?.imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clavier = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + clavier),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existante == null
                    ? 'Nouvelle prestation'
                    : 'Modifier la prestation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nom,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: _obligatoire,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    const InputDecoration(labelText: 'Description (facultatif)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _duree,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Durée (minutes)'),
                      validator: _validerDuree,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _prix,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Prix (€)'),
                      validator: _validerPrix,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _valider,
                child: Text(widget.existante == null ? 'Ajouter' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}