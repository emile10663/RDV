import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/avis.dart';
import '../models/rendez_vous.dart';
import 'auth_service.dart';
import 'base_donnees.dart';

/// ⭐ Les avis dans Firestore : salons/{salonId}/avis/{rdvId}
/// L'identifiant de l'avis = celui du RDV, donc un seul avis par rendez-vous.
class AvisService {
  static const _delai = Duration(seconds: 15);

  static CollectionReference<Map<String, dynamic>> _avis(String salonId) =>
      BaseDonnees.db.collection('salons').doc(salonId).collection('avis');

  /// Les 200 derniers avis du salon, du plus récent au plus ancien
  static Future<List<Avis>> charger(String salonId) async {
    final resultat = await _avis(salonId)
        .orderBy('creeLe', descending: true)
        .limit(200)
        .get()
        .timeout(_delai);

    return resultat.docs
        .map((d) {
          try {
            return Avis.fromDoc(d.id, d.data());
          } catch (e) {
            debugPrint('Avis illisible ignoré : $e');
            return null;
          }
        })
        .whereType<Avis>()
        .toList();
  }

  /// Parmi ces RDV, ceux pour lesquels un avis a déjà été donné
  static Future<Set<String>> idsDonnes(Iterable<RendezVous> rdvs) async {
    final resultats = await Future.wait(rdvs.map((r) async {
      final doc = await _avis(r.salonId).doc(r.id).get().timeout(_delai);
      return doc.exists ? r.id : null;
    }));
    return resultats.whereType<String>().toSet();
  }

  /// Le client donne son avis sur un RDV terminé
  static Future<void> donner(
    RendezVous rdv, {
    required int note,
    required String commentaire,
  }) async {
    final uid = AuthService.utilisateur?.uid;
    if (uid == null) throw StateError('Session expirée');

    await _avis(rdv.salonId).doc(rdv.id).set({
      'note': note,
      'commentaire': commentaire.trim(),
      'prenom': rdv.client.prenom.trim(),
      'clientUid': uid,
      'creeLe': FieldValue.serverTimestamp(),
    }).timeout(_delai);
  }

  /// Le coiffeur retire un avis abusif
  static Future<void> supprimer(String salonId, String avisId) =>
      _avis(salonId).doc(avisId).delete().timeout(_delai);
}