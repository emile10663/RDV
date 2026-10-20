import 'package:flutter/material.dart';

import '../../models/horaires_salon.dart';
import '../../models/prestation.dart';
import '../../models/salon.dart';
import '../../services/auth_service.dart';
import '../../services/prestation_service.dart';
import '../../services/salon_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logo_salon.dart';
import '../../utils/prix.dart';
import '../accueil_screen.dart';
import '../avis/avis_screen.dart';
import '../client/clients_screen.dart';
import 'horaires_screen.dart';
import 'infos_salon_screen.dart';
import 'lien_reservation.dart';
import 'prestation_form.dart';

/// 👤 Profil du salon
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Salon? _salon;
  List<Prestation> _prestations = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final salon = await SalonService.salonDuCoiffeur();
      final prestations = salon == null
          ? <Prestation>[]
          : await PrestationService.charger(salon.id);
      if (!mounted) return;
      setState(() {
        _salon = salon;
        _prestations = prestations;
        _chargement = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement profil : $e');
      if (!mounted) return;
      setState(() {
        _erreur = 'Impossible de charger les données du salon.';
        _chargement = false;
      });
    }
  }

  Future<void> _modifierHoraires(Salon salon) async {
    final nouveaux = await Navigator.of(context).push<HorairesSalon>(
      MaterialPageRoute(builder: (_) => HorairesScreen(salon: salon)),
    );
    if (nouveaux == null || !mounted) return;
    setState(() {
      _salon = salon.copyWith(horaires: nouveaux);
    });
    _message('Horaires enregistrés.');
  }

  Future<void> _modifierInfos(Salon salon) async {
    final modifie = await Navigator.of(context).push<Salon>(
      MaterialPageRoute(builder: (_) => InfosSalonScreen(salon: salon)),
    );
    if (modifie == null || !mounted) return;
    setState(() {
      _salon = modifie;
    });
    _message('Informations enregistrées.');
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  Future<void> _rechargerPrestations() async {
    final salon = _salon;
    if (salon == null) return;
    final liste = await PrestationService.charger(salon.id);
    if (!mounted) return;
    setState(() {
      _prestations = liste;
    });
  }

  /// Ajoute (existante == null) ou modifie une prestation
  Future<void> _editer([Prestation? existante]) async {
    final salon = _salon;
    if (salon == null) return;

    final resultat = await afficherFormulairePrestation(
      context,
      existante: existante,
    );
    if (resultat == null) return;

    try {
      await PrestationService.enregistrer(salon.id, resultat);
      await _rechargerPrestations();
    } catch (e) {
      debugPrint('Erreur enregistrement prestation : $e');
      if (mounted) _message('Impossible d\'enregistrer la prestation.');
    }
  }

  Future<void> _supprimer(Prestation p) async {
    final salon = _salon;
    if (salon == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la prestation ?'),
        content: Text(p.nom),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await PrestationService.supprimer(salon.id, p.id);
      await _rechargerPrestations();
    } catch (e) {
      debugPrint('Erreur suppression prestation : $e');
      if (mounted) _message('Impossible de supprimer la prestation.');
    }
  }

  Future<void> _deconnecter() async {
    await AuthService.deconnecter();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccueilScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final haut = MediaQuery.of(context).padding.top;
    final salon = _salon;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, haut + 24, 16, 24),
        children: [
          // ─── Identité ───
          Center(
            child: LogoSalon(
              logo: salon?.logo,
              taille: 96,
              degrade: AppColors.enTete,
              couleurIcone: AppColors.accent,
              bordure: AppColors.accent,
              largeurBordure: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            salon?.nom ?? 'Mon Salon',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (salon != null) ...[
            const SizedBox(height: 4),
            Text(
              salon.adresse,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.primary,
                ),
                title: Text(salon.telephone),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_2, color: AppColors.primary),
                title: const Text('Lien et QR code de réservation'),
                subtitle: const Text('À partager avec vos clients'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => afficherLienReservation(context, salon),
              ),
            ),
            const SizedBox(height: 10),
            CarteAvisSalon(salon: salon, estCoiffeur: true),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.people_outline,
                  color: AppColors.primary,
                ),
                title: const Text('Mes clients'),
                subtitle: const Text('Ceux qui ont pris rendez-vous chez vous'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ClientsScreen(salon: salon),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Informations du salon'),
                subtitle: const Text('Nom, adresse, téléphone, présentation'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _modifierInfos(salon),
              ),
            ),
          ],
          const SizedBox(height: 28),

          // ─── Horaires ───
          Text('Horaires', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (salon != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule, color: AppColors.primary),
                title: const Text('Horaires et congés'),
                subtitle: Text(
                  '${salon.horaires.joursOuverts} jours ouverts par semaine',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _modifierHoraires(salon),
              ),
            ),
          const SizedBox(height: 24),

          // ─── Prestations ───
          Row(
            children: [
              Expanded(
                child: Text(
                  'Prestations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (salon != null)
                TextButton.icon(
                  onPressed: () => _editer(),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_chargement)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_erreur != null)
            Column(
              children: [
                Text(_erreur!),
                TextButton(onPressed: _charger, child: const Text('Réessayer')),
              ],
            )
          else if (_prestations.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Aucune prestation pour l\'instant'),
                subtitle: Text(
                  'Appuie sur « Ajouter » pour créer la première.',
                ),
              ),
            )
          else
            for (final p in _prestations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    title: Text(
                      p.nom,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${p.duree.inMinutes} min'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatPrix(p.prix),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (choix) {
                            if (choix == 'modifier') _editer(p);
                            if (choix == 'supprimer') _supprimer(p);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'modifier',
                              child: Text('Modifier'),
                            ),
                            PopupMenuItem(
                              value: 'supprimer',
                              child: Text('Supprimer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AccueilScreen()),
              (_) => false,
            ),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Changer de mode'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _deconnecter,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Version 1.0',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}