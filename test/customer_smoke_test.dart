import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:allgo_customer_mobile/src/screens/welcome_screen.dart';

void main() {
  group('Customer Mobile App Smoke Tests', () {
    testWidgets('WelcomeScreen renders headline, description and CTA button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Verify headline is displayed
      expect(find.text('Everything you need,\ndelivered or on the move.'), findsOneWidget);

      // Verify service description
      expect(
        find.text('Food, Groceries, Courier, Rides and Professional Drivers in one super app.'),
        findsOneWidget,
      );

      // Verify Call to Action button
      expect(find.text('Get Started with Phone Number'), findsOneWidget);
    });
  });
}
