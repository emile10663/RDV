import 'package:flutter/material.dart';

/// 👤 Profil du coiffeur
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Mon Salon',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Coiffeur & Barbier',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            const Text('Version 1.0 🎉'),
          ],
        ),
      ),
    );
  }
}