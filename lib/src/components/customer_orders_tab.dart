import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../screens/order_detail_screen.dart';
import '../widgets/app_network_image.dart';
import '../widgets/empty_state_view.dart';

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
          color: isSelected ? AllGoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AllGoColors.primary : AllGoColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AllGoColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;
    String label = status.replaceAll('_', ' ');

    switch (status) {
      case 'DELIVERED':
        bg = Colors.green.shade50;
        text = Colors.green.shade800;
        break;
      case 'OUT_FOR_DELIVERY':
        bg = Colors.indigo.shade50;
        text = Colors.indigo.shade800;
        break;
      case 'PREPARING':
      case 'MERCHANT_ACCEPTED':
        bg = Colors.orange.shade50;
        text = Colors.orange.shade800;
        break;
      case 'CANCELLED':
        bg = Colors.red.shade50;
        text = Colors.red.shade800;
        break;
      default:
        bg = Colors.blue.shade50;
        text = Colors.blue.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $ampm';
    } catch (_) {
      return isoString.contains('T') ? isoString.split('T')[0] : isoString;
    }
  }

  String _getItemSummary(List<dynamic> items) {
    if (items.isEmpty) return 'Items details';
    final parts = items.map((i) {
      if (i is Map<String, dynamic>) {
        final name = i['name'] ?? i['item_name'] ?? 'Item';
        final qty = i['quantity'] ?? 1;
        return '$qty× $name';
      }
      return i.toString();
    }).toList();
    return parts.join(', ');
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
          color: Theme.of(context).cardColor,
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
                  ? EmptyStateView(
                      icon: Icons.receipt_long,
                      title: 'No orders found',
                      message: 'You have no orders matching the selected filter.',
                      actionLabel: 'Refresh',
                      onAction: onRefresh,
                    )
                  : RefreshIndicator(
                      onRefresh: () async => onRefresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final order = filtered[index];
                          final outletName = order.outlet['name']?.toString() ?? order.outlet['outlet_name']?.toString() ?? 'Store';
                          final dateStr = _formatDate(order.createdAt);
                          final itemsSummary = _getItemSummary(order.items);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailScreen(
                                      subOrderId: order.id,
                                      initialDetail: order,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppNetworkImage(
                                      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150',
                                      width: 56,
                                      height: 56,
                                      borderRadius: BorderRadius.circular(10),
                                      fallbackIcon: Icons.restaurant,
                                      semanticsLabel: outletName,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  outletName,
                                                  style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _buildStatusChip(order.status),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '#${order.subOrderNumber} • $dateStr',
                                            style: AllGoTypography.caption.copyWith(fontSize: 11, color: AllGoColors.textTertiary),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            itemsSummary,
                                            style: AllGoTypography.caption.copyWith(color: AllGoColors.textSecondary),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₹${order.totalInr.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
