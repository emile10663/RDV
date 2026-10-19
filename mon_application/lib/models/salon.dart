import 'horaires_salon.dart';

/// 💈 Un salon de coiffure (un coiffeur = un salon)
class Salon {
  final String id;
  final String proprietaireId; // identifiant Firebase du coiffeur
  final String nom;
  final String adresse;
  final String telephone;
  final HorairesSalon horaires;

  const Salon({
    required this.id,
    required this.proprietaireId,
    required this.nom,
    required this.adresse,
    required this.telephone,
    this.horaires = HorairesSalon.parDefaut,
  });

  Salon copyWith({HorairesSalon? horaires}) => Salon(
        id: id,
        proprietaireId: proprietaireId,
        nom: nom,
        adresse: adresse,
        telephone: telephone,
        horaires: horaires ?? this.horaires,
      );

  Map<String, dynamic> toJson() => {
        'proprietaireId': proprietaireId,
        'nom': nom,
        'adresse': adresse,
        'telephone': telephone,
        'horaires': horaires.toJson(),
      };

  /// L'id vient de Firestore (nom du document), pas du contenu
  factory Salon.fromJson(String id, Map<String, dynamic> json) => Salon(
        id: id,
        proprietaireId: json['proprietaireId'],
        nom: json['nom'],
        adresse: json['adresse'],
        telephone: json['telephone'],
        horaires: HorairesSalon.fromJson(json['horaires']),
      );
}