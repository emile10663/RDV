import 'package:flutter/material.dart';
import 'package:mon_application/models/client.dart';
import 'package:mon_application/models/prestation.dart';
import 'package:mon_application/models/rendez_vous.dart';
import 'package:mon_application/widgets/card_rdv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() async {
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
      debugShowCheckedModeBanner: false,   // enlève la bannière "DEBUG"
      theme: AppTheme.light,               // 👈 notre thème premium !
      home: const MainScreen(),
    );
  }
}

// Écran temporaire pour tester le thème (on le remplacera bientôt)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Coiffeur')),
      body: ListView(          // ListView = liste déroulante verticale
   children: [
    CardRdv(
      rdv: RendezVous(
        id: 'rdv-1',
        client: const Client(
          id: 'c1', nom: 'Martin', prenom: 'Sophie',
          telephone: '0612345678', email: 'sophie@mail.fr',
        ),
        prestation: const Prestation(
          id: 'p1', nom: 'Coupe + Brushing', description: '',
          duree: Duration(minutes: 60), prix: 45.0,
        ), dateHeure: DateTime(DateTime.august),
          // ❌ volontaire ! Corrige ça :
      ),
    ),
  ],
),
    );
  }
}