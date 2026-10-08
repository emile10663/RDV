import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/avis.dart';
import '../../models/salon.dart';
import '../../services/avis_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/etoiles.dart';

/// ⭐ Tous les avis d'un salon (le coiffeur peut retirer un avis abusif)
class AvisScreen extends StatefulWidget {
  final Salon salon;
  final bool estCoiffeur;

  const AvisScreen({super.key, required this.salon, this.estCoiffeur = false});

  @override
  State<AvisScreen> createState() => _AvisScreenState();
}

class _AvisScreenState extends State<AvisScreen> {
  List<Avis> _avis = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final liste = await AvisService.charger(widget.salon.id);
      if (!mounted) return;
      setState(() {
        _avis = liste;
        _chargement = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement avis : $e');
      if (!mounted) return;
      setState(() {
        _chargement = false;
        _erreur = 'Impossible de charger les avis.';
      });
    }
  }

  Future<void> _supprimer(Avis avis) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet avis ?'),
        content: const Text('Il ne sera plus visible par les clients.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Oui, supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      await AvisService.supprimer(widget.salon.id, avis.id);
      await _charger();
    } catch (e) {
      debugPrint('Erreur suppression avis : $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer l\'avis.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moyenne = moyenneAvis(_avis);

    return Scaffold(
      appBar: AppBar(title: const Text('Avis clients')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : _erreur != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_erreur!),
                      TextButton(
                        onPressed: _charger,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Text(
                              _avis.isEmpty ? '–' : noteTexte(moyenne),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(fontSize: 40),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Etoiles(note: moyenne, taille: 22),
                                  const SizedBox(height: 4),
                                  Text(
                                    _avis.isEmpty
                                        ? 'Pas encore d\'avis'
                                        : '${_avis.length} avis',
                                    style: const TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final a in _avis)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CarteAvis(
                          avis: a,
                          onSupprimer: widget.estCoiffeur
                              ? () => _supprimer(a)
                              : null,
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _CarteAvis extends StatelessWidget {
  final Avis avis;
  final VoidCallback? onSupprimer;

  const _CarteAvis({required this.avis, this.onSupprimer});

  @override
  Widget build(BuildContext context) {
    final date = avis.date == null
        ? ''
        : DateFormat('d MMM y', 'fr_FR').format(avis.date!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    avis.prenom.isEmpty ? 'Client' : avis.prenom,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (onSupprimer != null)
                  IconButton(
                    tooltip: 'Supprimer cet avis',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onSupprimer,
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
            Etoiles(note: avis.note.toDouble(), taille: 18),
            if (avis.commentaire.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(avis.commentaire),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ⭐ Petite carte "Avis clients · 4,8 / 5" qui ouvre la liste des avis
class CarteAvisSalon extends StatefulWidget {
  final Salon salon;
  final bool estCoiffeur;

  const CarteAvisSalon({
    super.key,
    required this.salon,
    this.estCoiffeur = false,
  });

  @override
  State<CarteAvisSalon> createState() => _CarteAvisSalonState();
}

class _CarteAvisSalonState extends State<CarteAvisSalon> {
  late Future<List<Avis>> _futur = AvisService.charger(widget.salon.id);

  Future<void> _ouvrir() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AvisScreen(salon: widget.salon, estCoiffeur: widget.estCoiffeur),
      ),
    );
    if (!mounted) return;
    final nouveau = AvisService.charger(widget.salon.id);
    setState(() {
      _futur = nouveau;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Avis>>(
      future: _futur,
      builder: (context, snap) {
        String texte;
        double moyenne = 0;
        if (snap.connectionState != ConnectionState.done) {
          texte = 'Chargement…';
        } else if (snap.hasError) {
          texte = 'Avis indisponibles pour le moment';
        } else {
          final liste = snap.data ?? [];
          moyenne = moyenneAvis(liste);
          texte = liste.isEmpty
              ? 'Pas encore d\'avis'
              : '${noteTexte(moyenne)} / 5 · ${liste.length} avis';
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.star_rounded, color: couleurEtoile),
            title: const Text('Avis clients'),
            subtitle: Text(texte),
            trailing: const Icon(Icons.chevron_right),
            onTap: _ouvrir,
          ),
        );
      },
    );
  }
}