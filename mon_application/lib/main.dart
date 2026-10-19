import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mon_application/services/notification_service.dart';

import 'firebase_options.dart';
import 'screens/accueil_screen.dart';
import 'screens/client/client_home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  // Démarre la connexion à Firebase avant d'afficher l'appli
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ← Ajoute ces lignes
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MonCoiffeurApp());
}

class MonCoiffeurApp extends StatelessWidget {
  const MonCoiffeurApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lien de réservation : https://.../?salon=IDENTIFIANT
    final salonId = Uri.base.queryParameters['salon'];
    final viensDUnLien = salonId != null && salonId.isNotEmpty;

    return MaterialApp(
      title: 'Mon Coiffeur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: viensDUnLien
          ? ClientHomeScreen(salonIdInitial: salonId)
          : const AccueilScreen(), // sinon on choisit : client ou coiffeur
    );
  }
}