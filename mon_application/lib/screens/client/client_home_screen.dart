import 'package:flutter/material.dart';
import '../../models/salon.dart';
import 'choix_salon_screen.dart';
import 'mes_rdv_screen.dart';
import 'salon_screen.dart';

/// 🧭 Espace client : choix du salon, puis "Le salon" + "Mes RDV"
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _onglet = 0;
  Salon? _salon;

  @override
  Widget build(BuildContext context) {
    final salon = _salon;

    if (salon == null) {
      return ChoixSalonScreen(
        onChoisi: (s) => setState(() {
          _salon = s;
          _onglet = 0;
        }),
      );
    }

    final ecrans = [
      SalonScreen(
        key: ValueKey(salon.id),
        salon: salon,
        onChangerSalon: () => setState(() {
          _salon = null;
        }),
      ),
      const MesRdvScreen(),
    ];

    return Scaffold(
      body: ecrans[_onglet],
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