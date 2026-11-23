import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class DeliveryTrackingStepper extends StatelessWidget {
  final int currentStep;

  const DeliveryTrackingStepper({
    super.key,
    required this.currentStep,
  });

  static const _steps = [
    'Order Assigned',
    'Arrived at Store',
    'Food Picked Up',
    'Arrived at Doorstep',
    'Order Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllGoColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Delivery Progress', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (i) {
            final isDone = i <= currentStep;
            return Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: isDone ? AllGoColors.success : AllGoColors.divider,
                  child: isDone ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Text(
                  _steps[i],
                  style: TextStyle(
                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                    color: isDone ? AllGoColors.textPrimary : AllGoColors.textTertiary,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
