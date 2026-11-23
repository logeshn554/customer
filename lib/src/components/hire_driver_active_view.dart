import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class HireDriverActiveView extends StatelessWidget {
  final HireDriverBookingModel booking;

  const HireDriverActiveView({
    super.key,
    required this.booking,
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
                    Text('Chauffeur Booking', style: AllGoTypography.heading3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(booking.status, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Reporting Address: ${booking.reportingAddress}', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 8),
                Text('Duty Duration: ${booking.durationHours} Hours', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 8),
                Text('Vehicle: ${booking.transmissionType} Transmission', style: AllGoTypography.bodyMedium),
                const SizedBox(height: 16),
                if (booking.startOdometerKm != null)
                  Text('Start Odometer: ${booking.startOdometerKm} km', style: AllGoTypography.caption),
                if (booking.endOdometerKm != null)
                  Text('End Odometer: ${booking.endOdometerKm} km', style: AllGoTypography.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
