import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/order_detail_safety_and_partner_card.dart';
import '../components/order_detail_items_and_pricing.dart';
import '../components/post_delivery_cross_sell_card.dart';
import 'delivery_tracking_screen.dart';

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
      if (mounted) {
        setState(() {
          _order = updated;
          _isLoading = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_order == null) _errorMessage = err.toString();
        });
      }
    }
  }

  Future<void> _cancelOrder() async {
    setState(() => _isCancelling = true);
    try {
      await ref.read(apiClientProvider).cancelCustomerOrder(widget.subOrderId, 'Customer cancelled');
      _refreshOrder();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Widget _buildStatusHeader(CustomerOrderDetail order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllGoColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order.subOrderNumber}', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Placed: ${order.createdAt.contains("T") ? order.createdAt.split("T")[0] : order.createdAt}', style: AllGoTypography.caption),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AllGoColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(order.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AllGoColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null) {
      return Scaffold(
        backgroundColor: AllGoColors.background,
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

    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: Text(order.subOrderNumber),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoading ? null : _refreshOrder),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusHeader(order),
            const SizedBox(height: 16),
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
            OrderDetailItemsAndPricing(order: order),
            if (order.status == 'DELIVERED') ...[
              CrossSellBannerView(
                config: const CrossSellConfig(),
                onBookRide: () => Navigator.of(context).pushNamed('/rides'),
                onSendParcel: () => Navigator.of(context).pushNamed('/parcels'),
              ),
            ],
            if (isCancellable) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _isCancelling ? null : _cancelOrder,
                style: OutlinedButton.styleFrom(foregroundColor: AllGoColors.error, side: const BorderSide(color: AllGoColors.error)),
                child: const Text('Cancel Order'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
