import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../accueil_screen.dart';

/// 🔑 Connexion / inscription du coiffeur
class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _inscription = false; // false = connexion, true = inscription
  bool _chargement = false;
  bool _mdpCache = true;
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final email = _email.text.trim();
    final mdp = _motDePasse.text;

    if (email.isEmpty || mdp.isEmpty) {
      setState(() => _erreur = 'Remplis l\'e-mail et le mot de passe.');
      return;
    }

    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      if (_inscription) {
        await AuthService.inscrire(email, mdp);
      } else {
        await AuthService.connecter(email, mdp);
      }
      // Rien d'autre à faire : l'appli détecte la connexion toute seule
    } catch (e) {
      if (mounted) setState(() => _erreur = AuthService.messageErreur(e));
    } finally {
      if (mounted) setState(() => _chargement = false);
    }
  }

  /// Ouvre la fenêtre « Mot de passe oublié ? »
  Future<void> _motDePasseOublie() {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          _DialogReinitialisation(emailInitial: _email.text.trim()),
    );
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 3),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      size: 34,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _inscription ? 'Créer mon compte' : 'Espace coiffeur',
                    style: Theme.of(context).textTheme.headlineMedium!
                        .copyWith(color: Colors.white),
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
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.mail_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _motDePasse,
                          obscureText: _mdpCache,
                          onSubmitted: (_) => _valider(),
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mdpCache
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _mdpCache = !_mdpCache),
                            ),
                          ),
                        ),
                        if (!_inscription)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _chargement ? null : _motDePasseOublie,
                              child: const Text('Mot de passe oublié ?'),
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
                          onPressed: _chargement ? null : _valider,
                          child: _chargement
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _inscription
                                      ? 'Créer mon compte'
                                      : 'Se connecter',
                                ),
                        ),
                        TextButton(
                          onPressed: _chargement
                              ? null
                              : () => setState(() {
                                  _inscription = !_inscription;
                                  _erreur = null;
                                }),
                          child: Text(
                            _inscription
                                ? 'J\'ai déjà un compte'
                                : 'Pas de compte ? Créer le mien',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AccueilScreen()),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    label: const Text(
                      'Retour',
                      style: TextStyle(color: Colors.white70),
                    ),
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

/// 📧 Fenêtre « Mot de passe oublié » : on entre son e-mail et on reçoit un lien
class _DialogReinitialisation extends StatefulWidget {
  final String emailInitial;

  const _DialogReinitialisation({required this.emailInitial});

  @override
  State<_DialogReinitialisation> createState() =>
      _DialogReinitialisationState();
}

class _DialogReinitialisationState extends State<_DialogReinitialisation> {
  late final TextEditingController _email = TextEditingController(
    text: widget.emailInitial,
  );
  bool _envoi = false;
  bool _envoye = false;
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _erreur = 'Entre une adresse e-mail valide.');
      return;
    }

    setState(() {
      _envoi = true;
      _erreur = null;
    });

    try {
      await AuthService.envoyerReinitialisation(email);
      if (!mounted) return;
      setState(() {
        _envoi = false;
        _envoye = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _envoi = false;
        _erreur = AuthService.messageErreur(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_envoye) {
      return AlertDialog(
        title: const Text('Vérifie ta boîte mail'),
        content: Text(
          'Si un compte existe avec ${_email.text.trim()}, un message vient '
          'd\'être envoyé avec un lien pour choisir un nouveau mot de passe.\n\n'
          'Pense à regarder dans les courriers indésirables (spam).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Mot de passe oublié ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Entre l\'e-mail de ton compte. Tu recevras un lien pour '
            'choisir un nouveau mot de passe.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            onSubmitted: (_) => _envoi ? null : _envoyer(),
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.mail_outline),
              border: OutlineInputBorder(),
            ),
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 10),
            Text(_erreur!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _envoi ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _envoi ? null : _envoyer,
          child: _envoi
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Envoyer le lien'),
        ),
      ],
    );
  }
}