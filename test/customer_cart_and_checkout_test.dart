import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_customer_mobile/src/components/cart_coupon_section.dart';
import 'package:allgo_customer_mobile/src/components/delivery_tip_selector.dart';
import 'package:allgo_customer_mobile/src/components/delivery_instructions_selector.dart';
import 'package:allgo_customer_mobile/src/components/delivery_slot_picker.dart';
import 'package:allgo_customer_mobile/src/components/checkout_payment_selector.dart';
import 'package:allgo_customer_mobile/src/screens/order_success_screen.dart';
import 'package:allgo_customer_mobile/src/screens/payment_status_screen.dart';

void main() {
  group('Customer Cart & Checkout Tests (Phase 4)', () {
    testWidgets('DeliveryTipSelector toggles tips', (tester) async {
      double tip = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryTipSelector(
              selectedTip: tip,
              onTipSelected: (t) => tip = t,
            ),
          ),
        ),
      );

      expect(find.text('Tip Your Delivery Partner'), findsOneWidget);
      expect(find.text('₹20'), findsOneWidget);

      await tester.tap(find.text('₹20'));
      expect(tip, 20.0);
    });

    testWidgets('DeliveryInstructionsSelector toggles instructions and notes', (tester) async {
      Set<String> instructions = {};
      final ctrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryInstructionsSelector(
              selectedInstructions: instructions,
              onChanged: (inst) => instructions = inst,
              cookingNotesController: ctrl,
            ),
          ),
        ),
      );

      expect(find.text('Delivery Instructions'), findsOneWidget);
      expect(find.text('Leave at door'), findsOneWidget);
      expect(find.text("Don't ring bell"), findsOneWidget);

      await tester.tap(find.text('Leave at door'));
      expect(instructions.contains('LEAVE_AT_DOOR'), isTrue);
    });

    testWidgets('DeliverySlotPicker toggles Deliver Now and Schedule Later', (tester) async {
      bool isScheduled = false;
      String slot = 'NOW';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliverySlotPicker(
              isScheduled: isScheduled,
              selectedSlot: slot,
              onSlotChanged: (sched, s) {
                isScheduled = sched;
                slot = s;
              },
            ),
          ),
        ),
      );

      expect(find.text('Deliver Now (25-35m)'), findsOneWidget);
      expect(find.text('Schedule Later'), findsOneWidget);

      await tester.tap(find.text('Schedule Later'));
      expect(isScheduled, isTrue);
    });

    testWidgets('CartCouponSection applies valid coupon', (tester) async {
      String? applied;
      double discount = 0.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CartCouponSection(
                orderTotal: 250.0,
                appliedCoupon: applied,
                discountAmount: discount,
                onCouponApplied: (code, d) {
                  applied = code;
                  discount = d;
                },
                onCouponRemoved: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Enter coupon code'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ALLGO50');
      await tester.tap(find.text('APPLY'));
      await tester.pumpAndSettle();

      expect(applied, 'ALLGO50');
      expect(discount, 50.0);
    });

    testWidgets('CheckoutPaymentSelector toggles wallet and selects UPI app', (tester) async {
      bool useWallet = false;
      String method = 'UPI';
      String upiApp = 'gpay';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckoutPaymentSelector(
              selectedMethod: method,
              onSelectMethod: (m) => method = m,
              useWalletBalance: useWallet,
              onToggleWallet: (w) => useWallet = w,
              selectedUpiApp: upiApp,
              onSelectUpiApp: (app) => upiApp = app,
            ),
          ),
        ),
      );

      expect(find.text('Use AllGo Wallet'), findsOneWidget);
      expect(find.text('Available Balance: ₹250'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('PhonePe'), findsOneWidget);

      await tester.tap(find.text('PhonePe'));
      expect(upiApp, 'phonepe');
    });

    testWidgets('OrderSuccessScreen renders celebratory check and order details', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrderSuccessScreen(
            orderId: 'ORD-987654321',
            storeName: 'Royal Biryani',
            totalAmount: 450.0,
          ),
        ),
      );

      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
      expect(find.text('Track Order'), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
    });

    testWidgets('PaymentStatusScreen renders failure and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentStatusScreen(
            type: PaymentFailureType.failed,
            orderId: 'ORD-1234',
            amount: 350.0,
            errorMessage: 'Bank server timeout',
            onRetry: () => retried = true,
            onChangeMethod: () {},
          ),
        ),
      );

      expect(find.text('Payment Failed'), findsNWidgets(2));
      expect(find.text('Bank server timeout'), findsOneWidget);
      expect(find.text('Retry Payment'), findsOneWidget);

      await tester.tap(find.text('Retry Payment'));
      expect(retried, isTrue);
    });
  });
}
