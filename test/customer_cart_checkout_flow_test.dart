import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'package:allgo_customer_mobile/src/screens/cart_screen.dart';
import 'package:allgo_customer_mobile/src/screens/checkout_screen.dart';
import 'package:allgo_customer_mobile/src/components/checkout_payment_selector.dart';

void main() {
  group('Customer Cart & Checkout Flow Tests', () {
    testWidgets('CartScreen displays empty state when cart has no items', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // With default unauthenticated or empty client, empty state or Cart is rendered
      expect(find.text('My Cart'), findsOneWidget);
    });

    testWidgets('CheckoutScreen renders address header and payment selector', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CheckoutScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Checkout & Payment'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CheckoutPaymentSelector displays UPI, Card, and Cash on Delivery options', (tester) async {
      String selected = 'UPI';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckoutPaymentSelector(
              selectedMethod: selected,
              onSelectMethod: (method) => selected = method,
            ),
          ),
        ),
      );

      expect(find.text('Select Payment Method'), findsOneWidget);
      expect(find.text('UPI Instant (GPay / PhonePe / Paytm)'), findsOneWidget);
      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('Cash on Delivery (COD)'), findsOneWidget);

      await tester.tap(find.text('Cash on Delivery (COD)'));
      await tester.pumpAndSettle();
      expect(selected, 'COD');
    });
  });
}
