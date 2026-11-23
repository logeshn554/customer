import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../screens/order_detail_screen.dart';

class CustomerOrdersTab extends StatelessWidget {
  final List<CustomerOrderDetail> orders;
  final bool isLoading;
  final VoidCallback onRefresh;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const CustomerOrdersTab({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.onRefresh,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  Widget _buildFilterChip(String label, String value) {
    final isSelected = activeFilter == value;
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AllGoColors.primary : AllGoColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AllGoColors.primary : AllGoColors.divider),
        ),
        child: Text(
          label,
          style: AllGoTypography.caption.copyWith(
            color: isSelected ? Colors.white : AllGoColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = activeFilter == 'ALL'
        ? orders
        : orders.where((o) => o.status == activeFilter).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AllGoColors.surface,
          child: Row(
            children: [
              _buildFilterChip('All Orders', 'ALL'),
              const SizedBox(width: 8),
              _buildFilterChip('Active', 'PLACED'),
              const SizedBox(width: 8),
              _buildFilterChip('Delivered', 'DELIVERED'),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 48, color: AllGoColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('No orders in this category', style: AllGoTypography.subtitle),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => onRefresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final order = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('#${order.subOrderNumber}', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text('Status: ${order.status} • ₹${order.totalInr.toStringAsFixed(0)}', style: AllGoTypography.caption),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => OrderDetailScreen(subOrderId: order.id, initialDetail: order)),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
