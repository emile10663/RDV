import 'package:flutter/material.dart';
import '../../models/rendez_vous.dart';
import '../../services/avis_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/etoiles.dart';

/// ✍️ Fenêtre où le client donne son avis. Renvoie true si l'avis est envoyé.
Future<bool?> donnerAvis(BuildContext context, RendezVous rdv) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _FormulaireAvis(rdv: rdv),
  );
}

class _FormulaireAvis extends StatefulWidget {
  final RendezVous rdv;

  const _FormulaireAvis({required this.rdv});

  @override
  State<_FormulaireAvis> createState() => _FormulaireAvisState();
}

class _FormulaireAvisState extends State<_FormulaireAvis> {
  final _commentaire = TextEditingController();
  int _note = 0;
  bool _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    _commentaire.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    if (_note == 0) {
      setState(() => _erreur = 'Choisis une note de 1 à 5 étoiles.');
      return;
    }
    setState(() {
      _envoi = true;
      _erreur = null;
    });

    try {
      await AvisService.donner(
        widget.rdv,
        note: _note,
        commentaire: _commentaire.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('Erreur envoi avis : $e');
      if (!mounted) return;
      setState(() {
        _envoi = false;
        _erreur = 'Impossible d\'envoyer ton avis. Réessaie.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clavier = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 4, 24, 24 + clavier),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ton avis compte',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              widget.rdv.prestation.nom,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            EtoilesChoix(
              note: _note,
              onChanged: (n) => setState(() {
                _note = n;
                _erreur = null;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentaire,
              maxLength: 500,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Un commentaire (facultatif)',
                alignLabelWithHint: true,
              ),
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 4),
              Text(_erreur!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _envoi ? null : _envoyer,
              child: _envoi
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Envoyer mon avis'),
            ),
          ],
        ),
      ),
    );
  }
}