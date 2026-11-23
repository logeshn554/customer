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
  final VoidCallback? onPickPickupOnMap;
  final VoidCallback? onPickDestOnMap;

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
    this.onPickPickupOnMap,
    this.onPickDestOnMap,
  });

  Widget _buildCategoryTile(String title, String subtitle, String category, IconData icon, String? fare) {
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
            if (fare != null)
              Text(
                fare,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AllGoColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quoteTotal = estimateData?['totalFareInr'] ?? estimateData?['fareInr'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AllGoTextField(
                        label: 'Pickup Location',
                        controller: pickupCtrl,
                        prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                      ),
                    ),
                    if (onPickPickupOnMap != null)
                      IconButton(
                        icon: const Icon(Icons.map, color: AllGoColors.primary),
                        tooltip: 'Pin on Google Map',
                        onPressed: onPickPickupOnMap,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AllGoTextField(
                        label: 'Destination',
                        controller: destCtrl,
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      ),
                    ),
                    if (onPickDestOnMap != null)
                      IconButton(
                        icon: const Icon(Icons.map, color: AllGoColors.primary),
                        tooltip: 'Pin on Google Map',
                        onPressed: onPickDestOnMap,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                AllGoButton(label: 'Get Fare Estimate', isLoading: isEstimating, onPressed: onGetEstimate),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Choose Ride Option', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        _buildCategoryTile('Bike Taxi', 'Fastest for single rider in traffic', 'BIKE', Icons.two_wheeler, quoteTotal != null && selectedCategory == 'BIKE' ? '₹$quoteTotal' : null),
        _buildCategoryTile('Auto Rickshaw', 'Affordable doorstep 3-wheeler', 'AUTO', Icons.electric_rickshaw, quoteTotal != null && selectedCategory == 'AUTO' ? '₹$quoteTotal' : null),
        _buildCategoryTile('Economy Cab', 'AC Mini & Hatchback', 'CAB_ECONOMY', Icons.directions_car, quoteTotal != null && selectedCategory == 'CAB_ECONOMY' ? '₹$quoteTotal' : null),
        _buildCategoryTile('Premium Cab', 'Comfort Sedan & SUV', 'CAB_PREMIUM', Icons.local_taxi, quoteTotal != null && selectedCategory == 'CAB_PREMIUM' ? '₹$quoteTotal' : null),
        if (estimateData != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Fare:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        '₹${estimateData!['totalFareInr'] ?? estimateData!['fareInr'] ?? "---"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (estimateData!['distanceKm'] != null)
                    Text('Estimated Distance: ${estimateData!['distanceKm']} km | Duration: ${estimateData!['durationMinutes'] ?? 15} mins', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 14),
                  AllGoButton(
                    label: 'Book Now (${selectedCategory.replaceAll('_', ' ')})',
                    icon: Icons.check,
                    isLoading: isBooking,
                    onPressed: onConfirmRide,
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
