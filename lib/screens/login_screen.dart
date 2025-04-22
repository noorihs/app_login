import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  void _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    setState(() {
      if (email != null && password != null && rememberMe) {
        _emailController.text = email;
        _passwordController.text = password;
        _rememberMe = rememberMe;
      }
    });
  }

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
                      // Avatar placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 32),

                      // Email field
                      CustomTextField(
                        hintText: 'Email ID',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
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
                          hintText: 'Password',
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

                      SizedBox(height: 8),

                      // Remember me and forgot password
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                            checkColor: AppTheme.purpleDark,
                            activeColor: Colors.white70,
                          ),
                          Text(
                            'Remember me',
                            style: AppTheme.inputTextStyle.copyWith(fontSize: 12),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: AppTheme.inputTextStyle.copyWith(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Login button
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : GradientButton(
                        text: 'LOGIN',
                        onPressed: _signIn,
                      ),

                      SizedBox(height: 16),

                      // Sign up link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignupScreen()),
                          );
                        },
                        child: Text(
                          'Pas de compte? Inscrivez-vous',
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

  void _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('email', _emailController.text.trim());
      prefs.setString('password', _passwordController.text.trim());
      prefs.setBool('rememberMe', _rememberMe);
    } else {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('email');
      prefs.remove('password');
      prefs.setBool('rememberMe', _rememberMe);
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        Fluttertoast.showToast(
          msg: error,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Veuillez entrer votre adresse e-mail');
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resetPassword(email);

      Fluttertoast.showToast(
        msg: 'Un e-mail de réinitialisation a été envoyé à $email',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Erreur: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
}
