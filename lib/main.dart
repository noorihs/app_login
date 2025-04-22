import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pour le débogage
  bool firebaseInitialized = false;
  String errorMessage = "";

  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    print("Firebase initialisé avec succès");
  } catch (e) {
    errorMessage = e.toString();
    print("Erreur d'initialisation Firebase: $e");
  }

  runApp(MyApp(
    firebaseInitialized: firebaseInitialized,
    errorMessage: errorMessage,
  ));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  final String errorMessage;

  const MyApp({
    Key? key,
    this.firebaseInitialized = false,
    this.errorMessage = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!firebaseInitialized) {
      return MaterialApp(
        title: 'Erreur Firebase',
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Impossible d'initialiser Firebase",
                    style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                Text(errorMessage),
                SizedBox(height: 20),
                Text("Essayez de mettre à jour vos packages Firebase"),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Authentication App',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return authService.currentUser != null
        ? HomeScreen()
        : LoginScreen();
  }
}
