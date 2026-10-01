import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/salon_service.dart';
import '../../theme/app_colors.dart';

/// 🏪 Création du salon (une seule fois, à la première connexion)
class CreerSalonScreen extends StatefulWidget {
  /// Appelée quand le salon est créé, pour que l'appli continue
  final VoidCallback onSalonCree;

  const CreerSalonScreen({super.key, required this.onSalonCree});

  @override
  State<CreerSalonScreen> createState() => _CreerSalonScreenState();
}

class _CreerSalonScreenState extends State<CreerSalonScreen> {
  final _nom = TextEditingController();
  final _adresse = TextEditingController();
  final _telephone = TextEditingController();
  bool _chargement = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _adresse.dispose();
    _telephone.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    final nom = _nom.text.trim();
    final adresse = _adresse.text.trim();
    final telephone = _telephone.text.trim();

    if (nom.isEmpty || adresse.isEmpty || telephone.isEmpty) {
      setState(() => _erreur = 'Remplis les trois champs.');
      return;
    }

    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      await SalonService.creer(
        nom: nom,
        adresse: adresse,
        telephone: telephone,
      );
      widget.onSalonCree();
    } catch (e) {
      debugPrint('Erreur création salon : $e');
      if (mounted) {
        setState(() => _erreur =
            'Impossible de créer le salon. Vérifie ta connexion et les règles Firestore.');
      }
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.enTete),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Crée ton salon',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ces informations seront visibles par tes clients.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nom,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nom du salon',
                            prefixIcon: Icon(Icons.storefront_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _adresse,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Adresse',
                            prefixIcon: Icon(Icons.place_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _telephone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (_erreur != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _erreur!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: _chargement ? null : _creer,
                          child: _chargement
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text('Créer mon salon'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _chargement ? null : AuthService.deconnecter,
                    child: const Text('Se déconnecter',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}