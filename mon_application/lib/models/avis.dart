import 'package:cloud_firestore/cloud_firestore.dart';

/// ⭐ L'avis d'un client sur un rendez-vous terminé
class Avis {
  final String id; // = identifiant du rendez-vous (un seul avis par RDV)
  final int note; // de 1 à 5
  final String commentaire;
  final String prenom;
  final DateTime? date;

  const Avis({
    required this.id,
    required this.note,
    required this.commentaire,
    required this.prenom,
    this.date,
  });

  factory Avis.fromDoc(String id, Map<String, dynamic> d) {
    final creeLe = d['creeLe'];
    return Avis(
      id: id,
      note: (d['note'] as num).toInt(),
      commentaire: (d['commentaire'] ?? '') as String,
      prenom: (d['prenom'] ?? '') as String,
      date: creeLe is Timestamp ? creeLe.toDate() : null,
    );
  }
}

/// Note moyenne (0 s'il n'y a aucun avis)
double moyenneAvis(List<Avis> avis) => avis.isEmpty
    ? 0
    : avis.fold<int>(0, (total, a) => total + a.note) / avis.length;

/// 4.5 → "4,5"
String noteTexte(double note) => note.toStringAsFixed(1).replaceAll('.', ',');