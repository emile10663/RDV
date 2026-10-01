import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'screens/accueil_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  // Démarre la connexion à Firebase avant d'afficher l'appli
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MonCoiffeurApp());
}

class MonCoiffeurApp extends StatelessWidget {
  const MonCoiffeurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Coiffeur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AccueilScreen(), // on choisit d'abord : client ou coiffeur
    );
  }
}