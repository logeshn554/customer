import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'unified_active_bookings_tray.dart';
import '../screens/parcel_send_screen.dart';
import '../screens/ride_booking_screen.dart';
import '../screens/hire_driver_screen.dart';
import '../screens/cart_screen.dart';

class CustomerHomeTab extends StatelessWidget {
  final User? user;
  final List<DeliveryJobModel> activeDeliveries;
  final List<UnifiedActiveBookingItem> unifiedBookings;
  final String currentAddressLabel;
  final double currentLatitude;
  final double currentLongitude;
  final VoidCallback onSelectAddress;
  final bool isLoading;
  final VoidCallback onRefresh;
  final void Function(int tabIndex) onNavigateTab;

  const CustomerHomeTab({
    super.key,
    required this.user,
    required this.activeDeliveries,
    required this.unifiedBookings,
    required this.currentAddressLabel,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.onSelectAddress,
    required this.isLoading,
    required this.onRefresh,
    required this.onNavigateTab,
  });

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AllGoColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AllGoTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AllGoTypography.caption.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Greeting & Interactive Location bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onSelectAddress,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AllGoColors.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                currentAddressLabel,
                                style: AllGoTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AllGoColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down, size: 16, color: AllGoColors.textTertiary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user != null ? 'Hello, ${user?.fullName ?? user?.phoneNumber ?? "Partner"}' : 'Welcome to AllGo',
                      style: AllGoTypography.heading2.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AllGoColors.textPrimary),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  CircleAvatar(
                    backgroundColor: AllGoColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AllGoColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Unified Active Bookings Tray
          if (unifiedBookings.isNotEmpty)
            UnifiedActiveBookingsTray(
              bookings: unifiedBookings,
              onRefresh: onRefresh,
            ),

          // Promotional Super Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AllGoColors.primary, AllGoColors.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ALLGO SUPERPASS',
                          style: AllGoTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Zero Delivery Fee On Food & Rides',
                        style: AllGoTypography.heading3.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.stars, color: Colors.amber, size: 48),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // All Super-App Services Grid
          Text('All Services', style: AllGoTypography.heading3),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _buildServiceCard(
                context,
                'Food Delivery',
                'Restaurants & Cloud Kitchens',
                Icons.restaurant,
                Colors.orange,
                onTap: () => onNavigateTab(1),
              ),
              _buildServiceCard(
                context,
                'Quick Grocery',
                'Delivered in 15 mins',
                Icons.shopping_basket,
                Colors.green,
                onTap: () => onNavigateTab(1),
              ),
              _buildServiceCard(
                context,
                'City Parcel',
                'Porter-style cargo & couriers',
                Icons.local_shipping,
                Colors.deepPurple,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ParcelSendScreen()),
                  );
                },
              ),
              _buildServiceCard(
                context,
                'Mobility Rides',
                'Bike Taxi, Auto & Cabs',
                Icons.directions_car,
                Colors.teal,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RideBookingScreen()),
                  );
                },
              ),
              _buildServiceCard(
                context,
                'Hire Driver',
                'Chauffeur for your car',
                Icons.airline_seat_recline_normal,
                Colors.indigo,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HireDriverScreen()),
                  );
                },
              ),
              _buildServiceCard(
                context,
                'Home Sellers',
                'Homemade foods & snacks',
                Icons.cookie,
                Colors.pink,
                onTap: () => onNavigateTab(1),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
