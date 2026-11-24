import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'customer_home_shell.dart';
import 'order_detail_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final String? storeName;
  final double totalAmount;
  final String eta;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    this.storeName,
    required this.totalAmount,
    this.eta = '25-35 mins',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CustomerHomeShell()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AllGoColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, color: AllGoColors.success, size: 64),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Order Placed Successfully!', style: AllGoTypography.heading2, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Your order has been sent to ${storeName ?? "the merchant"} and is being prepared.',
                  style: AllGoTypography.caption.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Reference', style: TextStyle(color: AllGoColors.textTertiary, fontSize: 13)),
                          Text('#${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Paid', style: TextStyle(color: AllGoColors.textTertiary, fontSize: 13)),
                          Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AllGoColors.success)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Delivery', style: TextStyle(color: AllGoColors.textTertiary, fontSize: 13)),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 16, color: AllGoColors.primary),
                              const SizedBox(width: 4),
                              Text(eta, style: const TextStyle(fontWeight: FontWeight.bold, color: AllGoColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AllGoButton(
                  label: 'Track Order',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => OrderDetailScreen(subOrderId: orderId)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const CustomerHomeShell()),
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Home', style: TextStyle(fontWeight: FontWeight.bold, color: AllGoColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
