import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/salon.dart';
import '../../services/salon_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logo_salon.dart';

/// ✏️ Le coiffeur modifie les informations de son salon.
/// Renvoie le salon mis à jour quand c'est enregistré.
class InfosSalonScreen extends StatefulWidget {
  final Salon salon;

  const InfosSalonScreen({super.key, required this.salon});

  @override
  State<InfosSalonScreen> createState() => _InfosSalonScreenState();
}

class _InfosSalonScreenState extends State<InfosSalonScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nom = TextEditingController(text: widget.salon.nom);
  late final _adresse = TextEditingController(text: widget.salon.adresse);
  late final _telephone = TextEditingController(text: widget.salon.telephone);
  late final _description = TextEditingController(
    text: widget.salon.description,
  );
  late String? _logo = widget.salon.logo;
  bool _envoi = false;
  bool _choixEnCours = false;

  @override
  void dispose() {
    _nom.dispose();
    _adresse.dispose();
    _telephone.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _obligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

  String? _validerTelephone(String? v) {
    final chiffres = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return chiffres.length < 6 ? 'Numéro de téléphone invalide' : null;
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  /// Choisit une image dans la galerie, la réduit (400 px max) et la garde en mémoire.
  /// Elle n'est enregistrée qu'en touchant « Enregistrer ».
  Future<void> _choisirLogo() async {
    setState(() => _choixEnCours = true);
    try {
      final fichier = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      if (fichier == null) return;

      final octets = await fichier.readAsBytes();
      if (octets.length > 150 * 1024) {
        if (mounted) _message('Image trop lourde. Choisis-en une plus petite.');
        return;
      }
      if (!mounted) return;
      setState(() => _logo = base64Encode(octets));
    } catch (e) {
      debugPrint('Erreur choix du logo : $e');
      if (mounted) _message('Impossible de charger cette image.');
    } finally {
      if (mounted) setState(() => _choixEnCours = false);
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _envoi = true);
    try {
      await SalonService.mettreAJourInfos(
        widget.salon.id,
        nom: _nom.text.trim(),
        adresse: _adresse.text.trim(),
        telephone: _telephone.text.trim(),
        description: _description.text.trim(),
        logo: _logo,
      );
      if (!mounted) return;
      Navigator.of(context).pop(
        widget.salon.copyWith(
          nom: _nom.text.trim(),
          adresse: _adresse.text.trim(),
          telephone: _telephone.text.trim(),
          description: _description.text.trim(),
          logo: _logo,
          retirerLogo: _logo == null,
        ),
      );
    } catch (e) {
      debugPrint('Erreur modification salon : $e');
      if (!mounted) return;
      setState(() => _envoi = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'enregistrer les informations.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informations du salon')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ─── Logo ───
            Center(
              child: LogoSalon(
                logo: _logo,
                taille: 110,
                degrade: AppColors.enTete,
                couleurIcone: AppColors.accent,
                bordure: AppColors.accent,
                largeurBordure: 3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _choixEnCours || _envoi ? null : _choisirLogo,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  icon: _choixEnCours
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image_outlined, size: 18),
                  label: Text(_logo == null ? 'Choisir un logo' : 'Changer le logo'),
                ),
                if (_logo != null)
                  TextButton(
                    onPressed: _envoi ? null : () => setState(() => _logo = null),
                    child: const Text('Retirer'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nom,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              decoration: const InputDecoration(labelText: 'Nom du salon'),
              validator: _obligatoire,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _adresse,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Adresse'),
              validator: _obligatoire,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _telephone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Téléphone'),
              validator: _validerTelephone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLength: 200,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Présentation du salon (facultatif)',
                helperText: 'Visible par les clients sur la page du salon.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
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
      ),
    );
  }
}