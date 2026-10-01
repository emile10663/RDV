/// 💈 Un salon de coiffure (un coiffeur = un salon)
class Salon {
  final String id;
  final String proprietaireId; // identifiant Firebase du coiffeur
  final String nom;
  final String adresse;
  final String telephone;

  const Salon({
    required this.id,
    required this.proprietaireId,
    required this.nom,
    required this.adresse,
    required this.telephone,
  });

  Map<String, dynamic> toJson() => {
        'proprietaireId': proprietaireId,
        'nom': nom,
        'adresse': adresse,
        'telephone': telephone,
      };

  /// L'id vient de Firestore (nom du document), pas du contenu
  factory Salon.fromJson(String id, Map<String, dynamic> json) => Salon(
        id: id,
        proprietaireId: json['proprietaireId'],
        nom: json['nom'],
        adresse: json['adresse'],
        telephone: json['telephone'],
      );
}