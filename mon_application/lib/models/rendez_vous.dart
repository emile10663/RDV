import 'package:intl/intl.dart';
import 'client.dart';
import 'prestation.dart';

/// 📅 Statut possible d'un rendez-vous
enum StatutRdv { enAttente, confirme, annule, termine }

/// 🗓️ Un rendez-vous = un client + une prestation + un créneau horaire
class RendezVous {
  final String id;
  final String salonId; // salon concerné ('' tant qu'il n'est pas enregistré)
  final Client client;
  final Prestation prestation;
  final DateTime dateHeure;
  final StatutRdv statut;

  const RendezVous({
    required this.id,
    required this.client,
    required this.prestation,
    required this.dateHeure,
    this.salonId = '',
    this.statut = StatutRdv.enAttente,
  });

  /// Génère un identifiant unique
  static String nouvelId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  /// Heure de fin = début + durée de la prestation
  DateTime get fin => dateHeure.add(prestation.duree);

  /// Vrai si ce RDV empiète sur le créneau de l'autre
  bool chevauche(RendezVous autre) =>
      dateHeure.isBefore(autre.fin) && fin.isAfter(autre.dateHeure);

  /// "14:30"
  String get heureFormatee => DateFormat('HH:mm').format(dateHeure);

  /// "16/09"
  String get jourCourt => DateFormat('dd/MM').format(dateHeure);

  /// "16/09/2026 à 14:30"
  String get dateFormatee =>
      DateFormat("dd/MM/yyyy 'à' HH:mm").format(dateHeure);

  /// Copie le RDV en changeant le statut, l'id et/ou le salon
  RendezVous copyWith({StatutRdv? statut, String? id, String? salonId}) {
    return RendezVous(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      client: client,
      prestation: prestation,
      dateHeure: dateHeure,
      statut: statut ?? this.statut,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'salonId': salonId,
        'client': client.toJson(),
        'prestation': prestation.toJson(),
        'dateHeure': dateHeure.toIso8601String(),
        'statut': statut.name,
      };

  factory RendezVous.fromJson(Map<String, dynamic> json) => RendezVous(
        id: json['id'],
        salonId: json['salonId'] ?? '',
        client: Client.fromJson(json['client']),
        prestation: Prestation.fromJson(json['prestation']),
        dateHeure: DateTime.parse(json['dateHeure']),
        statut: StatutRdv.values.byName(json['statut']),
      );
}