import 'client.dart';
import 'prestation.dart';

/// 📅 Statut possible d'un rendez-vous
enum StatutRdv { enAttente, confirme, annule, termine }

/// 🗓️ Un rendez-vous = un client + une prestation + un créneau horaire
class RendezVous {
  final String id;
  final Client client;
  final Prestation prestation;
  final DateTime dateHeure;
  final StatutRdv statut;

  const RendezVous({
    required this.id,
    required this.client,
    required this.prestation,
    required this.dateHeure,
    this.statut = StatutRdv.enAttente,  // valeur par défaut
  });

  /// Date + heure au format lisible : "16/09/2026 à 14:30"
  String get dateFormatee {
    final d = dateHeure;
    final date = '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
    final heure = '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
    return '$date à $heure';
  }


  /// Copie le RDV en modifiant seulement le statut (et plus tard d'autres champs)
RendezVous copyWith({StatutRdv? statut}) {
  return RendezVous(
    id: id,
    client: client,
    prestation: prestation,
    dateHeure: dateHeure,
    statut: statut ?? this.statut,   // ?? = "si null, garde l'ancienne valeur"
  );
}


  Map<String, dynamic> toJson() => {
        'id': id, 'client': client.toJson(), 'prestation': prestation.toJson(),
        'dateHeure': dateHeure.toIso8601String(),
        'statut': statut.name,
      };

  factory RendezVous.fromJson(Map<String, dynamic> json) => RendezVous(
        id: json['id'],
        client: Client.fromJson(json['client']),
        prestation: Prestation.fromJson(json['prestation']),
        dateHeure: DateTime.parse(json['dateHeure']),
        statut: StatutRdv.values.byName(json['statut']),
      );
}