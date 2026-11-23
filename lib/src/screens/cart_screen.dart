import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/cart_item_card.dart';
import '../components/cart_bill_details.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isLoading = true;
  CartModel? _cart;
  CartPricingModel? _pricing;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);
    try {
      final cart = await client.getCart();
      CartPricingModel? pricing;
      if (cart.items.isNotEmpty) {
        pricing = await client.getCheckoutEstimate().catchError((_) => null);
      }
      if (mounted) {
        setState(() {
          _cart = cart;
          _pricing = pricing;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(String cartItemId, int qty) async {
    try {
      final updated = await ref.read(apiClientProvider).updateCartItemQuantity(cartItemId, qty);
      final pricing = await ref.read(apiClientProvider).getCheckoutEstimate().catchError((_) => null);
      if (mounted) {
        setState(() {
          _cart = updated;
          _pricing = pricing;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _removeItem(String cartItemId) async {
    try {
      final updated = await ref.read(apiClientProvider).removeCartItem(cartItemId);
      CartPricingModel? pricing;
      if (updated.items.isNotEmpty) {
        pricing = await ref.read(apiClientProvider).getCheckoutEstimate().catchError((_) => null);
      }
      if (mounted) {
        setState(() {
          _cart = updated;
          _pricing = pricing;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Remove failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cart == null || _cart!.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.remove_shopping_cart_outlined, size: 64, color: AllGoColors.textTertiary),
              const SizedBox(height: 16),
              Text('Your cart is empty', style: AllGoTypography.heading2),
              const SizedBox(height: 8),
              Text('Explore restaurants and add items to your cart', style: AllGoTypography.subtitle),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(apiClientProvider).clearCart();
              _loadCartData();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Items from ${_cart!.outletName ?? "Restaurant"}', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          ..._cart!.items.map((item) {
            return CartItemCard(
              item: item,
              onQuantityChanged: (qty) => _updateQuantity(item.id, qty),
              onRemove: () => _removeItem(item.id),
            );
          }),
          const SizedBox(height: 16),
          if (_pricing != null) ...[
            CartBillDetails(pricing: _pricing!),
            const SizedBox(height: 24),
            AllGoButton(
              label: 'Proceed to Checkout - ₹${_pricing!.finalTotalInr.toStringAsFixed(0)}',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
