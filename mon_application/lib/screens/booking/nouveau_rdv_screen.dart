import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/horaires.dart';
import '../../models/client.dart';
import '../../models/prestation.dart';
import '../../models/rendez_vous.dart';
import '../../theme/app_colors.dart';
import '../../widgets/puce_jour.dart';

/// ➕ Écran de création d'un rendez-vous
class NouveauRdvScreen extends StatefulWidget {
  /// Prestations proposées par le salon
  final List<Prestation> prestations;

  /// RDV déjà pris : sert à griser les créneaux occupés
  final List<RendezVous> rdvsExistants;

  /// Jour présélectionné (celui affiché dans le planning)
  final DateTime? jourInitial;

  /// Vrai quand c'est un client qui réserve (téléphone obligatoire, textes adaptés)
  final bool modeClient;

  const NouveauRdvScreen({
    super.key,
    required this.prestations,
    this.rdvsExistants = const [],
    this.jourInitial,
    this.modeClient = false,
  });

  @override
  State<NouveauRdvScreen> createState() => _NouveauRdvScreenState();
}

class _NouveauRdvScreenState extends State<NouveauRdvScreen> {
  static const _nbJours = 45;

  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _telController = TextEditingController();

  late final DateTime _aujourdhui;
  late DateTime _jour;
  late final ScrollController _bandeau;
  Prestation? _prestation;
  TimeOfDay? _heure;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _aujourdhui = DateTime(now.year, now.month, now.day);
    final init = widget.jourInitial;
    _jour = (init == null || init.isBefore(_aujourdhui))
        ? _aujourdhui
        : DateTime(init.year, init.month, init.day);
    final index = DateTime.utc(_jour.year, _jour.month, _jour.day)
        .difference(DateTime.utc(
            _aujourdhui.year, _aujourdhui.month, _aujourdhui.day))
        .inDays;
    _bandeau = ScrollController(
      initialScrollOffset:
          math.max(0, index * (PuceJour.largeur + PuceJour.espace)),
    );
  }

  String? _obligatoire(String? valeur) =>
      (valeur == null || valeur.trim().isEmpty) ? 'Champ obligatoire' : null;

  void _message(String texte) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texte)));
  }

  /// Tous les créneaux de la journée (toutes les 30 min)
  List<TimeOfDay> get _creneaux => [
        for (var h = heureOuverture; h < heureFermeture; h++) ...[
          TimeOfDay(hour: h, minute: 0),
          TimeOfDay(hour: h, minute: 30),
        ],
      ];

  DateTime _debut(TimeOfDay t) =>
      DateTime(_jour.year, _jour.month, _jour.day, t.hour, t.minute);

  /// Un créneau est libre s'il n'est pas passé, tient avant la fermeture
  /// et ne chevauche aucun RDV non annulé
  bool _libre(TimeOfDay t) {
    final debut = _debut(t);
    if (debut.isBefore(DateTime.now())) return false;

    final duree = _prestation?.duree ?? const Duration(minutes: 30);
    final fin = debut.add(duree);
    final fermeture =
        DateTime(_jour.year, _jour.month, _jour.day, heureFermeture);
    if (fin.isAfter(fermeture)) return false;

    return !widget.rdvsExistants
        .where((r) => r.statut != StatutRdv.annule)
        .any((r) => debut.isBefore(r.fin) && fin.isAfter(r.dateHeure));
  }

  /// Si le créneau choisi n'est plus possible (autre jour/prestation), on l'efface
  void _verifierHeure() {
    if (_heure != null && !_libre(_heure!)) _heure = null;
  }

  String _heureTexte(TimeOfDay h) =>
      '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

  void _valider() {
    if (!_formKey.currentState!.validate()) return;
    if (_prestation == null) {
      _message('Choisis une prestation');
      return;
    }
    if (_heure == null) {
      _message('Choisis une heure');
      return;
    }

    final debut = _debut(_heure!);
    if (debut.isBefore(DateTime.now())) {
      _message('Ce créneau est déjà passé');
      return;
    }

    final rdv = RendezVous(
      id: RendezVous.nouvelId(),
      client: Client(
        id: 'c${RendezVous.nouvelId()}',
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telController.text.trim(),
        email: '',
      ),
      prestation: _prestation!,
      dateHeure: debut,
    );

    final conflit = widget.rdvsExistants
        .where((r) => r.statut != StatutRdv.annule)
        .any((r) => r.chevauche(rdv));
    if (conflit) {
      _message('Ce créneau chevauche un autre rendez-vous');
      return;
    }

    Navigator.of(context).pop(rdv);
  }

  @override
  Widget build(BuildContext context) {
    final prestation = _prestation;
    final heure = _heure;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modeClient ? 'Réserver' : 'Nouveau rendez-vous'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ─── 1. Client ───
            const _Titre('Client', numero: 1),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prenomController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: _obligatoire,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nomController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: _obligatoire,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText:
                    widget.modeClient ? 'Téléphone' : 'Téléphone (facultatif)',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: widget.modeClient ? _obligatoire : null,
            ),

            // ─── 2. Prestation ───
            const _Titre('Prestation', numero: 2),
            for (final p in widget.prestations)
              _TuilePrestation(
                prestation: p,
                selected: prestation?.id == p.id,
                onTap: () => setState(() {
                  _prestation = p;
                  _verifierHeure();
                }),
              ),

            // ─── 3. Jour ───
            const _Titre('Jour', numero: 3),
            SizedBox(
              height: 82,
              child: ListView.builder(
                controller: _bandeau,
                scrollDirection: Axis.horizontal,
                itemCount: _nbJours,
                itemBuilder: (context, i) {
                  final jour = DateTime(
                    _aujourdhui.year,
                    _aujourdhui.month,
                    _aujourdhui.day + i,
                  );
                  return PuceJour(
                    jour: jour,
                    selected: jour == _jour,
                    onTap: () => setState(() {
                      _jour = jour;
                      _verifierHeure();
                    }),
                  );
                },
              ),
            ),

            // ─── 4. Heure ───
            const _Titre('Heure', numero: 4),
            if (prestation == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Choisis une prestation pour voir les créneaux disponibles.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _creneaux)
                  _PuceHeure(
                    texte: _heureTexte(t),
                    selected: heure == t,
                    libre: _libre(t),
                    onTap: () => setState(() => _heure = t),
                  ),
              ],
            ),
          ],
        ),
      ),

      // ─── Barre du bas : récapitulatif + bouton ───
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prestation != null && heure != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${DateFormat('EEEE d MMMM', 'fr_FR').format(_jour)} à ${_heureTexte(heure)}'
                      ' · ${prestation.prix.toStringAsFixed(2).replaceAll('.', ',')} €',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _valider,
                  child: Text(widget.modeClient
                      ? 'Envoyer ma demande'
                      : 'Confirmer le rendez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telController.dispose();
    _bandeau.dispose();
    super.dispose();
  }
}

/// Titre de section numéroté
class _Titre extends StatelessWidget {
  final String texte;
  final int numero;

  const _Titre(this.texte, {required this.numero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$numero',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(texte, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Carte cliquable d'une prestation
class _TuilePrestation extends StatelessWidget {
  final Prestation prestation;
  final bool selected;
  final VoidCallback onTap;

  const _TuilePrestation({
    required this.prestation,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final prix = prestation.prix.toStringAsFixed(2).replaceAll('.', ',');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldSoft : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prestation.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (prestation.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      prestation.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${prestation.duree.inMinutes} min',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$prix €',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.goldDark,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? AppColors.primary : AppColors.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Une heure cliquable ("09:30"), grisée si indisponible
class _PuceHeure extends StatelessWidget {
  final String texte;
  final bool selected;
  final bool libre;
  final VoidCallback onTap;

  const _PuceHeure({
    required this.texte,
    required this.selected,
    required this.libre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fond;
    final Color bord;
    final Color couleurTexte;

    if (selected) {
      fond = AppColors.primary;
      bord = AppColors.primary;
      couleurTexte = Colors.white;
    } else if (libre) {
      fond = AppColors.card;
      bord = AppColors.border;
      couleurTexte = AppColors.onSurface;
    } else {
      fond = AppColors.surfaceContainerHigh;
      bord = AppColors.surfaceContainerHigh;
      couleurTexte = AppColors.outline;
    }

    return GestureDetector(
      onTap: libre ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bord),
        ),
        child: Text(
          texte,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: couleurTexte,
            decoration: libre ? null : TextDecoration.lineThrough,
          ),
        ),
      ),
    );
  }
}