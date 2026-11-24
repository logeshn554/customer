import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_customer_mobile/src/screens/welcome_screen.dart';
import 'package:allgo_customer_mobile/src/screens/onboarding_screen.dart';
import 'package:allgo_customer_mobile/src/screens/legal/terms_screen.dart';
import 'package:allgo_customer_mobile/src/screens/legal/privacy_policy_screen.dart';
import 'package:allgo_customer_mobile/src/screens/legal/about_screen.dart';
import 'package:allgo_customer_mobile/src/components/permission_primer_sheet.dart';
import 'package:allgo_customer_mobile/src/components/guest_login_prompt_sheet.dart';

void main() {
  group('Customer Onboarding, Legal & Auth Tests (Phase 6)', () {
    testWidgets('WelcomeScreen renders guest browsing option and legal text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );

      expect(find.text('Get Started with Phone Number'), findsOneWidget);
      expect(find.text('Browse App as Guest'), findsOneWidget);
      expect(find.textContaining('Terms of Service'), findsOneWidget);
      expect(find.textContaining('Privacy Policy'), findsOneWidget);
    });

    testWidgets('TermsScreen renders marketplace sections', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: TermsScreen(),
        ),
      );

      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('1. Platform Marketplace Role'), findsOneWidget);
      expect(find.text('4. Cancellations and Refunds'), findsOneWidget);
    });

    testWidgets('PrivacyPolicyScreen renders DPDP Act compliance section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Compliant with Digital Personal Data Protection (DPDP) Act'), findsOneWidget);
      expect(find.text('4. Your DPDP Act Rights (Section 12)'), findsOneWidget);
    });

    testWidgets('AboutScreen renders version and company information', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('About AllGo'), findsOneWidget);
      expect(find.text('AllGo Technologies Pvt Ltd'), findsOneWidget);
      expect(find.text('Made with pride in India'), findsOneWidget);
    });

    testWidgets('OnboardingScreen renders 3-step carousel and buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Food & Groceries in Minutes'), findsOneWidget);
      expect(find.text('SPEED & FRESHNESS'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Next to advance
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Express Parcel Delivery'), findsOneWidget);
      expect(find.text('RELIABLE & SAFE'), findsOneWidget);
    });

    testWidgets('PermissionPrimerSheet renders location explanation and action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionPrimerSheet(
              permissionType: PrimerPermissionType.location,
              onGranted: () {},
              onManualFallback: () {},
            ),
          ),
        ),
      );

      expect(find.text('Enable Location for Accurate Delivery'), findsOneWidget);
      expect(find.text('Allow Location Access'), findsOneWidget);
      expect(find.text('Enter Address Manually'), findsOneWidget);
    });

    testWidgets('GuestLoginPromptSheet displays login prompt', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuestLoginPromptSheet(),
          ),
        ),
      );

      expect(find.text('Sign In to Proceed'), findsOneWidget);
      expect(find.text('Continue with Phone Number'), findsOneWidget);
      expect(find.text('Continue Browsing'), findsOneWidget);
    });
  });
}
