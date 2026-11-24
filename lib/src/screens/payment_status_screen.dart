import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

enum PaymentFailureType { failed, pending }

class PaymentStatusScreen extends StatelessWidget {
  final PaymentFailureType type;
  final String orderId;
  final double amount;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onChangeMethod;

  const PaymentStatusScreen({
    super.key,
    required this.type,
    required this.orderId,
    required this.amount,
    this.errorMessage,
    required this.onRetry,
    required this.onChangeMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isFailed = type == PaymentFailureType.failed;
    final color = isFailed ? AllGoColors.error : Colors.amber;
    final icon = isFailed ? Icons.error_outline_rounded : Icons.hourglass_top_rounded;
    final title = isFailed ? 'Payment Failed' : 'Payment Pending';
    final defaultSubtitle = isFailed
        ? 'Your bank or payment provider declined the transaction. No amount has been deducted.'
        : 'We are waiting for payment confirmation from your bank. Please do not re-pay immediately.';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 50),
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: AllGoTypography.heading2),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? defaultSubtitle,
                style: AllGoTypography.caption.copyWith(fontSize: 13),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount to Pay', style: TextStyle(color: AllGoColors.textTertiary)),
                    Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const Spacer(),
              AllGoButton(
                label: 'Retry Payment',
                onPressed: onRetry,
              ),
              const SizedBox(height: 12),
              AllGoButton(
                label: 'Change Payment Method',
                variant: AllGoButtonVariant.outlined,
                onPressed: onChangeMethod,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
