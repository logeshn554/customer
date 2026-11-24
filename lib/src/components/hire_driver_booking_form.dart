import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class HireDriverBookingForm extends StatelessWidget {
  final TextEditingController reportingCtrl;
  final int hours;
  final ValueChanged<int> onHoursChanged;
  final String transmission;
  final ValueChanged<String> onTransmissionChanged;
  final Map<String, dynamic>? estimateData;
  final bool isEstimating;
  final bool isBooking;
  final VoidCallback onGetEstimate;
  final VoidCallback onBookDriver;

  const HireDriverBookingForm({
    super.key,
    required this.reportingCtrl,
    required this.hours,
    required this.onHoursChanged,
    required this.transmission,
    required this.onTransmissionChanged,
    required this.estimateData,
    required this.isEstimating,
    required this.isBooking,
    required this.onGetEstimate,
    required this.onBookDriver,
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
                Text('Vehicle & Duty Details', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                AllGoTextField(label: 'Reporting Address', controller: reportingCtrl, prefixIcon: const Icon(Icons.location_on, color: Colors.indigo)),
                const SizedBox(height: 12),
                Text('Duty Duration: $hours Hours', style: AllGoTypography.bodyMedium),
                Slider(
                  value: hours.toDouble(),
                  min: 2,
                  max: 12,
                  divisions: 5,
                  label: '$hours hrs',
                  onChanged: (v) => onHoursChanged(v.toInt()),
                ),
                const SizedBox(height: 12),
                Text('Vehicle Transmission', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onTransmissionChanged('MANUAL'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: transmission == 'MANUAL' ? Colors.indigo.withValues(alpha: 0.1) : null,
                          side: BorderSide(color: transmission == 'MANUAL' ? Colors.indigo : Colors.grey),
                        ),
                        child: const Text('Manual'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onTransmissionChanged('AUTOMATIC'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: transmission == 'AUTOMATIC' ? Colors.indigo.withValues(alpha: 0.1) : null,
                          side: BorderSide(color: transmission == 'AUTOMATIC' ? Colors.indigo : Colors.grey),
                        ),
                        child: const Text('Automatic'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AllGoButton(label: 'Get Chauffeur Estimate', isLoading: isEstimating, onPressed: onGetEstimate),
              ],
            ),
          ),
        ),
        if (estimateData != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.indigo.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Charge ($hours hrs)', style: AllGoTypography.caption.copyWith(color: Colors.indigo.shade900)),
                      Text('₹${estimateData!['estimatedFareInr'] ?? 450}', style: AllGoTypography.heading2.copyWith(color: Colors.indigo.shade900)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isBooking ? null : onBookDriver,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade800, foregroundColor: Colors.white),
                    child: const Text('Book Driver'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
