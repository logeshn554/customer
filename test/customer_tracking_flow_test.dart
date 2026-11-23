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

    testWidgets('LiveTripTrackingBottomSheet displays OTP, ETA and driver details correctly', (tester) async {
      final mockJob = DeliveryJobModel(
        id: 'job_test_tracking_100',
        orderId: 'ord_sample_101',
        orderNumber: 'AG-2026-9999',
        status: 'OUT_FOR_DELIVERY',
        pickupAddress: 'T. Nagar, Chennai',
        deliveryAddress: 'Velachery, Chennai',
        deliveryOtp: '7412',
        driverName: 'Karthik Raja',
        driverPhone: '+919988776655',
        driverVehicleNumber: 'TN 09 AB 1234',
        estimatedMinutesRemaining: 12,
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 12)),
        items: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveTripTrackingBottomSheet(job: mockJob),
          ),
        ),
      );

      expect(find.text('Karthik Raja'), findsOneWidget);
      expect(find.text('TN 09 AB 1234'), findsOneWidget);
      expect(find.text('7412'), findsOneWidget);
      expect(find.text('12 mins'), findsOneWidget);
      expect(find.text('Delivery PIN'), findsOneWidget);
    });
  });
}
