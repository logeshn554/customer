import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../common/friendly_error.dart';
import '../components/order_detail_safety_and_partner_card.dart';
import '../components/order_detail_items_and_pricing.dart';
import 'cart_screen.dart';
import 'delivery_tracking_screen.dart';
import 'rate_review_screen.dart';
import 'support_screen.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String subOrderId;
  final CustomerOrderDetail? initialDetail;

  const OrderDetailScreen({
    super.key,
    required this.subOrderId,
    this.initialDetail,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  CustomerOrderDetail? _order;
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _order = widget.initialDetail;
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    setState(() {
      _isLoading = _order == null;
      _errorMessage = null;
    });
    try {
      final updated = await ref.read(apiClientProvider).getCustomerOrderDetail(widget.subOrderId);
      if (mounted) setState(() { _order = updated; _isLoading = false; });
    } catch (err, st) {
      if (mounted) {
        final f = FriendlyError.from(err, st);
        setState(() {
          _isLoading = false;
          if (_order == null) _errorMessage = f.message;
        });
      }
    }
  }

  Future<void> _handleReorder() async {
    final order = _order;
    if (order == null) return;
    try {
      final client = ref.read(apiClientProvider);
      final outletId = order.outlet['id']?.toString() ?? '';
      for (final item in order.items) {
        if (item is Map<String, dynamic>) {
          final pid = item['id']?.toString() ?? item['productId']?.toString();
          final qty = (item['quantity'] as num?)?.toInt() ?? 1;
          if (pid != null) {
            await client.addToCart(outletId: outletId, productId: pid, quantity: qty).catchError((_) => CartModel.empty());
          }
        }
      }
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
      }
    } catch (e, st) {
      final f = FriendlyError.from(e, st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  Future<void> _confirmCancelOrder() async {
    final order = _order;
    if (order == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AllGoColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '100% Refund Info: ₹${order.totalInr.toStringAsFixed(0)} will be refunded instantly to your AllGo Wallet.',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AllGoColors.success),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Don\'t Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Cancellation', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    try {
      await ref.read(apiClientProvider).cancelCustomerOrder(widget.subOrderId, 'Customer cancelled');
      _refreshOrder();
    } catch (e, st) {
      final f = FriendlyError.from(e, st);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message)));
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _downloadInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tax Invoice for #${_order?.subOrderNumber} downloaded successfully.'),
        backgroundColor: AllGoColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage ?? 'Order not found', style: AllGoTypography.subtitle),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _refreshOrder, child: const Text('Retry')),
                  ],
                ),
        ),
      );
    }

    final isCancellable = order.status == 'PLACED' || order.status == 'MERCHANT_ACCEPTED';
    final outletName = order.outlet['name']?.toString() ?? 'Store';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Order #${order.subOrderNumber}'),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), tooltip: 'Help & Support', onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerSupportScreen()));
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Order Safety & Courier Card
            OrderDetailSafetyAndPartnerCard(
              order: order,
              onTrackDelivery: () {
                if (order.deliveryJob != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(jobId: order.deliveryJob!['id']?.toString() ?? '')),
                  );
                }
              },
            ),
            const SizedBox(height: 14),

            // Items & Pricing Breakdown
            OrderDetailItemsAndPricing(order: order),
            const SizedBox(height: 16),

            // Post-order Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('Invoice'),
                    onPressed: _downloadInvoice,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Rate'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RateReviewScreen(
                            orderId: order.id,
                            outletName: outletName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.replay, size: 18, color: Colors.white),
                    label: const Text('Reorder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.primary),
                    onPressed: _handleReorder,
                  ),
                ),
              ],
            ),

            if (isCancellable) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isCancelling ? null : _confirmCancelOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AllGoColors.error,
                  side: const BorderSide(color: AllGoColors.error),
                ),
                child: _isCancelling
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AllGoColors.error))
                    : const Text('Cancel Order'),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
