import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'home_banner_carousel.dart';
import 'home_category_chips.dart';
import 'home_horizontal_store_row.dart';
import 'home_offers_strip.dart';
import 'unified_active_bookings_tray.dart';
import '../screens/cart_screen.dart';
import '../screens/hire_driver_screen.dart';
import '../screens/outlet_catalog_screen.dart';
import '../screens/parcel_send_screen.dart';
import '../screens/ride_booking_screen.dart';

class CustomerHomeTab extends StatefulWidget {
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

  @override
  State<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends State<CustomerHomeTab> {
  String _selectedCategory = 'ALL';

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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
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
    // Generate dummy recommended outlets for visual discovery if empty
    final mockOutlets = [
      DiscoveryOutlet(
        id: 'out-1',
        merchantId: 'm-1',
        outletName: 'A2B - Adyar Ananda Bhavan',
        businessName: 'A2B Veg',
        outletStatus: 'ACTIVE',
        isOpen: true,
        merchantType: 'FOOD',
        distanceKm: 1.8,
      ),
      DiscoveryOutlet(
        id: 'out-2',
        merchantId: 'm-2',
        outletName: 'BlinkGrocery Super Mart',
        businessName: 'BlinkGrocery',
        outletStatus: 'ACTIVE',
        isOpen: true,
        merchantType: 'GROCERY',
        distanceKm: 1.2,
      ),
      DiscoveryOutlet(
        id: 'out-3',
        merchantId: 'm-3',
        outletName: 'Dindigul Thalappakatti',
        businessName: 'Thalappakatti Biryani',
        outletStatus: 'ACTIVE',
        isOpen: true,
        merchantType: 'FOOD',
        distanceKm: 2.5,
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Header: Location & Cart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.onSelectAddress,
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
                                widget.currentAddressLabel,
                                style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 16, color: AllGoColors.textTertiary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.user != null ? 'Hello, ${widget.user?.fullName ?? "Partner"}' : 'Welcome to AllGo',
                      style: AllGoTypography.heading2.copyWith(fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                tooltip: 'Open cart',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active Bookings Tray
          if (widget.unifiedBookings.isNotEmpty) ...[
            UnifiedActiveBookingsTray(
              bookings: widget.unifiedBookings,
              onRefresh: widget.onRefresh,
            ),
            const SizedBox(height: 12),
          ],

          // Category Filter Chips
          HomeCategoryChips(
            selectedCategory: _selectedCategory,
            onSelectCategory: (cat) {
              setState(() => _selectedCategory = cat);
              widget.onNavigateTab(1);
            },
          ),
          const SizedBox(height: 14),

          // Promotional Banner Carousel
          HomeBannerCarousel(onBannerTap: (_) => widget.onNavigateTab(1)),
          const SizedBox(height: 14),

          // Offers Strip
          HomeOffersStrip(onTap: () => widget.onNavigateTab(1)),
          const SizedBox(height: 18),

          // All Super-App Services Grid
          Text('All Services', style: AllGoTypography.heading3),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              _buildServiceCard(
                context,
                'Food Delivery',
                'Restaurants & Kitchens',
                Icons.restaurant,
                Colors.orange,
                onTap: () => widget.onNavigateTab(1),
              ),
              _buildServiceCard(
                context,
                'Quick Grocery',
                'Delivered in 15 mins',
                Icons.shopping_basket,
                Colors.green,
                onTap: () => widget.onNavigateTab(1),
              ),
              _buildServiceCard(
                context,
                'City Parcel',
                'Porter-style cargo',
                Icons.local_shipping,
                Colors.deepPurple,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ParcelSendScreen()),
                ),
              ),
              _buildServiceCard(
                context,
                'Mobility Rides',
                'Bike, Auto & Cabs',
                Icons.directions_car,
                Colors.teal,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RideBookingScreen()),
                ),
              ),
              _buildServiceCard(
                context,
                'Hire Driver',
                'Chauffeur for your car',
                Icons.airline_seat_recline_normal,
                Colors.indigo,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HireDriverScreen()),
                ),
              ),
              _buildServiceCard(
                context,
                'Order Again',
                'Past favorites & reorder',
                Icons.replay,
                Colors.pink,
                onTap: () => widget.onNavigateTab(2),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Recommended For You Horizontal Row
          HomeHorizontalStoreRow(
            title: 'Recommended For You',
            subtitle: 'Curated outlets delivering in your area',
            outlets: mockOutlets,
            onOutletTap: (out) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OutletCatalogScreen(
                    outletId: out.outletId,
                    outletName: out.outletName,
                    categoryName: out.verticalType,
                  ),
                ),
              );
            },
            onViewAll: () => widget.onNavigateTab(1),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
