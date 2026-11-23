import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class CheckoutBillSummary extends StatelessWidget {
  final CartPricingModel pricing;

  const CheckoutBillSummary({
    super.key,
    required this.pricing,
  });

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AllGoTypography.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: AllGoTypography.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
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
          Text('Bill Details', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          _buildRow('Item Total', '₹${pricing.subtotalInr.toStringAsFixed(2)}'),
          _buildRow('Delivery Partner Fee', '₹${pricing.deliveryFeeInr.toStringAsFixed(2)}'),
          _buildRow('Packaging Charges', '₹${pricing.packagingFeeInr.toStringAsFixed(2)}'),
          _buildRow('Platform Taxes (GST)', '₹${pricing.taxInr.toStringAsFixed(2)}'),
          if (pricing.discountInr > 0)
            _buildRow('Promotion Discount', '-₹${pricing.discountInr.toStringAsFixed(2)}', color: AllGoColors.success),
          const Divider(height: 20),
          _buildRow('To Pay', '₹${pricing.finalTotalInr.toStringAsFixed(2)}', isBold: true, color: AllGoColors.primary),
        ],
      ),
    );
  }
}
