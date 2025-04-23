import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/login_screen.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Connexion (autorise même si l'e-mail n'est pas vérifié)
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null; // Connexion réussie
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erreur d'authentification";
    } catch (e) {
      return e.toString();
    }
  }

  // Inscription avec envoi d'email de vérification (option de déconnexion après)
  Future<String?> signUp(String email, String password, String name, {bool disconnectAfter = false}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      // Envoi de l'email de vérification (informative uniquement)
      await userCredential.user?.sendEmailVerification();

      if (disconnectAfter) {
        await _auth.signOut(); // Déconnecter si nécessaire
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erreur d'enregistrement";
    } catch (e) {
      return e.toString();
    }
  }

  // Réinitialisation de mot de passe
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Déconnexion
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    notifyListeners();

    // Rediriger vers la page de connexion après déconnexion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
// Rediriger vers la page de connexion après déconnexion


