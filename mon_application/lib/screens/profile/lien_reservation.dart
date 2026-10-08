import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config.dart';
import '../../models/salon.dart';
import '../../theme/app_colors.dart';

/// 🔗 Affiche le lien de réservation du salon + son QR code
Future<void> afficherLienReservation(BuildContext context, Salon salon) {
  final lien = lienSalon(salon.id);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Réserver chez ${salon.nom}',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Montrez ce QR code ou envoyez le lien à vos clients.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: QrImageView(
                data: lien,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.secondary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(
              lien,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: lien));
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Lien copié')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copier le lien'),
            ),
          ],
        ),
      ),
    ),
  );
}