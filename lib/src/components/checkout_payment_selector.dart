import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class CheckoutPaymentSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onSelectMethod;

  const CheckoutPaymentSelector({
    super.key,
    required this.selectedMethod,
    required this.onSelectMethod,
  });

  Widget _buildMethodTile(String title, String subtitle, String method, IconData icon) {
    final isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () => onSelectMethod(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AllGoColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AllGoColors.primary : AllGoColors.divider),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AllGoColors.primary : Colors.grey, size: 20),
            const SizedBox(width: 12),
            Icon(icon, color: AllGoColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AllGoTypography.caption),
                ],
              ),
            ),
          ],
        ),
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
          Text('Select Payment Method', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          _buildMethodTile('UPI Instant (GPay / PhonePe / Paytm)', 'Instant cashless payment', 'UPI', Icons.account_balance),
          _buildMethodTile('Credit / Debit Card', 'Visa, Mastercard, RuPay', 'CARD', Icons.credit_card),
          _buildMethodTile('AllGo Wallet', '1-click seamless checkout', 'WALLET', Icons.account_balance_wallet),
          _buildMethodTile('Cash on Delivery (COD)', 'Pay at your doorstep', 'COD', Icons.money),
        ],
      ),
    );
  }
}
