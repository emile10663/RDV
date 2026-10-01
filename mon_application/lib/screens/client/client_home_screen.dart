import 'package:flutter/material.dart';
import 'salon_screen.dart';
import 'mes_rdv_screen.dart';

/// 🧭 Espace client : "Le salon" + "Mes RDV"
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _onglet = 0;

  final _ecrans = const [
    SalonScreen(),
    MesRdvScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ecrans[_onglet],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _onglet,
        onDestinationSelected: (i) => setState(() => _onglet = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Le salon',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Mes RDV',
          ),
        ],
      ),
    );
  }
}