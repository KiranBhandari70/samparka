// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samparka/main.dart';

void main() {
  testWidgets('Samparka splash navigates to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const SamparkaApp());

    // Splash screen should display the app name.
    expect(find.text('SAMPARKA'), findsOneWidget);
    expect(find.text('Discover Local Events'), findsNothing);

    // Wait for splash timer to finish and transition.
    await tester.pump(const Duration(seconds: 3));

    // Onboarding screen should be visible after splash.
    expect(find.text('Discover Local Events'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
