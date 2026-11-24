import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../repositories/payment_options_repository.dart';

class CartCouponSection extends ConsumerStatefulWidget {
  final double orderTotal;
  final String? appliedCoupon;
  final double discountAmount;
  final void Function(String code, double discount) onCouponApplied;
  final VoidCallback onCouponRemoved;

  const CartCouponSection({
    super.key,
    required this.orderTotal,
    required this.appliedCoupon,
    required this.discountAmount,
    required this.onCouponApplied,
    required this.onCouponRemoved,
  });

  @override
  ConsumerState<CartCouponSection> createState() => _CartCouponSectionState();
}

class _CartCouponSectionState extends ConsumerState<CartCouponSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isChecking = false;
  String? _errorMsg;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyCode(String code) async {
    if (code.trim().isEmpty) return;
    setState(() {
      _isChecking = true;
      _errorMsg = null;
    });

    final repo = ref.read(paymentOptionsRepositoryProvider);
    final res = await repo.validateCoupon(code, widget.orderTotal);

    if (mounted) {
      setState(() => _isChecking = false);
      if (res.isValid) {
        widget.onCouponApplied(code.toUpperCase(), res.discountAmount);
        _controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Coupon applied!'),
            backgroundColor: AllGoColors.success,
          ),
        );
      } else {
        setState(() => _errorMsg = res.message ?? 'Invalid coupon code');
      }
    }
  }

  void _showAvailableOffers() async {
    final repo = ref.read(paymentOptionsRepositoryProvider);
    final coupons = await repo.getAvailableCoupons();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Offers & Coupons', style: AllGoTypography.heading3),
              const SizedBox(height: 12),
              ...coupons.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AllGoColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AllGoColors.primary)),
                          Text(c.title, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          Text(c.description, style: AllGoTypography.caption),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllGoColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(70, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _applyCode(c.code);
                      },
                      child: const Text('APPLY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appliedCoupon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AllGoColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AllGoColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AllGoColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coupon "${widget.appliedCoupon}" Applied',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AllGoColors.success, fontSize: 13),
                  ),
                  Text(
                    'You saved ₹${widget.discountAmount.toStringAsFixed(0)} on this order',
                    style: AllGoTypography.caption,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onCouponRemoved,
              child: const Text('Remove', style: TextStyle(color: AllGoColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  prefixIcon: const Icon(Icons.local_offer_outlined, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  errorText: _errorMsg,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isChecking ? null : () => _applyCode(_controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AllGoColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isChecking
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          icon: const Icon(Icons.discount_outlined, size: 16, color: AllGoColors.primary),
          label: const Text('View Available Offers', style: TextStyle(color: AllGoColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          onPressed: _showAvailableOffers,
        ),
      ],
    );
  }
}
