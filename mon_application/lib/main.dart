import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/accueil_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
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
      home: const AccueilScreen(), // 👈 on choisit d'abord : client ou coiffeur
    );
  }
}