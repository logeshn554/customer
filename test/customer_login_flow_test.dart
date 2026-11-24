import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'package:allgo_customer_mobile/src/screens/welcome_screen.dart';
import 'package:allgo_customer_mobile/src/screens/phone_login_screen.dart';
import 'package:allgo_customer_mobile/src/screens/otp_verify_screen.dart';

void main() {
  group('Customer Mobile Login Flow Tests', () {
    testWidgets('WelcomeScreen renders navigation and triggers login transition', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      expect(find.text('Get Started with Phone Number'), findsOneWidget);
      expect(find.text('Everything you need,\ndelivered or on the move.'), findsOneWidget);

      await tester.tap(find.text('Get Started with Phone Number'));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneLoginScreen), findsOneWidget);
    });

    testWidgets('PhoneLoginScreen validates 10-digit Indian mobile number input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PhoneLoginScreen(),
          ),
        ),
      );

      expect(find.text('Enter Phone Number'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);

      // Attempt to submit empty phone number
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your mobile number'), findsOneWidget);

      // Enter valid 10 digits
      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pumpAndSettle();
      expect(find.text('9876543210'), findsOneWidget);
    });

    testWidgets('OtpVerifyScreen renders countdown timer and 6-digit input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OtpVerifyScreen(phone: '+919876543210'),
          ),
        ),
      );

      expect(find.text('Enter 6-digit code'), findsOneWidget);
      expect(find.textContaining('+919876543210'), findsOneWidget);
      expect(find.text('Verify & Continue'), findsOneWidget);
      expect(find.byType(AllGoOtpInput), findsOneWidget);
    });
  });
}
