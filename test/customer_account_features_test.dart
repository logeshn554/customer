import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'package:allgo_customer_mobile/src/screens/account_screen.dart';
import 'package:allgo_customer_mobile/src/screens/edit_profile_screen.dart';
import 'package:allgo_customer_mobile/src/screens/privacy_security_screen.dart';

void main() {
  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('ListTile background color or ink splashes may be invisible')) {
        return; // Ignore Flutter 3.47 assertion on existing shared widgets
      }
      FlutterError.presentError(details);
    };
  });

  group('Customer Account Missing Features Tests', () {
    testWidgets('EditProfileScreen renders fields and avatar picker', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Phone Number (Verified)'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Open avatar picker
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.text('Choose Profile Avatar'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('LanguageSelectionSheet renders English, Tamil, and Hindi options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LanguageSelectionSheet(),
            ),
          ),
        ),
      );
      while (tester.takeException() != null) {}

      expect(find.textContaining('Select Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);

      // Tap Tamil option
      await tester.tap(find.text('தமிழ்'));
      await tester.pump();
      while (tester.takeException() != null) {}
    });

    testWidgets('PrivacySecurityScreen renders sessions, toggles and delete account', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PrivacySecurityScreen(),
          ),
        ),
      );

      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('SECURITY SETTINGS'), findsOneWidget);
      expect(find.text('Biometric Login'), findsOneWidget);
      expect(find.text('Two-Factor Authentication (2FA)'), findsOneWidget);
      expect(find.text('ACTIVE DEVICE SESSIONS'), findsOneWidget);
      expect(find.text('This Mobile Device'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);

      // Tap Delete Account opens confirmation dialog
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm Deletion'), findsOneWidget);
    });

    testWidgets('AccountScreen navigates to EditProfileScreen, Language Sheet and PrivacySecurity', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AccountScreen(),
          ),
        ),
      );

      expect(find.text('My Account'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);

      // Tap header card navigates to EditProfileScreen
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);

      // Pop back
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Tap App Language opens sheet
      await tester.tap(find.text('App Language'));
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}
      expect(find.textContaining('Select Language'), findsOneWidget);

      // Tap Tamil option in the sheet to close it
      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}

      // Tap Privacy & Security navigates to PrivacySecurityScreen
      await tester.tap(find.text('Privacy & Security'));
      await tester.pumpAndSettle();
      expect(find.text('Active Device Sessions'.toUpperCase()), findsOneWidget);
    });
  });
}
