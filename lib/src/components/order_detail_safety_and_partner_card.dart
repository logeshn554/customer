import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class OrderDetailSafetyAndPartnerCard extends StatelessWidget {
  final CustomerOrderDetail order;
  final VoidCallback onTrackDelivery;

  const OrderDetailSafetyAndPartnerCard({
    super.key,
    required this.order,
    required this.onTrackDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final hasDeliveryJob = order.deliveryJob != null;
    return Column(
      children: [
        if (order.deliveryPin != null && order.status != 'DELIVERED' && order.status != 'CANCELLED') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AllGoColors.primary.withValues(alpha: 0.12), AllGoColors.primary.withValues(alpha: 0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AllGoColors.primary.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, color: AllGoColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Delivery Verification PIN', style: AllGoTypography.heading3.copyWith(fontSize: 15, color: AllGoColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Share this PIN with your delivery partner only after receiving packages:', style: AllGoTypography.caption),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AllGoColors.primary, width: 2)),
                  child: Text(
                    order.deliveryPin!,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8, color: AllGoColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (hasDeliveryJob) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AllGoColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AllGoColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.two_wheeler, color: AllGoColors.primary),
                        const SizedBox(width: 8),
                        Text('Delivery Partner', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text(order.deliveryJob!['status']?.toString() ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue.shade800)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AllGoButton(
                  label: 'Live Track Courier Map',
                  variant: AllGoButtonVariant.outlined,
                  icon: Icons.navigation_outlined,
                  onPressed: onTrackDelivery,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
