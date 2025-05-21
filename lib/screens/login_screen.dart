import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../services/face_recognition_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  File? _loginImage;
  String? _loginMethod; // Ajout

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.setAsset(path);
      await _audioPlayer.play();
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  Future<void> _signInWithPassword() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showToast("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final result = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      await _saveCredentials();

      if (result == null) {
        await _playSound('assets/sounds/success.wav');
        _loginMethod = 'mot_de_passe'; // Déplacement ici
        _redirectAfterLogin();
      } else {
        await _playSound('assets/sounds/failure.wav');
        _showToast(result);
      }
    } catch (e) {
      _showToast("Error: $e");
      await _playSound('assets/sounds/failure.wav');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithFaceRecognition() async {
    if (_emailController.text.trim().isEmpty) {
      _showToast("Please enter your email before using face recognition");
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _isLoading = true;
        _loginImage = File(picked.path);
      });

      final supabase = Supabase.instance.client;
      final email = _emailController.text.trim();
      final userResp = await supabase
          .from('users')
          .select('id, photo_url')
          .eq('email', email)
          .single();

      if (userResp['photo_url'] == null || userResp['photo_url'].isEmpty) {
        throw Exception("No reference photo found.");
      }

      final match = await FaceRecognitionService.compare(
        referenceUrl: userResp['photo_url'],
        loginImage: _loginImage!,
      );

      if (match) {
        await _playSound('assets/sounds/success.wav');
        _showToast("Face recognized. Login successful!");
        _loginMethod = 'reconnaissance_faciale'; // Déplacement ici
        _redirectAfterLogin();
        await supabase.auth.signInWithPassword(email: email, password: 'faceid123');

      } else {
        await _playSound('assets/sounds/failure.wav');
        _showToast("Face not recognized.");
      }

    } catch (e) {
      await _playSound('assets/sounds/failure.wav');
      _showToast("Face ID error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');

    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      setState(() => _rememberMe = true);
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text.trim());
      await prefs.setString('password', _passwordController.text.trim());
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  void _redirectAfterLogin() async {
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();

    try {
      final userData = await supabase
          .from('users')
          .select('id, full_name, photo_url')
          .eq('email', email)
          .single();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(initialUserData: userData, userEmail: email),
        ),
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }

    if (_loginMethod != null) {
      await logLogin(email, _loginMethod!);
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_emailController.text.trim().isEmpty) {
      _showToast("Please enter your email to reset password");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _showToast("📧 Password reset email sent.");
    } catch (e) {
      _showToast("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width * 0.05),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Text('Login', style: AppTheme.headingStyle),
                const SizedBox(height: 32),
                Card(
                  color: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      children: [
                        CustomTextField(
                          hintText: 'Email',
                          prefixIcon: Icons.email,
                          controller: _emailController,
                        ),
                        CustomTextField(
                          hintText: 'Password',
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() => _rememberMe = value!);
                              },
                              activeColor: Colors.white,
                            ),
                            Expanded(
                              child: Text(
                                "Remember me",
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_loginImage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: FileImage(_loginImage!),
                            ),
                          ),
                        if (_isLoading)
                          const CircularProgressIndicator(color: Colors.white)
                        else ...[
                          GradientButton(
                            text: "Login with Password",
                            onPressed: _signInWithPassword,
                          ),
                          GradientButton(
                            text: "Login with Face ID",
                            onPressed: _signInWithFaceRecognition,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SignupScreen()),
                            ),
                            child: Text(
                              "No account yet? Sign up",
                              style: AppTheme.linkStyle,
                            ),
                          ),
                          GestureDetector(
                            onTap: _sendPasswordReset,
                            child: Text(
                              "Forgot password?",
                              style: AppTheme.linkStyle.copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logLogin(String email, String method) async {
    try {
      final supabase = Supabase.instance.client;

      // Récupérer manuellement l'ID utilisateur à partir de l'email
      final userData = await supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      final ipResponse = await http.get(Uri.parse('https://api.ipify.org'));
      final ip = ipResponse.statusCode == 200 ? ipResponse.body : 'inconnue';

      await supabase.from('login_logs').insert({
        'user_id': userData?['id'], // ✅ ID retrouvé manuellement
        'email': email,
        'method': method,
        'ip_address': ip,
      });
    } catch (e) {
      print("❌ Erreur lors de l'enregistrement du login: $e");
    }
  }

}
