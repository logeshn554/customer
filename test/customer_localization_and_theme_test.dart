import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_customer_mobile/src/localization/app_localizations.dart';
import 'package:allgo_customer_mobile/src/components/theme_selection_sheet.dart';
import 'package:allgo_customer_mobile/src/theme/app_theme_customer.dart';

void main() {
  group('Customer Localization & Theme Tests (Phase 2)', () {
    test('AppLocalizations defines strings in en, hi, and ta', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(en.appTitle, 'AllGo Super App');
      expect(en.save, 'Save');
      expect(en.tabHome, 'Home');
      expect(en.tabExplore, 'Explore');
      expect(en.myCart, 'My Cart');

      final hi = await AppLocalizations.delegate.load(const Locale('hi'));
      expect(hi.appTitle, 'AllGo सुपर ऐप');
      expect(hi.save, 'सहेजें');
      expect(hi.tabHome, 'होम');

      final ta = await AppLocalizations.delegate.load(const Locale('ta'));
      expect(ta.appTitle, 'AllGo சூப்பர் ஆப்');
      expect(ta.save, 'சேமி');
      expect(ta.tabHome, 'முகப்பு');
    });

    test('AllGoCustomerTheme defines high contrast light and dark themes', () {
      final light = AllGoCustomerTheme.lightTheme;
      final dark = AllGoCustomerTheme.darkTheme;

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AllGoCustomerTheme.darkBackground);
    });

    testWidgets('ThemeSelectionSheet renders System, Light, and Dark options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: ThemeSelectionSheet(),
            ),
          ),
        ),
      );

      expect(find.text('App Theme'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      // Tap Dark Mode option
      await tester.tap(find.text('Dark Mode'));
      await tester.pump();
    });
  });
}
