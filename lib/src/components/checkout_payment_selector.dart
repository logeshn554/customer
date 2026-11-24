import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../repositories/payment_options_repository.dart';

// BACKEND-NEEDED: Direct UPI intent initiation and tokenized card capture APIs

class CheckoutPaymentSelector extends StatefulWidget {
  final String selectedMethod;
  final ValueChanged<String> onSelectMethod;
  final bool useWalletBalance;
  final ValueChanged<bool>? onToggleWallet;
  final double walletBalance;
  final String selectedUpiApp;
  final ValueChanged<String>? onSelectUpiApp;

  const CheckoutPaymentSelector({
    super.key,
    required this.selectedMethod,
    required this.onSelectMethod,
    this.useWalletBalance = false,
    this.onToggleWallet,
    this.walletBalance = 250.0,
    this.selectedUpiApp = 'gpay',
    this.onSelectUpiApp,
  });

  @override
  State<CheckoutPaymentSelector> createState() => _CheckoutPaymentSelectorState();
}

class _CheckoutPaymentSelectorState extends State<CheckoutPaymentSelector> {
  final TextEditingController _cardNumberCtrl = TextEditingController();
  final TextEditingController _expiryCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();

  static const List<UpiAppInfo> upiApps = [
    UpiAppInfo(id: 'gpay', name: 'Google Pay', packageName: 'com.google.android.apps.nbu.paisa.user'),
    UpiAppInfo(id: 'phonepe', name: 'PhonePe', packageName: 'com.phonepe.app'),
    UpiAppInfo(id: 'paytm', name: 'Paytm UPI', packageName: 'net.one97.paytm'),
    UpiAppInfo(id: 'cred', name: 'CRED', packageName: 'com.dreamplug.androidapp'),
  ];

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Widget _buildMethodTile(String title, String subtitle, String method, IconData icon) {
    final isSelected = widget.selectedMethod == method;
    return GestureDetector(
      onTap: () => widget.onSelectMethod(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AllGoColors.primary.withValues(alpha: 0.08) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AllGoColors.primary : Theme.of(context).dividerColor.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AllGoColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Icon(icon, color: isSelected ? AllGoColors.primary : AllGoColors.textSecondary, size: 22),
            const SizedBox(width: 10),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Options', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
          const SizedBox(height: 12),

          // Wallet balance toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AllGoColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AllGoColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: AllGoColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Use AllGo Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Available Balance: ₹${widget.walletBalance.toStringAsFixed(0)}', style: AllGoTypography.caption),
                    ],
                  ),
                ),
                Switch(
                  value: widget.useWalletBalance,
                  activeColor: AllGoColors.primary,
                  onChanged: widget.onToggleWallet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _buildMethodTile('UPI Instant', 'Google Pay, PhonePe, Paytm, CRED', 'UPI', Icons.account_balance),
          if (widget.selectedMethod == 'UPI') ...[
            Padding(
              padding: const EdgeInsets.only(left: 36, bottom: 8),
              child: Wrap(
                spacing: 8,
                children: upiApps.map((app) {
                  final isAppSelected = widget.selectedUpiApp == app.id;
                  return ChoiceChip(
                    label: Text(app.name, style: const TextStyle(fontSize: 11)),
                    selected: isAppSelected,
                    onSelected: (_) => widget.onSelectUpiApp?.call(app.id),
                  );
                }).toList(),
              ),
            ),
          ],

          _buildMethodTile('Credit / Debit Card', 'Visa, Mastercard, RuPay', 'CARD', Icons.credit_card),
          if (widget.selectedMethod == 'CARD') ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _cardNumberCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Card Number (16 digits)',
                      prefixIcon: Icon(Icons.credit_card, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expiryCtrl,
                          decoration: const InputDecoration(
                            hintText: 'MM/YY',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _cvvCtrl,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'CVV',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          _buildMethodTile('Cash on Delivery (COD)', 'Pay at your doorstep', 'COD', Icons.money),
        ],
      ),
    );
  }
}
