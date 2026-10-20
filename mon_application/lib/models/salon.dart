import 'horaires_salon.dart';

/// 💈 Un salon de coiffure (un coiffeur = un salon)
class Salon {
  final String id;
  final String proprietaireId; // identifiant Firebase du coiffeur
  final String nom;
  final String adresse;
  final String telephone;
  final String description; // petit texte de présentation (facultatif)
  final String? logo; // image réduite, enregistrée en base64 (facultatif)
  final HorairesSalon horaires;

  const Salon({
    required this.id,
    required this.proprietaireId,
    required this.nom,
    required this.adresse,
    required this.telephone,
    this.description = '',
    this.logo,
    this.horaires = HorairesSalon.parDefaut,
  });

  Salon copyWith({
    String? nom,
    String? adresse,
    String? telephone,
    String? description,
    String? logo,
    bool retirerLogo = false,
    HorairesSalon? horaires,
  }) =>
      Salon(
        id: id,
        proprietaireId: proprietaireId,
        nom: nom ?? this.nom,
        adresse: adresse ?? this.adresse,
        telephone: telephone ?? this.telephone,
        description: description ?? this.description,
        logo: retirerLogo ? null : (logo ?? this.logo),
        horaires: horaires ?? this.horaires,
      );

  Map<String, dynamic> toJson() => {
        'proprietaireId': proprietaireId,
        'nom': nom,
        'adresse': adresse,
        'telephone': telephone,
        'description': description,
        if (logo != null) 'logo': logo,
        'horaires': horaires.toJson(),
      };

  /// L'id vient de Firestore (nom du document), pas du contenu.
  /// Les anciens salons sans description ni horaires reçoivent des valeurs par défaut.
  factory Salon.fromJson(String id, Map<String, dynamic> json) => Salon(
        id: id,
        proprietaireId: json['proprietaireId'],
        nom: json['nom'],
        adresse: json['adresse'],
        telephone: json['telephone'],
        description: (json['description'] ?? '') as String,
        logo: json['logo'] as String?,
        horaires: HorairesSalon.fromJson(json['horaires']),
      );
}