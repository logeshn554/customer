import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class ParcelActiveTrackingCard extends StatelessWidget {
  final ParcelModel parcel;
  final bool isCancelling;
  final VoidCallback onCancel;
  final VoidCallback onRefresh;

  const ParcelActiveTrackingCard({
    super.key,
    required this.parcel,
    required this.isCancelling,
    required this.onCancel,
    required this.onRefresh,
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
                    Text('Parcel #${parcel.id.substring(0, 8)}', style: AllGoTypography.heading3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        parcel.status,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepPurple.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Pickup: ${parcel.pickupAddress}', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 8),
                Text('Dropoff: ${parcel.dropoffAddress}', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 16),
                if (parcel.pickupOtp != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pickup Verification OTP:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(parcel.pickupOtp!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (parcel.deliveryOtp != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Recipient OTP:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(parcel.deliveryOtp!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (parcel.status == 'REQUESTED' || parcel.status == 'QUOTE_ACCEPTED')
                  AllGoButton(
                    label: 'Cancel Courier Booking',
                    variant: AllGoButtonVariant.outlined,
                    isLoading: isCancelling,
                    onPressed: onCancel,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
