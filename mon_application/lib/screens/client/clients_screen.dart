import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/rendez_vous.dart';
import '../../models/salon.dart';
import '../../services/rdv_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/prix.dart';
import '../../widgets/statut_rdv_style.dart';

/// 👥 Les clients du salon : tous ceux qui ont pris rendez-vous (RDV non annulés).
/// Calculé à partir des rendez-vous, rien de plus à enregistrer.
class ClientsScreen extends StatefulWidget {
  final Salon salon;

  const ClientsScreen({super.key, required this.salon});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

/// Un client = tous ses rendez-vous regroupés
class _FicheClient {
  final String nom;
  final String telephone;
  final String email;
  final List<RendezVous> rdvs; // du plus récent au plus ancien

  const _FicheClient({
    required this.nom,
    required this.telephone,
    required this.email,
    required this.rdvs,
  });

  DateTime get dernier => rdvs.first.dateHeure;

  double get totalDepense => rdvs
      .where((r) => r.statut == StatutRdv.termine)
      .fold(0.0, (total, r) => total + r.prestation.prix);
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _recherche = TextEditingController();
  StreamSubscription<List<RendezVous>>? _abonnement;
  List<RendezVous> _rdvs = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _ecouter();
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    _recherche.dispose();
    super.dispose();
  }

  void _ecouter() {
    _abonnement?.cancel();
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    _abonnement = RdvService.ecouterSalon(widget.salon.id).listen(
      (liste) {
        if (!mounted) return;
        setState(() {
          _rdvs = liste;
          _chargement = false;
        });
      },
      onError: (Object e) {
        debugPrint('Erreur liste clients : $e');
        if (!mounted) return;
        setState(() {
          _chargement = false;
          _erreur = 'Impossible de charger les clients.';
        });
      },
    );
  }

  /// Même téléphone = même client (sinon e-mail, sinon nom)
  static String _cle(RendezVous r) {
    final tel = r.client.telephone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (tel.isNotEmpty) return tel;
    final email = r.client.email.trim().toLowerCase();
    if (email.isNotEmpty) return email;
    return r.client.nomComplet.toLowerCase();
  }

  List<_FicheClient> _fiches() {
    final groupes = <String, List<RendezVous>>{};
    for (final r in _rdvs.where((r) => r.statut != StatutRdv.annule)) {
      groupes.putIfAbsent(_cle(r), () => []).add(r);
    }

    final requete = _recherche.text.trim().toLowerCase();
    final fiches = <_FicheClient>[];
    for (final liste in groupes.values) {
      liste.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
      final c = liste.first.client;
      final fiche = _FicheClient(
        nom: c.nomComplet,
        telephone: c.telephone,
        email: c.email,
        rdvs: liste,
      );
      if (requete.isEmpty ||
          fiche.nom.toLowerCase().contains(requete) ||
          fiche.telephone.replaceAll(' ', '').contains(requete)) {
        fiches.add(fiche);
      }
    }
    fiches.sort((a, b) => b.dernier.compareTo(a.dernier));
    return fiches;
  }

  void _ouvrirFiche(_FicheClient fiche) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _FicheClientSheet(fiche: fiche),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fiches = _chargement || _erreur != null ? <_FicheClient>[] : _fiches();
    final aucunClient = _rdvs.every((r) => r.statut == StatutRdv.annule);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes clients')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : _erreur != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_erreur!),
                      TextButton(
                        onPressed: _ecouter,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : aucunClient
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Aucun client pour le moment.\n'
                          'Ils apparaissent ici dès leur premier rendez-vous.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        TextField(
                          controller: _recherche,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Rechercher un nom ou un numéro',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fiches.length <= 1
                              ? '${fiches.length} client'
                              : '${fiches.length} clients',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final f in fiches)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  child: Text(
                                    f.nom.isEmpty ? '?' : f.nom[0].toUpperCase(),
                                  ),
                                ),
                                title: Text(
                                  f.nom.isEmpty ? 'Client' : f.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${f.rdvs.length} rendez-vous'
                                  ' · dernier le '
                                  '${DateFormat('d MMM y', 'fr_FR').format(f.dernier)}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _ouvrirFiche(f),
                              ),
                            ),
                          ),
                        if (fiches.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Center(child: Text('Aucun résultat.')),
                          ),
                      ],
                    ),
    );
  }
}

/// Détail d'un client : coordonnées, total et historique de ses rendez-vous
class _FicheClientSheet extends StatelessWidget {
  final _FicheClient fiche;

  const _FicheClientSheet({required this.fiche});

  void _copier(BuildContext context, String texte, String message) {
    Clipboard.setData(ClipboardData(text: texte));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final hauteurMax = MediaQuery.of(context).size.height * 0.8;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: hauteurMax),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text(
              fiche.nom.isEmpty ? 'Client' : fiche.nom,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (fiche.telephone.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined),
                title: Text(fiche.telephone),
                trailing: IconButton(
                  tooltip: 'Copier le numéro',
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () =>
                      _copier(context, fiche.telephone, 'Numéro copié'),
                ),
              ),
            if (fiche.email.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline),
                title: Text(fiche.email),
                trailing: IconButton(
                  tooltip: 'Copier l\'e-mail',
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () =>
                      _copier(context, fiche.email, 'E-mail copié'),
                ),
              ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _Chiffre(
                        valeur: '${fiche.rdvs.length}',
                        titre: 'Rendez-vous',
                      ),
                    ),
                    Expanded(
                      child: _Chiffre(
                        valeur: formatPrix(fiche.totalDepense),
                        titre: 'Déjà payé',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Historique', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final r in fiche.rdvs)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(r.prestation.nom),
                subtitle: Text(
                  DateFormat('EEE d MMM y · HH:mm', 'fr_FR').format(r.dateHeure),
                ),
                trailing: Text(
                  r.statut.libelle,
                  style: TextStyle(
                    color: r.statut.couleur,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chiffre extends StatelessWidget {
  final String valeur;
  final String titre;

  const _Chiffre({required this.valeur, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valeur,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          titre,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}