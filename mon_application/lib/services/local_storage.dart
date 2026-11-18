import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/rendez_vous.dart';

/// 💾 Sauvegarde locale des rendez-vous (survivent à la fermeture de l'app)
class LocalStorage {
  static const _cle = 'liste_rdvs';

  static Future<void> sauvegarder(List<RendezVous> rdvs) async {
    final prefs = await SharedPreferences.getInstance();
    final texte = jsonEncode(rdvs.map((r) => r.toJson()).toList());
    await prefs.setString(_cle, texte);
  }

  static Future<List<RendezVous>> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final texte = prefs.getString(_cle);
    if (texte == null) return [];   // première ouverture : rien sauvegardé
    final liste = jsonDecode(texte) as List;
    return liste.map((e) => RendezVous.fromJson(e)).toList();
  }
}