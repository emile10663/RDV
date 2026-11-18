/// 👤 Un client du salon
class Client {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;

  const Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
  });

  /// Getter : un "calcul" qui se comporte comme une propriété
  /// Usage : client.nomComplet  (sans parenthèses !)
  String get nomComplet => '$prenom $nom';

    Map<String, dynamic> toJson() => {
        'id': id, 'nom': nom, 'prenom': prenom,
        'telephone': telephone, 'email': email,
      };

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['id'], nom: json['nom'], prenom: json['prenom'],
        telephone: json['telephone'], email: json['email'],
      );
}