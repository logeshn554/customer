import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class LiveTripTrackingBottomSheet extends StatelessWidget {
  final String status;
  final String pickupAddress;
  final String dropoffAddress;
  final String? deliveryOtp;
  final double? driverLatitude;
  final double? driverLongitude;
  final double? driverHeading;
  final double? driverSpeedMps;
  final VoidCallback? onSnapCameraToDriver;

  const LiveTripTrackingBottomSheet({
    super.key,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.deliveryOtp,
    this.driverLatitude,
    this.driverLongitude,
    this.driverHeading,
    this.driverSpeedMps,
    this.onSnapCameraToDriver,
  });

  int get _stepIndex {
    switch (status.toUpperCase()) {
      case 'PLACED':
      case 'PENDING':
        return 0;
      case 'PREPARING':
      case 'MERCHANT_ACCEPTED':
      case 'READY':
        return 1;
      case 'ON_THE_WAY':
      case 'PICKED_UP':
      case 'IN_TRANSIT':
        return 2;
      case 'ARRIVED':
      case 'DELIVERED':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const steps = ['Placed', 'Preparing', 'On the Way', 'Arrived'];

    return Container(
      decoration: const BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AllGoColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Order Tracking', style: AllGoTypography.heading2),
              if (onSnapCameraToDriver != null)
                IconButton(
                  tooltip: 'Snap Camera to Driver',
                  icon: const Icon(Icons.my_location, color: AllGoColors.primary),
                  onPressed: onSnapCameraToDriver,
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated Progress Stepper
          Row(
            children: List.generate(steps.length, (i) {
              final isCompleted = i <= _stepIndex;
              return Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          isCompleted ? AllGoColors.success : AllGoColors.divider,
                      child: isCompleted
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text('${i + 1}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isCompleted ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted
                              ? AllGoColors.textPrimary
                              : AllGoColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Telemetry Status Card
          if (driverLatitude != null && driverLongitude != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bike, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Driver WebSocket Telemetry Streaming',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                        Text(
                          'Coords: ${driverLatitude!.toStringAsFixed(4)}, ${driverLongitude!.toStringAsFixed(4)} | Speed: ${((driverSpeedMps ?? 0) * 3.6).toStringAsFixed(0)} km/h',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Dynamic 6-Digit Delivery Verification OTP Card
          if (deliveryOtp != null && deliveryOtp!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Verification Code',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      const Text('Share with courier upon doorstep arrival',
                          style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade600),
                    ),
                    child: Text(
                      deliveryOtp!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Route Details
          Text('Pickup: $pickupAddress', style: AllGoTypography.caption),
          const SizedBox(height: 4),
          Text('Dropoff: $dropoffAddress', style: AllGoTypography.caption),
        ],
      ),
    );
  }
}
