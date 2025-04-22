// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projet_login/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());  // Retiré le 'const' car MyApp n'est pas une classe const

    // Note: Ce test est conçu pour une application compteur, mais votre
    // application est une app d'authentification. Vous pouvez soit:
    // 1. Modifier ce test pour qu'il soit pertinent pour votre application
    // 2. Ignorer ce test pour le moment

    // Commenté les attentes qui ne s'appliquent pas à votre application
    /*
    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    */

    // Un test simple pour vérifier si l'application se lance
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
