import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Méthode de connexion
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null; // Pas d'erreur
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erreur d'authentification";
    } catch (e) {
      return e.toString();
    }
  }

  // Méthode d'inscription sans Firestore
  Future<String?> signUp(String email, String password, String name) async {
    try {
      // Créer l'utilisateur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le nom d'affichage
      await userCredential.user?.updateDisplayName(name);

      // Envoyer l'email de vérification
      await userCredential.user?.sendEmailVerification();

      notifyListeners();
      return null; // Pas d'erreur
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erreur d'enregistrement";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
