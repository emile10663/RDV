/// Une plage d'ouverture, en minutes depuis minuit (9h00 = 540, 19h00 = 1140)
class PlageHoraire {
  final int ouverture;
  final int fermeture;

  const PlageHoraire(this.ouverture, this.fermeture);

  /// 540 → "09:00"
  static String texteMinutes(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  /// "09:00 – 19:00"
  String get texte => '${texteMinutes(ouverture)} – ${texteMinutes(fermeture)}';
}

/// 🕘 Horaires d'un salon : une plage par jour de la semaine + jours de congé
class HorairesSalon {
  /// 1 = lundi … 7 = dimanche. Une valeur null = fermé ce jour-là.
  final Map<int, PlageHoraire?> semaine;

  /// Jours de congé, au format "2026-12-25"
  final List<String> conges;

  const HorairesSalon({required this.semaine, this.conges = const []});

  static const _standard = PlageHoraire(540, 1140); // 9h00 – 19h00

  /// Pour les salons qui n'ont encore rien réglé : ouvert tous les jours 9h-19h
  static const parDefaut = HorairesSalon(semaine: {
    1: _standard,
    2: _standard,
    3: _standard,
    4: _standard,
    5: _standard,
    6: _standard,
    7: _standard,
  });

  /// DateTime → "2026-12-25"
  static String cleJour(DateTime jour) =>
      '${jour.year.toString().padLeft(4, '0')}-'
      '${jour.month.toString().padLeft(2, '0')}-'
      '${jour.day.toString().padLeft(2, '0')}';

  bool estConge(DateTime jour) => conges.contains(cleJour(jour));

  /// La plage d'ouverture de ce jour (null si fermé ou en congé)
  PlageHoraire? plageDuJour(DateTime jour) =>
      estConge(jour) ? null : semaine[jour.weekday];

  bool estOuvert(DateTime jour) => plageDuJour(jour) != null;

  /// Nombre de jours ouverts par semaine
  int get joursOuverts => semaine.values.where((p) => p != null).length;

  HorairesSalon copyWith({
    Map<int, PlageHoraire?>? semaine,
    List<String>? conges,
  }) =>
      HorairesSalon(
        semaine: semaine ?? this.semaine,
        conges: conges ?? this.conges,
      );

  Map<String, dynamic> toJson() => {
        'semaine': {
          for (var j = 1; j <= 7; j++)
            '$j': semaine[j] == null
                ? {'ferme': true}
                : {
                    'ouverture': semaine[j]!.ouverture,
                    'fermeture': semaine[j]!.fermeture,
                  },
        },
        'conges': [...conges]..sort(),
      };

  /// Lit les horaires depuis Firestore. Si rien n'est enregistré → par défaut.
  factory HorairesSalon.fromJson(Object? brut) {
    if (brut is! Map) return parDefaut;

    final jours = brut['semaine'];
    final semaine = <int, PlageHoraire?>{};
    for (var j = 1; j <= 7; j++) {
      final jour = jours is Map ? jours['$j'] : null;
      if (jour is Map && jour['ouverture'] is num && jour['fermeture'] is num) {
        semaine[j] = PlageHoraire(
          (jour['ouverture'] as num).toInt(),
          (jour['fermeture'] as num).toInt(),
        );
      } else if (jour is Map && jour['ferme'] == true) {
        semaine[j] = null;
      } else {
        semaine[j] = parDefaut.semaine[j];
      }
    }

    final conges = brut['conges'];
    return HorairesSalon(
      semaine: semaine,
      conges: conges is List ? conges.whereType<String>().toList() : const [],
    );
  }
}