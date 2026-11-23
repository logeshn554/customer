import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class OrderDetailItemsAndPricing extends StatelessWidget {
  final CustomerOrderDetail order;

  const OrderDetailItemsAndPricing({
    super.key,
    required this.order,
  });

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AllGoTypography.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: AllGoTypography.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllGoColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Items', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          ...order.items.map((it) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${it.quantity}x ${it.productName}', style: AllGoTypography.bodyMedium),
                  Text('₹${it.totalPriceInr.toStringAsFixed(0)}', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
          const Divider(height: 20),
          _buildRow('Subtotal', '₹${order.itemsTotalInr.toStringAsFixed(2)}'),
          _buildRow('Delivery Fee', '₹${order.deliveryFeeInr.toStringAsFixed(2)}'),
          _buildRow('Packaging Fee', '₹${order.packagingFeeInr.toStringAsFixed(2)}'),
          _buildRow('GST & Taxes', '₹${order.taxInr.toStringAsFixed(2)}'),
          const Divider(height: 16),
          _buildRow('Total Paid', '₹${order.totalInr.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }
}
