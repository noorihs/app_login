import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar du profil
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                    border: Border.all(color: Colors.white38, width: 2),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white70,
                    size: 60,
                  ),
                ),

                SizedBox(height: 24),

                Text(
                  'Bienvenue!',
                  style: AppTheme.headingStyle,
                ),

                SizedBox(height: 8),

                Card(
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
                        Text(
                          'Vous êtes connecté avec:',
                          style: AppTheme.inputTextStyle,
                        ),
                        SizedBox(height: 8),
                        Text(
                          user?.email ?? 'Inconnu',
                          style: AppTheme.inputTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Spacer(),

                GradientButton(
                  text: 'SE DÉCONNECTER',
                  onPressed: () {
                    authService.signOut();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
