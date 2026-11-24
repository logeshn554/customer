import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:allgo_customer_mobile/src/widgets/connectivity_banner.dart';
import 'package:allgo_customer_mobile/src/widgets/shimmer_box.dart';
import 'package:allgo_customer_mobile/src/common/friendly_error.dart';

void main() {
  group('Customer Polish, Performance & Offline Tests (Phase 9)', () {
    testWidgets('ConnectivityBanner displays offline message when isOffline=true', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectivityBanner(
              isOffline: true,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('No internet connection — showing cached data'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('ConnectivityBanner hides completely when isOffline=false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectivityBanner(isOffline: false),
          ),
        ),
      );

      expect(find.text('No internet connection — showing cached data'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('ShimmerBox renders animated skeleton placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerBox(
              width: 120,
              height: 40,
              borderRadius: 8.0,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerBox), findsOneWidget);
    });

    test('FriendlyError maps technical exceptions to user-friendly messages', () {
      // 1. Socket / Offline Exception
      final networkErr = FriendlyError.from(const SocketException('Failed host lookup'));
      expect(networkErr.title, equals('No Internet Connection'));
      expect(networkErr.message, contains('Please check your Wi-Fi'));
      expect(networkErr.isRetryable, isTrue);

      // 2. Timeout Exception
      final timeoutErr = FriendlyError.from(TimeoutException('Request took too long'));
      expect(timeoutErr.title, equals('Connection Timed Out'));
      expect(timeoutErr.message, contains('The server took too long'));
      expect(timeoutErr.isRetryable, isTrue);

      // 3. Generic Format Exception
      final formatErr = FriendlyError.from(const FormatException('Bad JSON format'));
      expect(formatErr.message, isNotEmpty);
      expect(formatErr.message, isNot(contains('FormatException')));
    });
  });
}
