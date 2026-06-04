// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility
// that Flutter provides. For example, you can send tap and scroll gestures.
// You can also use WidgetTester to find child widgets in the widget tree,
// read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_it/main.dart';

void main() {
  testWidgets('Track It App - Login Screen Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrackItApp());

    // Verify that the login screen is displayed
    expect(find.text('Track It'), findsOneWidget);
    expect(find.text('Connect your Spotify and track your music'), findsOneWidget);
    
    // Verify login form elements
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    
    // Verify social login buttons
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
  });
}
