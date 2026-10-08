import 'package:flutter/material.dart';
import '../../models/salon.dart';
import '../../services/salon_service.dart';
import 'choix_salon_screen.dart';
import 'mes_rdv_screen.dart';
import 'salon_screen.dart';

/// 🧭 Espace client : choix du salon, puis "Le salon" + "Mes RDV"
class ClientHomeScreen extends StatefulWidget {
  /// Salon à ouvrir directement (quand le client arrive par un lien / QR code)
  final String? salonIdInitial;

  const ClientHomeScreen({super.key, this.salonIdInitial});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _onglet = 0;
  Salon? _salon;
  late bool _ouverture = widget.salonIdInitial != null;

  @override
  void initState() {
    super.initState();
    final id = widget.salonIdInitial;
    if (id != null) _ouvrirSalon(id);
  }

  /// Ouvre le salon du lien ; s'il est introuvable, on affiche la liste
  Future<void> _ouvrirSalon(String id) async {
    Salon? trouve;
    try {
      trouve = await SalonService.parId(id);
    } catch (e) {
      debugPrint('Erreur ouverture salon du lien : $e');
    }
    if (!mounted) return;
    setState(() {
      _salon = trouve;
      _ouverture = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ouverture) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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