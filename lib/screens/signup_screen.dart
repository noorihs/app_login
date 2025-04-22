import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: mediaQuery.size.width * 0.05,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                minHeight: mediaQuery.size.height * 0.7,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        style: AppTheme.inputTextStyle,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Nom complet',
                          hintStyle: AppTheme.inputTextStyle,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        style: AppTheme.inputTextStyle,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Email',
                          hintStyle: AppTheme.inputTextStyle,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Password field with eye icon
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTheme.inputTextStyle,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Mot de passe',
                          hintStyle: AppTheme.inputTextStyle,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Sign up button
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : GradientButton(
                        text: 'S\'INSCRIRE',
                        onPressed: _signUp,
                      ),

                      SizedBox(height: 16),

                      // Login link
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        child: Text(
                          'Déjà un compte? Se connecter',
                          style: AppTheme.inputTextStyle.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
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

  void _signUp() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final result = await authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result == null) {
        Fluttertoast.showToast(
          msg: "Inscription réussie! Un e-mail de vérification a été envoyé à votre adresse.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );

        Future.microtask(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
          );
        });
      } else {
        Fluttertoast.showToast(
          msg: result,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
          msg: "Une erreur s'est produite: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Veuillez entrer votre nom");
      return false;
    }

    if (!EmailValidator.validate(_emailController.text.trim())) {
      Fluttertoast.showToast(msg: "Email invalide");
      return false;
    }

    if (_passwordController.text.length < 6) {
      Fluttertoast.showToast(msg: "Le mot de passe doit contenir au moins 6 caractères");
      return false;
    }

    return true;
  }
}