import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class ActiveRideTrackingView extends StatelessWidget {
  final RideModel ride;
  final bool isCancelling;
  final bool isTriggeringSos;
  final VoidCallback onCancel;
  final VoidCallback onTriggerSos;

  const ActiveRideTrackingView({
    super.key,
    required this.ride,
    required this.isCancelling,
    required this.isTriggeringSos,
    required this.onCancel,
    required this.onTriggerSos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${ride.serviceType} Ride', style: AllGoTypography.heading3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(ride.status, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (ride.startOtp != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Start Ride OTP (Share with driver):', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(ride.startOtp!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.brown)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text('Pickup: ${ride.pickupAddress}', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 6),
                Text('Destination: ${ride.destinationAddress}', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.warning, color: Colors.red),
                        label: const Text('SOS Safety'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        onPressed: isTriggeringSos ? null : onTriggerSos,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (ride.status == 'REQUESTED' || ride.status == 'SEARCHING' || ride.status == 'DRIVER_ASSIGNED')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isCancelling ? null : onCancel,
                          child: const Text('Cancel Ride'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
