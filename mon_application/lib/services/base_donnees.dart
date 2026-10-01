import 'package:cloud_firestore/cloud_firestore.dart';

/// 🗄️ Point d'accès unique à la base Firestore
class BaseDonnees {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Si votre base s'appelle "default" (sans parenthèses), remplacez la ligne
  // ci-dessus par celle-ci, et ajoutez en haut du fichier :
  //   import 'package:firebase_core/firebase_core.dart';
  //
  // static final FirebaseFirestore db = FirebaseFirestore.instanceFor(
  //   app: Firebase.app(),
  //   databaseId: 'default',
  // );
}