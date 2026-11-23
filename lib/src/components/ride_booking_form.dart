import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class RideBookingForm extends StatelessWidget {
  final TextEditingController pickupCtrl;
  final TextEditingController destCtrl;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final Map<String, dynamic>? estimateData;
  final bool isEstimating;
  final bool isBooking;
  final VoidCallback onGetEstimate;
  final VoidCallback onConfirmRide;

  const RideBookingForm({
    super.key,
    required this.pickupCtrl,
    required this.destCtrl,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.estimateData,
    required this.isEstimating,
    required this.isBooking,
    required this.onGetEstimate,
    required this.onConfirmRide,
  });

  Widget _buildCategoryTile(String title, String subtitle, String category, IconData icon) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => onSelectCategory(category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AllGoColors.primary.withOpacity(0.08) : AllGoColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AllGoColors.primary : AllGoColors.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AllGoColors.primary : Colors.grey, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AllGoTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AllGoTextField(label: 'Pickup Location', controller: pickupCtrl, prefixIcon: const Icon(Icons.my_location, color: Colors.green)),
                const SizedBox(height: 12),
                AllGoTextField(label: 'Destination', controller: destCtrl, prefixIcon: const Icon(Icons.location_on, color: Colors.red)),
                const SizedBox(height: 12),
                AllGoButton(label: 'Get Fare Estimate', isLoading: isEstimating, onPressed: onGetEstimate),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Choose Ride Option', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        _buildCategoryTile('Bike Taxi', 'Fastest through traffic • 1 Person', 'BIKE_TAXI', Icons.two_wheeler),
        _buildCategoryTile('Auto Rickshaw', 'Affordable doorstep rides • 3 People', 'AUTO', Icons.electric_rickshaw),
        _buildCategoryTile('Cab Economy', 'Air-conditioned compact rides • 4 People', 'CAB_ECONOMY', Icons.directions_car),
        _buildCategoryTile('Cab Premium', 'Spacious sedans & top drivers', 'CAB_PREMIUM', Icons.local_taxi),
        if (estimateData != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Fare', style: AllGoTypography.caption.copyWith(color: Colors.teal.shade900)),
                      Text('₹${estimateData!['estimatedFareInr'] ?? 150}', style: AllGoTypography.heading2.copyWith(color: Colors.teal.shade900)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isBooking ? null : onConfirmRide,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
                    child: const Text('Confirm Ride'),
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
