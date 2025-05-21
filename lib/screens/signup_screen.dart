import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final picker = ImagePicker();

  bool _obscurePassword = true;
  bool _isLoading = false;
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) setState(() => _image = File(picked.path));
  }


  Future<void> _signUp() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final result = await authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (result != null) {
        Fluttertoast.showToast(msg: result);
        setState(() => _isLoading = false);
        return;
      }

      // 🔁 Attendre que la session soit stabilisée
      await Future.delayed(const Duration(milliseconds: 500));

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (_image != null && user != null) {
        final fileName = 'face_${user.id}.jpg'; // ✅ correction ici
        final bytes = await _image!.readAsBytes();

        try {
          final response = await supabase.storage.from('faces').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

          if (response.isEmpty) {
            throw Exception("Échec de l'envoi de la photo");
          }

          final publicUrl = supabase.storage.from('faces').getPublicUrl(fileName);
          await supabase.from('users').update({
            'photo_url': publicUrl,
          }).eq('id', user.id);

          print("✅ Photo enregistrée et URL ajoutée à la table `users`");
        } catch (e) {
          print("❌ Erreur Supabase Storage : $e");
          Fluttertoast.showToast(msg: "Erreur lors de l'upload de la photo : ${e.toString()}");
          return;
        }
      } else {
        print("⚠️ Aucun utilisateur connecté ou image manquante");
      }

      Fluttertoast.showToast(msg: "Inscription réussie !");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      print("❌ Erreur lors de l'inscription: $e");
      Fluttertoast.showToast(msg: "Erreur: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }




  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez entrer votre nom");
      return false;
    }
    if (!EmailValidator.validate(_emailController.text.trim())) {
      Fluttertoast.showToast(msg: "Email invalide");
      return false;
    }
    if (_passwordController.text.length < 6) {
      Fluttertoast.showToast(msg: "Mot de passe trop court");
      return false;
    }
    if (_image == null) {
      Fluttertoast.showToast(msg: "Veuillez ajouter une photo pour la reconnaissance faciale");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.05),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 8,
                color: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Create an account", style: AppTheme.headingStyle),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Full name',
                        prefixIcon: Icons.person,
                        controller: _nameController,
                      ),
                      CustomTextField(
                        hintText: 'Email',
                        prefixIcon: Icons.email,
                        controller: _emailController,
                      ),
                      CustomTextField(
                        hintText: 'Password',
                        prefixIcon: Icons.lock,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white54,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_image != null)
                        CircleAvatar(radius: 50, backgroundImage: FileImage(_image!)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, color: Colors.white54),
                            label: const Text("Galerie", style: TextStyle(color: Colors.white70)),
                          ),
                          TextButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, color: Colors.white54),
                            label: const Text("Camera", style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "This pic is going to be used for Face ID",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : GradientButton(
                        text: "Sign up",
                        onPressed: _signUp,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        ),
                        child: Text("Have an account ? Login", style: AppTheme.linkStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
