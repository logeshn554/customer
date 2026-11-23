import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../screens/outlet_catalog_screen.dart';
import '../screens/parcel_send_screen.dart';
import '../screens/ride_booking_screen.dart';
import '../screens/hire_driver_screen.dart';

class CustomerHomeTab extends StatelessWidget {
  final User? user;
  final List<DeliveryJobModel> activeDeliveries;
  final bool isLoading;
  final VoidCallback onRefresh;
  final void Function(int tabIndex) onNavigateTab;

  const CustomerHomeTab({
    super.key,
    required this.user,
    required this.activeDeliveries,
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
            color: Colors.black.withOpacity(0.03),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AllGoTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AllGoTypography.caption,
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
          // Greeting & Location bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AllGoColors.primary),
                      const SizedBox(width: 4),
                      Text('Chennai, Anna Nagar', style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AllGoColors.textTertiary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user != null ? 'Hello, ${user?.phoneNumber ?? "Guest"}' : 'Welcome to AllGo',
                    style: AllGoTypography.heading2.copyWith(fontSize: 20),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: AllGoColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AllGoColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Promotional Super Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AllGoColors.primary, AllGoColors.primary.withOpacity(0.8)],
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
                          color: Colors.white.withOpacity(0.2),
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
          const SizedBox(height: 24),

          // Services Grid
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
                'Top restaurants & delicacies',
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
                'Fast courier & package delivery',
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
                'Bike, Auto & Cab rides',
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
            ],
          ),
        ],
      ),
    );
  }
}
