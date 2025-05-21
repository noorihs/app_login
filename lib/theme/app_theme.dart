import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Couleurs principales
  static const Color purpleDark = Color(0xFF1F0A33);
  static const Color purpleLight = Color(0xFF5E1E7B);
  static const Color blueAccent = Color(0xFF1E3B7B);
  static const Color redAccent = Color(0xFF7B1E3B);

  // 🌄 Dégradé de fond global
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleDark, purpleLight],
  );

  // 🎯 Dégradé pour les boutons personnalisés
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purpleLight, blueAccent],
  );

  // ✍️ Style de texte pour les entrées
  static TextStyle inputTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.white70,
  );

  // 🧭 Titre principal
  static TextStyle headingStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 📍 Style de texte pour les boutons
  static TextStyle buttonTextStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // 🔗 Style pour les liens cliquables (ex: "Mot de passe oublié")
  static TextStyle linkStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.white,
    decoration: TextDecoration.underline,
  );

  // 🧩 Thème principal de l'application
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      scaffoldBackgroundColor: Colors.transparent,

      // Couleurs de base
      colorScheme: ColorScheme.dark(
        primary: purpleLight,
        secondary: blueAccent,
        error: redAccent,
      ),

      // Thème des textes
      textTheme: TextTheme(
        headlineSmall: headingStyle,
        bodyMedium: inputTextStyle,
        labelLarge: buttonTextStyle,
      ),

      // 🎛 Thème des boutons ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: purpleLight,
          foregroundColor: Colors.white,
          textStyle: buttonTextStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ✅ Tu peux ajouter plus de composants ici si besoin (Switch, InputDecoration, etc.)
    );
  }
}
