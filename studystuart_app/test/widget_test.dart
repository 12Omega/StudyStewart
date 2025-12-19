// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studystuart_app/main.dart';
import 'package:studystuart_app/screens/auth_screen.dart';

void main() {
  testWidgets('StudyStuart app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudyStuartApp());

    // Wait for initial frame
    await tester.pump();

    // Verify that our app starts with the auth screen
    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('Auth screen UI elements test', (WidgetTester tester) async {
    // Test the auth screen directly to avoid async initialization issues
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(),
      ),
    );

    await tester.pump();

    // Verify auth screen elements that are visible by default
    expect(find.text('Your Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Or'), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);
  });

  testWidgets('Auth screen basic functionality', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(),
      ),
    );

    await tester.pump();

    // Check that we can find text input fields
    expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    
    // Check for buttons
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    expect(find.byType(OutlinedButton), findsOneWidget);
  });
}
