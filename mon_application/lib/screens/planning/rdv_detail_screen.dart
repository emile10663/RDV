import 'package:flutter/material.dart';
import '../../models/rendez_vous.dart';

/// 📄 Détail d'un rendez-vous
class RdvDetailScreen extends StatelessWidget {
  final RendezVous rdv;

  const RdvDetailScreen({super.key, required this.rdv});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(rdv.prestation.nom)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rdv.client.nomComplet,
                style: textTheme.headlineMedium),
            const SizedBox(height: 20),
            Text('📅  ${rdv.dateFormatee}'),
            const SizedBox(height: 8),
            Text('⏱  ${rdv.prestation.duree.inMinutes} minutes'),
            const SizedBox(height: 8),
            Text('💶  ${rdv.prestation.prix.toStringAsFixed(2)} €'),
            const SizedBox(height: 8),
            Text('📞  ${rdv.client.telephone}'),
          ],
        ),
      ),
    );
  }
}