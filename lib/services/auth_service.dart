
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return "Échec de la connexion";
      notifyListeners();
      return null;
    } catch (e) {
      return "Erreur de connexion : ${e.toString()}";
    }
  }


  Future<String?> signUp(String email, String password, String fullName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        return "Erreur lors de la création du compte.";
      }

      final userId = response.user!.id;

      final existing = await _supabase
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('users').insert({
          'id': userId,
          'email': email,
          'full_name': fullName,
          'photo_url': '',
        });
      }



      notifyListeners();
      return null;
    } catch (e) {
      if (e.toString().contains("email") && e.toString().contains("exists")) {
        return "Cette adresse email est déjà utilisée.";
      }
      return "Erreur inattendue : ${e.toString()}";
    }
  }



  Future<String?> updateProfilePhoto(String photoUrl) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return "Utilisateur non connecté";

      await _supabase
          .from('users')
          .update({'photo_url': photoUrl})
          .eq('id', userId);

      return null;
    } catch (e) {
      return "Erreur de mise à jour : ${e.toString()}";
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return null;

      final userData = await _supabase
          .from('users')
          .select('id, email, full_name, photo_url')
          .eq('id', userId)
          .single();

      return userData;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      notifyListeners();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (_) => false,
      );
    } catch (e) {
      print("❌ Erreur lors de la déconnexion : $e");
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      return "Erreur lors de la réinitialisation : ${e.toString()}";
    }
  }


Future<Map<String, dynamic>?> getUserInfoByEmail(String email) async {
  try {
    final data = await _supabase
        .from('users')
        .select('id, email, full_name, photo_url')
        .eq('email', email)
        .single();

    return data;
  } catch (e) {
    return null;
  }
}
}