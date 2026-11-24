import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_customer_mobile/src/screens/help_faq_screen.dart';
import 'package:allgo_customer_mobile/src/screens/offers_coupons_screen.dart';
import 'package:allgo_customer_mobile/src/screens/refer_earn_screen.dart';
import 'package:allgo_customer_mobile/src/screens/app_settings_screen.dart';
import 'package:allgo_customer_mobile/src/screens/app_state_screens.dart';

void main() {
  group('Customer Missing Screens Tests (Phase 7)', () {
    testWidgets('HelpFaqScreen renders search, category chips, and questions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpFaqScreen(),
        ),
      );

      expect(find.text('Help Centre & FAQ'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('How do I cancel my order?'), findsOneWidget);
      expect(find.text('Still need help?'), findsOneWidget);
    });

    testWidgets('OffersCouponsScreen renders categories, coupon card, and copy action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OffersCouponsScreen(),
        ),
      );

      expect(find.text('Offers & Coupons'), findsOneWidget);
      expect(find.text('WELCOME50'), findsOneWidget);
      expect(find.text('50% OFF up to ₹100'), findsOneWidget);
      expect(find.text('COPY'), findsWidgets);

      await tester.tap(find.text('COPY').first);
      await tester.pumpAndSettle();
    });

    testWidgets('ReferEarnScreen renders code, share button, and step guide', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ReferEarnScreen(referralCode: 'ALLGO987'),
        ),
      );

      expect(find.text('Refer & Earn'), findsOneWidget);
      expect(find.text('ALLGO987'), findsOneWidget);
      expect(find.text('Share Invite with Friends'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Both Earn ₹100'), findsOneWidget);
    });

    testWidgets('AppSettingsScreen renders switches, theme tile, and clear cache', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppSettingsScreen(),
          ),
        ),
      );

      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('Order Status Updates'), findsOneWidget);
      expect(find.text('Promotions & Discounts'), findsOneWidget);
      expect(find.text('Clear Cache'), findsOneWidget);
    });

    testWidgets('MaintenanceScreen, ForceUpdateScreen, and NoInternetScreen render correctly', (tester) async {
      // 1. Maintenance
      await tester.pumpWidget(
        const MaterialApp(
          home: MaintenanceScreen(),
        ),
      );
      expect(find.text('Scheduled Maintenance'), findsOneWidget);
      expect(find.text('Check Server Status'), findsOneWidget);

      // 2. Force Update
      await tester.pumpWidget(
        const MaterialApp(
          home: ForceUpdateScreen(requiredVersion: '2.4.0'),
        ),
      );
      expect(find.text('Update Required'), findsOneWidget);
      expect(find.text('Update Now on Play Store'), findsOneWidget);

      // 3. No Internet
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: NoInternetScreen(onRetry: () => retried = true),
        ),
      );
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);

      await tester.tap(find.text('Retry Connection'));
      expect(retried, isTrue);
    });
  });
}
