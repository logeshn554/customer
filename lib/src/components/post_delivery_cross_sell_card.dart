import 'package:flutter/material.dart';

class CrossSellConfig {
  final bool enableFoodToRide;
  final bool enableFoodToParcel;
  final bool enableRideToFood;
  final String rideHeadline;
  final String parcelHeadline;

  const CrossSellConfig({
    this.enableFoodToRide = true,
    this.enableFoodToParcel = true,
    this.enableRideToFood = true,
    this.rideHeadline = 'Need a ride somewhere? Book an AllGo Cab or Auto in seconds.',
    this.parcelHeadline = 'Need to send packages or keys? Send an AllGo Parcel instantly.',
  });

  factory CrossSellConfig.fromRemoteConfig(Map<String, dynamic> params) {
    return CrossSellConfig(
      enableFoodToRide: params['enable_food_to_ride'] as bool? ?? true,
      enableFoodToParcel: params['enable_food_to_parcel'] as bool? ?? true,
      enableRideToFood: params['enable_ride_to_food'] as bool? ?? true,
      rideHeadline: params['cross_sell_ride_headline'] as String? ?? 'Need a ride somewhere? Book an AllGo Cab or Auto in seconds.',
      parcelHeadline: params['cross_sell_parcel_headline'] as String? ?? 'Need to send packages or keys? Send an AllGo Parcel instantly.',
    );
  }
}

class CrossSellBannerView extends StatelessWidget {
  final CrossSellConfig config;
  final VoidCallback onBookRide;
  final VoidCallback onSendParcel;

  const CrossSellBannerView({
    super.key,
    required this.config,
    required this.onBookRide,
    required this.onSendParcel,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.enableFoodToRide && !config.enableFoodToParcel) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFF16A34A), size: 20),
              SizedBox(width: 8),
              Text(
                'Explore More On AllGo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (config.enableFoodToRide) ...[
            Text(config.rideHeadline, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: onBookRide,
              icon: const Icon(Icons.directions_car, size: 16),
              label: const Text('Book a Ride'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
          if (config.enableFoodToRide && config.enableFoodToParcel) const SizedBox(height: 12),
          if (config.enableFoodToParcel) ...[
            Text(config.parcelHeadline, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: onSendParcel,
              icon: const Icon(Icons.local_shipping, size: 16),
              label: const Text('Send a Parcel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF15803D),
                side: const BorderSide(color: Color(0xFF16A34A)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
