import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/rendez_vous.dart';

/// 💾 Sauvegarde locale (survit à la fermeture de l'app)
/// ⚠️ Temporaire : sera remplacée par un serveur (Firebase) à l'étape 2
class LocalStorage {
  static const _cle = 'liste_rdvs';
  static const _cleMesRdvs = 'mes_rdv_ids';

  // ─── Tous les rendez-vous du salon ───

  static Future<void> sauvegarder(List<RendezVous> rdvs) async {
    final prefs = await SharedPreferences.getInstance();
    final texte = jsonEncode(rdvs.map((r) => r.toJson()).toList());
    await prefs.setString(_cle, texte);
  }

  static Future<List<RendezVous>> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final texte = prefs.getString(_cle);
    if (texte == null) return [];
    final liste = jsonDecode(texte) as List;
    return liste.map((e) => RendezVous.fromJson(e)).toList();
  }

  // ─── Les rendez-vous pris par CE client (sur cet appareil) ───

  static Future<List<String>> chargerMesIds() async {
    final prefs = await SharedPreferences.getInstance();
    return [...?prefs.getStringList(_cleMesRdvs)];
  }

  static Future<void> ajouterMonRdv(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = [...?prefs.getStringList(_cleMesRdvs)];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(_cleMesRdvs, ids);
    }
  }
}