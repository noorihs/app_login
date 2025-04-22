import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales pour le gradient
  static const Color purpleDark = Color(0xFF1F0A33);
  static const Color purpleLight = Color(0xFF5E1E7B);
  static const Color blueAccent = Color(0xFF1E3B7B);
  static const Color redAccent = Color(0xFF7B1E3B);

  // Gradient de fond
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleDark, purpleLight],
  );

  // Gradient pour les boutons
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purpleLight, blueAccent],
  );

  // Style de texte pour les entrées
  static TextStyle inputTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.white70,
  );

  // Style pour les titres
  static TextStyle headingStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Style pour les boutons
  static TextStyle buttonTextStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Ajout de linkStyle pour résoudre l'erreur
  static TextStyle linkStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  static ThemeData get themeData {
    return ThemeData(
      // Désactive les effets de splash/ripple
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      // Pour les Switch, Checkbox etc. (nouvelle propriété)
      useMaterial3: true, // Optionnel - pour Material 3
      colorScheme: ColorScheme.light(
        primary: Colors.white, // Remplace toggleableActiveColor
      ),

      // Configuration du texte
      textTheme: TextTheme(
        headlineSmall: headingStyle, // Anciennement headline6
        bodyMedium: inputTextStyle, // Anciennement bodyText2
        labelLarge: buttonTextStyle, // Anciennement button
      ),
    );
  }
}
