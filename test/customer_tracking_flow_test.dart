import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'package:allgo_customer_mobile/src/screens/delivery_tracking_screen.dart';
import 'package:allgo_customer_mobile/src/components/live_trip_tracking_bottom_sheet.dart';

void main() {
  group('Customer Tracking Flow Tests', () {
    testWidgets('DeliveryTrackingScreen initializes and shows loading state or app bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DeliveryTrackingScreen(jobId: 'job_test_tracking_100'),
          ),
        ),
      );

      expect(find.text('Live Tracking'), findsOneWidget);
    });

    testWidgets('LiveTripTrackingBottomSheet displays OTP and tracking details correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveTripTrackingBottomSheet(
              status: 'ON_THE_WAY',
              pickupAddress: 'T. Nagar, Chennai',
              dropoffAddress: 'Velachery, Chennai',
              deliveryOtp: '7412',
              driverLatitude: 13.0827,
              driverLongitude: 80.2707,
              driverSpeedMps: 8.5,
            ),
          ),
        ),
      );

      expect(find.text('Live Order Tracking'), findsOneWidget);
      expect(find.text('7412'), findsOneWidget);
      expect(find.text('Driver WebSocket Telemetry Streaming'), findsOneWidget);
    });
  });
}
