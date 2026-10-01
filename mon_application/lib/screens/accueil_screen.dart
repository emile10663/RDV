import 'package:flutter/material.dart';
import 'package:mon_application/screens/client/client_home_screen.dart';
import 'package:mon_application/screens/main_screen.dart';
import 'package:mon_application/theme/app_colors.dart';

/// 👋 Premier écran : "Je suis client" ou "Je suis coiffeur"
class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

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
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 3),
                    ),
                    child: const Icon(Icons.content_cut,
                        size: 40, color: AppColors.gold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'MON SALON',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bienvenue',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Réserve ta coupe en quelques secondes,\nou gère ton salon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 40),
                  _ChoixCarte(
                    icone: Icons.event_available,
                    titre: 'Je suis client',
                    sousTitre: 'Prendre un rendez-vous',
                    clair: true,
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ClientHomeScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ChoixCarte(
                    icone: Icons.content_cut,
                    titre: 'Je suis coiffeur',
                    sousTitre: 'Gérer mon planning',
                    clair: false,
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainScreen()),
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

/// Grande carte de choix
class _ChoixCarte extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final bool clair;
  final VoidCallback onTap;

  const _ChoixCarte({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.clair,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fond = clair ? Colors.white : Colors.white.withValues(alpha: 0.08);
    final texte = clair ? AppColors.onSurface : Colors.white;
    final discret = clair ? AppColors.onSurfaceVariant : Colors.white70;

    return Material(
      color: fond,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: clair ? Colors.transparent : AppColors.gold,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: clair ? AppColors.primary : AppColors.gold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icone,
                  color: clair ? AppColors.gold : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: texte,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(sousTitre, style: TextStyle(color: discret)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: discret),
            ],
          ),
        ),
      ),
    );
  }
}