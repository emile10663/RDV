import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/salon.dart';
import '../../services/auth_service.dart';
import '../../services/salon_service.dart';
import '../main_screen.dart';
import 'connexion_screen.dart';
import 'creer_salon_screen.dart';

/// 🚪 Porte d'entrée de l'espace coiffeur. Elle décide quoi afficher :
///   pas connecté (ou simple client) → écran de connexion
///   connecté sans salon             → création du salon
///   connecté avec salon             → le planning (MainScreen)
class PorteCoiffeur extends StatelessWidget {
  const PorteCoiffeur({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.changements,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Chargement();
        }
        final user = snap.data;
        // Une session anonyme est celle d'un client : pas d'accès coiffeur
        if (user == null || user.isAnonymous) return const ConnexionScreen();
        // La clé force un rechargement si un autre coiffeur se connecte
        return _ChargementSalon(key: ValueKey(user.uid));
      },
    );
  }
}

class _ChargementSalon extends StatefulWidget {
  const _ChargementSalon({super.key});

  @override
  State<_ChargementSalon> createState() => _ChargementSalonState();
}

class _ChargementSalonState extends State<_ChargementSalon> {
  late Future<Salon?> _futur = SalonService.salonDuCoiffeur();

  void _recharger() {
    final nouveau = SalonService.salonDuCoiffeur();
    setState(() {
      _futur = nouveau;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Salon?>(
      future: _futur,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const _Chargement();
        }

        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Impossible de charger ton salon.\n${snap.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _recharger, child: const Text('Réessayer')),
                    TextButton(
                        onPressed: AuthService.deconnecter,
                        child: const Text('Se déconnecter')),
                  ],
                ),
              ),
            ),
          );
        }

        if (snap.data == null) {
          return CreerSalonScreen(onSalonCree: _recharger);
        }
        return const MainScreen();
      },
    );
  }
}

class _Chargement extends StatelessWidget {
  const _Chargement();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}