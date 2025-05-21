import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String errorMessage = "";

  try {
    await Supabase.initialize(
      url: "https://yenqfxmrwfyveydtmioc.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllbnFmeG1yd2Z5dmV5ZHRtaW9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyNTU0NzUsImV4cCI6MjA2MjgzMTQ3NX0.gLPDLpAaaSWd2FKc2VUpgySH3ZDZ9FsacBXiYBC97Ak",
    );
    print("✅ Supabase initialisé avec succès");
  } catch (e) {
    errorMessage = e.toString();
    print("❌ Erreur d'initialisation Supabase: $errorMessage");
  }

  runApp(MyApp(errorMessage: errorMessage));
}

class MyApp extends StatelessWidget {
  final String errorMessage;

  const MyApp({Key? key, this.errorMessage = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return MaterialApp(
        title: 'Erreur Supabase',
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                SizedBox(height: 20),
                Text("Erreur d'initialisation Supabase", style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(errorMessage, textAlign: TextAlign.center),
                ),
                SizedBox(height: 20),
                Text("Vérifiez vos clés ou votre connexion Internet."),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'App Reconnaissance Faciale',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return authService.currentUser != null ? HomeScreen() : LoginScreen();
  }
}
