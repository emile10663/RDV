import 'package:flutter/material.dart';
import '../../data/horaires.dart';
import '../../data/mock_rdvs.dart';
import '../../theme/app_colors.dart';
import '../accueil_screen.dart';

/// 👤 Profil du salon
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;
    final h = (int heure) => '${heure.toString().padLeft(2, '0')}:00';

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, haut + 24, 16, 24),
        children: [
          // ─── Identité ───
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.enTete,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 3),
              ),
              child: const Icon(Icons.content_cut,
                  size: 40, color: AppColors.gold),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Mon Salon',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Coiffeur & Barbier',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 28),

          // ─── Horaires ───
          Text('Horaires', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule, color: AppColors.goldDark),
              title: const Text('Créneaux proposés'),
              trailing: Text(
                '${h(heureOuverture)} – ${h(heureFermeture)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Prestations ───
          Text('Prestations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final p in mockPrestations)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  title: Text(
                    p.nom,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${p.duree.inMinutes} min'),
                  trailing: Text(
                    '${p.prix.toStringAsFixed(2).replaceAll('.', ',')} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AccueilScreen()),
              (_) => false,
            ),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Changer de mode'),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Version 1.0',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}