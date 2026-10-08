import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/client.dart';
import '../models/prestation.dart';
import '../models/rendez_vous.dart';
import 'base_donnees.dart';

/// Levée quand le créneau demandé vient d'être pris par quelqu'un d'autre
class CreneauPrisException implements Exception {
  final String message;
  const CreneauPrisException([
    this.message = "Ce créneau vient d'être pris. Choisis un autre horaire.",
  ]);

  @override
  String toString() => message;
}

/// 📅 Les rendez-vous dans Firestore
///   rdvs/{id}                          → le RDV complet (nom, téléphone…)
///   salons/{salonId}/creneaux/{bloc}   → un document par bloc de 30 min occupé
///                                        (lisible par tous, sans aucun nom).
///   L'identifiant du bloc = son heure de début : si deux personnes réservent
///   en même temps, la deuxième est refusée par Firestore.
class RdvService {
  static const _delai = Duration(seconds: 15);
  static const _bloc = Duration(minutes: 30);

  /// Heures de début des blocs de 30 min occupés par ce RDV
  static List<DateTime> _blocs(RendezVous rdv) {
    final d = rdv.dateHeure;
    final debut = DateTime(d.year, d.month, d.day, d.hour, d.minute - d.minute % 30);
    final minutes = rdv.prestation.duree.inMinutes;
    final nombre = minutes <= 0 ? 1 : (minutes + 29) ~/ 30;
    return [for (var i = 0; i < nombre; i++) debut.add(_bloc * i)];
  }

  static String _idBloc(DateTime debut) =>
      debut.millisecondsSinceEpoch.toString();

  static CollectionReference<Map<String, dynamic>> get _rdvs =>
      BaseDonnees.db.collection('rdvs');

  static CollectionReference<Map<String, dynamic>> _creneaux(String salonId) =>
      BaseDonnees.db.collection('salons').doc(salonId).collection('creneaux');

  /// Convertit un document Firestore en RendezVous (null si illisible).
  /// Firestore peut renvoyer un entier à la place d'un nombre à virgule.
  static RendezVous? _depuis(Map<String, dynamic> data) {
    try {
      final prestation = Map<String, dynamic>.from(data['prestation'] as Map);
      prestation['prix'] = (prestation['prix'] as num).toDouble();
      prestation['dureeMinutes'] = (prestation['dureeMinutes'] as num).toInt();
      prestation['description'] = prestation['description'] ?? '';

      return RendezVous.fromJson({
        ...data,
        'client': Map<String, dynamic>.from(data['client'] as Map),
        'prestation': prestation,
      });
    } catch (e) {
      debugPrint('Rendez-vous illisible ignoré : $e');
      return null;
    }
  }

  /// 🔴 Coiffeur : tous les RDV du salon, mis à jour en direct
  static Stream<List<RendezVous>> ecouterSalon(String salonId) {
    return _rdvs
        .where('salonId', isEqualTo: salonId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => _depuis(d.data()))
            .whereType<RendezVous>()
            .toList());
  }

  /// Client : les RDV pris avec cette session
  static Future<List<RendezVous>> mesRdvs(String clientUid) async {
    final resultat = await _rdvs
        .where('clientUid', isEqualTo: clientUid)
        .get()
        .timeout(_delai);
    return resultat.docs
        .map((d) => _depuis(d.data()))
        .whereType<RendezVous>()
        .toList();
  }

  /// Client : les créneaux déjà pris (sans aucun nom), sous forme de
  /// RDV "vides" que l'écran de réservation sait griser
  static Future<List<RendezVous>> creneauxOccupes(String salonId) async {
    final resultat = await _creneaux(salonId)
        .where('fin', isGreaterThan: Timestamp.now())
        .get()
        .timeout(_delai);

    return resultat.docs.map((d) {
      final debut = (d.data()['debut'] as Timestamp).toDate();
      final fin = (d.data()['fin'] as Timestamp).toDate();
      return RendezVous(
        id: d.id,
        salonId: salonId,
        client: const Client(
            id: '', nom: '', prenom: '', telephone: '', email: ''),
        prestation: Prestation(
          id: '',
          nom: '',
          description: '',
          duree: fin.difference(debut),
          prix: 0,
        ),
        dateHeure: debut,
        statut: StatutRdv.confirme,
      );
    }).toList();
  }

  /// Enregistre le RDV ET ses blocs de créneau en une seule opération.
  /// Si un bloc est déjà pris, rien n'est enregistré.
  static Future<void> creer(RendezVous rdv, {required String clientUid}) async {
    assert(rdv.salonId.isNotEmpty, 'Le RDV doit avoir un salonId');

    final batch = BaseDonnees.db.batch();
    batch.set(_rdvs.doc(rdv.id), {
      ...rdv.toJson(),
      'clientUid': clientUid,
      'creeLe': FieldValue.serverTimestamp(),
    });
    for (final debut in _blocs(rdv)) {
      batch.set(_creneaux(rdv.salonId).doc(_idBloc(debut)), {
        'debut': Timestamp.fromDate(debut),
        'fin': Timestamp.fromDate(debut.add(_bloc)),
        'rdvId': rdv.id,
      });
    }

    try {
      await batch.commit().timeout(_delai);
    } on FirebaseException catch (e) {
      // Bloc déjà existant = créneau pris (refusé par les règles Firestore)
      if (e.code == 'permission-denied') throw const CreneauPrisException();
      rethrow;
    }
  }

  /// Change le statut. Si le RDV est annulé, ses blocs sont libérés.
  static Future<void> changerStatut(RendezVous rdv, StatutRdv statut) async {
    final batch = BaseDonnees.db.batch();
    batch.update(_rdvs.doc(rdv.id), {'statut': statut.name});
    if (statut == StatutRdv.annule) {
      for (final debut in _blocs(rdv)) {
        batch.delete(_creneaux(rdv.salonId).doc(_idBloc(debut)));
      }
    }
    await batch.commit().timeout(_delai);
  }
}