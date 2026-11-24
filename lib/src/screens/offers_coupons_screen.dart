import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class OffersCouponsScreen extends StatefulWidget {
  const OffersCouponsScreen({super.key});

  @override
  State<OffersCouponsScreen> createState() => _OffersCouponsScreenState();
}

class _OffersCouponsScreenState extends State<OffersCouponsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<_CouponItem> coupons = [
    _CouponItem(
      code: 'WELCOME50',
      category: 'Food',
      discount: '50% OFF up to ₹100',
      description: 'Get 50% discount on your first order across any restaurant outlet.',
      minOrder: 'Min order ₹199',
      validTill: 'Valid till 31 Dec 2026',
    ),
    _CouponItem(
      code: 'FEAST100',
      category: 'Food',
      discount: 'Flat ₹100 OFF',
      description: 'Enjoy delicious meals with a flat ₹100 savings on party & family orders.',
      minOrder: 'Min order ₹499',
      validTill: 'Valid till 30 Nov 2026',
    ),
    _CouponItem(
      code: 'FREESHIP',
      category: 'Groceries',
      discount: 'Free Delivery',
      description: 'Zero delivery charges on daily household essentials and fresh dairy items.',
      minOrder: 'Min order ₹149',
      validTill: 'Valid till 15 Dec 2026',
    ),
    _CouponItem(
      code: 'PARCEL25',
      category: 'Rides',
      discount: '25% OFF Couriers',
      description: 'Save 25% on intra-city parcel bookings and bike courier shipments.',
      minOrder: 'No minimum',
      validTill: 'Valid till 31 Dec 2026',
    ),
    _CouponItem(
      code: 'RIDEFAST',
      category: 'Rides',
      discount: 'Flat ₹40 OFF',
      description: 'Special commuter discount on instant cab and auto ride bookings.',
      minOrder: 'Min trip ₹100',
      validTill: 'Valid till 28 Nov 2026',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyCouponCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon code "$code" copied to clipboard!'),
        backgroundColor: AllGoColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Offers & Coupons'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AllGoColors.primary,
          unselectedLabelColor: AllGoColors.textTertiary,
          indicatorColor: AllGoColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Food'),
            Tab(text: 'Groceries'),
            Tab(text: 'Rides'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCouponList(coupons),
          _buildCouponList(coupons.where((c) => c.category == 'Food').toList()),
          _buildCouponList(coupons.where((c) => c.category == 'Groceries').toList()),
          _buildCouponList(coupons.where((c) => c.category == 'Rides').toList()),
        ],
      ),
    );
  }

  Widget _buildCouponList(List<_CouponItem> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No active coupons in this category'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final theme = Theme.of(context);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AllGoColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.code,
                        style: const TextStyle(
                          color: AllGoColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('COPY', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _copyCouponCode(item.code),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.discount,
                  style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AllGoTypography.bodyMedium.copyWith(color: AllGoColors.textSecondary, height: 1.4),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.minOrder, style: AllGoTypography.caption),
                    Text(item.validTill, style: AllGoTypography.caption.copyWith(color: AllGoColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CouponItem {
  final String code;
  final String category;
  final String discount;
  final String description;
  final String minOrder;
  final String validTill;

  const _CouponItem({
    required this.code,
    required this.category,
    required this.discount,
    required this.description,
    required this.minOrder,
    required this.validTill,
  });
}
