/// 💇 Une prestation = un service proposé par le salon
/// Exemples : "Coupe homme", "Taille de barbe", "Coloration"
class Prestation {
  final String id;           // identifiant unique ("coupe-homme")
  final String nom;          // "Coupe homme"
  final String description;  // petit texte descriptif
  final Duration duree;      // combien de temps ça prend
  final double prix;         // en euros
  final String? imageUrl;    // photo (optionnelle → le "?" signifie nullable)

  const Prestation({
    required this.id,
    required this.nom,
    required this.description,
    required this.duree,
    required this.prix,
    this.imageUrl,
  });

    Map<String, dynamic> toJson() => {
        'id': id, 'nom': nom, 'description': description,
        'dureeMinutes': duree.inMinutes, 'prix': prix, 'imageUrl': imageUrl,
      };

  factory Prestation.fromJson(Map<String, dynamic> json) => Prestation(
        id: json['id'], nom: json['nom'], description: json['description'],
        duree: Duration(minutes: json['dureeMinutes']), prix: json['prix'],
        imageUrl: json['imageUrl'],
      );
}