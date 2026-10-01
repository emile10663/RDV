import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prestation.dart';
import 'base_donnees.dart';

/// 💇 Les prestations d'un salon, rangées dans salons/{salonId}/prestations
class PrestationService {
  static CollectionReference<Map<String, dynamic>> _col(String salonId) =>
      BaseDonnees.db
          .collection('salons')
          .doc(salonId)
          .collection('prestations');

  /// Convertit un document Firestore en Prestation
  /// (Firestore peut renvoyer un entier à la place d'un nombre à virgule)
  static Prestation _depuis(String id, Map<String, dynamic> data) {
    return Prestation.fromJson({
      ...data,
      'id': id,
      'description': data['description'] ?? '',
      'prix': (data['prix'] as num).toDouble(),
      'dureeMinutes': (data['dureeMinutes'] as num).toInt(),
    });
  }

  static Future<List<Prestation>> charger(String salonId) async {
    final resultat = await _col(salonId).orderBy('nom').get();
    return resultat.docs.map((d) => _depuis(d.id, d.data())).toList();
  }

  /// Crée la prestation (si son id est vide) ou la met à jour
  static Future<void> enregistrer(String salonId, Prestation p) async {
    final ref = p.id.isEmpty ? _col(salonId).doc() : _col(salonId).doc(p.id);
    final complete = Prestation(
      id: ref.id,
      nom: p.nom,
      description: p.description,
      duree: p.duree,
      prix: p.prix,
      imageUrl: p.imageUrl,
    );
    await ref.set(complete.toJson()).timeout(const Duration(seconds: 15));
  }

  static Future<void> supprimer(String salonId, String prestationId) async {
    await _col(salonId)
        .doc(prestationId)
        .delete()
        .timeout(const Duration(seconds: 15));
  }
}