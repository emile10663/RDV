import 'package:firebase_auth/firebase_auth.dart';

/// 🔐 Connexion du coiffeur (e-mail + mot de passe)
///    et session anonyme pour les clients
class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Prévient l'appli quand quelqu'un se connecte ou se déconnecte
  static Stream<User?> get changements => _auth.authStateChanges();

  static User? get utilisateur => _auth.currentUser;

  static Future<void> inscrire(String email, String motDePasse) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: motDePasse);
  }

  static Future<void> connecter(String email, String motDePasse) async {
    await _auth.signInWithEmailAndPassword(
        email: email, password: motDePasse);
  }

  static Future<void> deconnecter() => _auth.signOut();

  /// Client : s'assure qu'une session existe (anonyme au besoin)
  /// et renvoie son identifiant
  static Future<String> assurerSessionClient() async {
    final actuel = _auth.currentUser;
    if (actuel != null) return actuel.uid;
    final resultat = await _auth.signInAnonymously();
    return resultat.user!.uid;
  }

  /// Transforme l'erreur Firebase en phrase compréhensible
  static String messageErreur(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Cette adresse e-mail n\'est pas valide.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Un compte existe déjà avec cet e-mail.';
        case 'weak-password':
          return 'Mot de passe trop faible (6 caractères minimum).';
        case 'network-request-failed':
          return 'Pas de connexion internet.';
        case 'operation-not-allowed':
          return 'Ce mode de connexion n\'est pas activé dans Firebase.';
      }
      return 'Erreur de connexion (${e.code}).';
    }
    return 'Une erreur est survenue. Réessaie.';
  }
}