import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_customer_mobile/src/screens/chat_with_driver_screen.dart';
import 'package:allgo_customer_mobile/src/screens/rate_review_screen.dart';

void main() {
  group('Customer Tracking and Post-Order Tests (Phase 5)', () {
    testWidgets('ChatWithDriverScreen displays driver header and quick reply options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ChatWithDriverScreen(
              driverName: 'Ramesh Kumar',
              driverPhone: '+919876543210',
              orderId: 'ord_test_001',
            ),
          ),
        ),
      );

      // Verifies driver info is present
      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('Delivery Partner • Active en route'), findsOneWidget);

      // Verifies quick reply chips
      expect(find.text('I am waiting at the gate.'), findsOneWidget);
      expect(find.text('Please leave it at the door.'), findsOneWidget);

      // Tap a quick reply chip
      await tester.tap(find.text('I am waiting at the gate.'));
      await tester.pumpAndSettle();

      // Message should now be present in bubbles
      expect(find.text('I am waiting at the gate.'), findsWidgets);
    });

    testWidgets('RateReviewScreen renders star rating sections, feedback chips, and submit action', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RateReviewScreen(
              orderId: 'ord_test_001',
              partnerName: 'Ramesh Kumar',
              outletName: 'Biryani Central',
            ),
          ),
        ),
      );

      // Verifies ratings sections
      expect(find.text('Food & Restaurant Quality'), findsOneWidget);
      expect(find.text('Biryani Central'), findsOneWidget);
      expect(find.text('Delivery Partner Service'), findsOneWidget);
      expect(find.text('Submit Feedback'), findsOneWidget);

      // Verifies compliment tags
      expect(find.text('Super Fast Delivery'), findsOneWidget);
      expect(find.text('Great Packaging'), findsOneWidget);

      // Tap on a compliment chip
      await tester.tap(find.text('Super Fast Delivery'));
      await tester.pumpAndSettle();

      // Enter review comment
      await tester.enterText(find.byType(TextField), 'Great food and fast delivery!');
      expect(find.text('Great food and fast delivery!'), findsOneWidget);
    });
  });
}
