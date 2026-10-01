import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salon.dart';
import 'auth_service.dart';
import 'base_donnees.dart';

/// 🏪 Lecture et création du salon dans Firestore
class SalonService {
  static CollectionReference<Map<String, dynamic>> get _salons =>
      BaseDonnees.db.collection('salons');

  /// Le salon du coiffeur connecté (null s'il n'en a pas encore)
  static Future<Salon?> salonDuCoiffeur() async {
    final uid = AuthService.utilisateur?.uid;
    if (uid == null) return null;

    final resultat = await _salons
        .where('proprietaireId', isEqualTo: uid)
        .limit(1)
        .get();

    if (resultat.docs.isEmpty) return null;
    final doc = resultat.docs.first;
    return Salon.fromJson(doc.id, doc.data());
  }

  /// Tous les salons (pour que le client choisisse le sien)
  static Future<List<Salon>> tous() async {
    final resultat = await _salons.orderBy('nom').get();
    return resultat.docs.map((d) => Salon.fromJson(d.id, d.data())).toList();
  }

  /// Crée le salon du coiffeur connecté
  static Future<Salon> creer({
    required String nom,
    required String adresse,
    required String telephone,
  }) async {
    final uid = AuthService.utilisateur!.uid;
    final donnees = Salon(
      id: '',
      proprietaireId: uid,
      nom: nom,
      adresse: adresse,
      telephone: telephone,
    );

    final ref = await _salons.add({
      ...donnees.toJson(),
      'creeLe': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 15));

    return Salon(
      id: ref.id,
      proprietaireId: uid,
      nom: nom,
      adresse: adresse,
      telephone: telephone,
    );
  }
}