import 'package:intl/intl.dart';

// 💰 Monnaie de l'appli : le franc CFA (FCFA / XOF), sans centimes.
// Les prix sont enregistrés comme des nombres entiers (ex. 5000).

/// 5000 → "5 000 FCFA"
String formatPrix(num montant) {
  final nombre = NumberFormat.decimalPattern(
    'fr_FR',
  ).format(montant.round()).replaceAll('\u202f', '\u00A0');
  return '$nombre\u00A0FCFA';
}

/// Version courte pour les petits espaces (graphiques) : 25000 → "25 k"
String formatPrixCourt(num montant) =>
    NumberFormat.compact(locale: 'fr_FR').format(montant);