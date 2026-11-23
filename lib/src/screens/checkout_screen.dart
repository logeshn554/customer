import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/checkout_address_selector.dart';
import '../components/checkout_payment_selector.dart';
import '../components/checkout_bill_summary.dart';
import 'order_detail_screen.dart';
import 'address_editor_dialog.dart';
import 'saved_addresses_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = true;
  bool _isLoadingAddresses = false;
  bool _isPlacingOrder = false;

  CartModel? _cart;
  CartPricingModel? _pricing;
  List<CustomerAddressModel> _addresses = [];
  CustomerAddressModel? _selectedAddress;
  String _selectedPaymentMethod = 'UPI';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);
    try {
      final cart = await client.getCart();
      final pricing = await client.getCheckoutEstimate(paymentMethod: _selectedPaymentMethod);
      final addresses = await client.listCustomerAddresses().catchError((_) => <CustomerAddressModel>[]);

      if (mounted) {
        setState(() {
          _cart = cart;
          _pricing = pricing;
          _addresses = addresses;
          if (addresses.isNotEmpty) _selectedAddress = addresses.first;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePaymentMethodChanged(String method) async {
    setState(() => _selectedPaymentMethod = method);
    try {
      final updatedPricing = await ref.read(apiClientProvider).getCheckoutEstimate(paymentMethod: method);
      if (mounted) setState(() => _pricing = updatedPricing);
    } catch (_) {}
  }

  Future<void> _showAddAddressDialog() async {
    final newAddr = await showDialog<CustomerAddressModel>(
      context: context,
      builder: (ctx) => const AddressEditorDialog(),
    );

    if (newAddr != null && mounted) {
      setState(() {
        _addresses.add(newAddr);
        _selectedAddress = newAddr;
      });
    }
  }

  Future<void> _handlePlaceOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address')));
      return;
    }
    setState(() => _isPlacingOrder = true);
    try {
      final res = await ref.read(apiClientProvider).placeOrder(
        addressId: _selectedAddress!.id,
        paymentMethod: _selectedPaymentMethod,
      );
      final subOrderId = (res['subOrderId'] ?? res['subOrders']?[0]?['id'] ?? res['id'])?.toString();
      if (mounted && subOrderId != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OrderDetailScreen(subOrderId: subOrderId)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(title: const Text('Checkout & Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CheckoutAddressSelector(
                  addresses: _addresses,
                  selectedAddress: _selectedAddress,
                  isLoading: _isLoadingAddresses,
                  onSelect: (addr) => setState(() => _selectedAddress = addr),
                  onAddNew: _showAddAddressDialog,
                ),
                const SizedBox(height: 16),
                CheckoutPaymentSelector(
                  selectedMethod: _selectedPaymentMethod,
                  onSelectMethod: _handlePaymentMethodChanged,
                ),
                const SizedBox(height: 16),
                if (_pricing != null) ...[
                  CheckoutBillSummary(pricing: _pricing!),
                  const SizedBox(height: 24),
                  AllGoButton(
                    label: 'Pay ₹${_pricing!.finalTotalInr.toStringAsFixed(0)} & Place Order',
                    isLoading: _isPlacingOrder,
                    onPressed: _handlePlaceOrder,
                  ),
                ],
              ],
            ),
    );
  }
}
