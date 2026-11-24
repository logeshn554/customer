import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../common/friendly_error.dart';
import '../components/checkout_address_selector.dart';
import '../components/checkout_bill_summary.dart';
import '../components/checkout_payment_selector.dart';
import '../repositories/payment_options_repository.dart';
import 'address_editor_dialog.dart';
import 'order_success_screen.dart';
import 'payment_status_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String? couponCode;
  final double discountAmount;
  final double deliveryTip;
  final List<String> instructions;
  final String? cookingNotes;
  final String deliverySlot;

  const CheckoutScreen({
    super.key,
    this.couponCode,
    this.discountAmount = 0.0,
    this.deliveryTip = 0.0,
    this.instructions = const [],
    this.cookingNotes,
    this.deliverySlot = 'NOW',
  });

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
  bool _useWalletBalance = false;
  double _walletBalance = 250.0;
  String _selectedUpiApp = 'gpay';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);
    final repo = ref.read(paymentOptionsRepositoryProvider);
    try {
      final results = await Future.wait<dynamic>([
        client.getCart(),
        client.getCheckoutEstimate(paymentMethod: _selectedPaymentMethod).catchError((_) => null as dynamic),
        client.listCustomerAddresses().catchError((_) => <CustomerAddressModel>[]),
        repo.getWalletBalance().catchError((_) => 0.0),
      ]);

      if (mounted) {
        final addresses = (results[2] as List<dynamic>).cast<CustomerAddressModel>();
        setState(() {
          _cart = results[0] as CartModel;
          _pricing = results[1] as CartPricingModel?;
          _addresses = addresses;
          _walletBalance = results[3] as double;
          if (addresses.isNotEmpty) _selectedAddress = addresses.first;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _payableAmount {
    final base = _pricing?.finalTotalInr ?? 0.0;
    var total = base - widget.discountAmount + widget.deliveryTip;
    if (_useWalletBalance) {
      total = (total - _walletBalance).clamp(0.0, 999999.0);
    }
    return total.clamp(0.0, 999999.0);
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
    if (_isPlacingOrder) return; // Prevent double-tap
    setState(() => _isPlacingOrder = true);

    final idempotencyKey = 'order_${DateTime.now().millisecondsSinceEpoch}';
    final effectiveMethod = (_payableAmount == 0.0 && _useWalletBalance) ? 'WALLET' : _selectedPaymentMethod;

    try {
      final res = await ref.read(apiClientProvider).placeOrder(
        addressId: _selectedAddress!.id,
        paymentMethod: effectiveMethod,
      );

      final subOrderId = (res['subOrderId'] ?? res['subOrders']?[0]?['id'] ?? res['id'])?.toString() ?? idempotencyKey;
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: subOrderId,
              storeName: _cart?.outletName,
              totalAmount: _payableAmount,
              eta: widget.deliverySlot == 'NOW' ? '25-35 mins' : widget.deliverySlot,
            ),
          ),
        );
      }
    } catch (e, st) {
      final err = FriendlyError.from(e, st);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentStatusScreen(
              type: PaymentFailureType.failed,
              orderId: idempotencyKey,
              amount: _payableAmount,
              errorMessage: err.message,
              onRetry: () {
                Navigator.pop(context);
                _handlePlaceOrder();
              },
              onChangeMethod: () => Navigator.pop(context),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Checkout?'),
        content: const Text('Your selected items will remain saved in your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Stay')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldLeave = await _showDiscardDialog();
        if (shouldLeave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    onSelectMethod: (m) => setState(() => _selectedPaymentMethod = m),
                    useWalletBalance: _useWalletBalance,
                    onToggleWallet: (v) => setState(() => _useWalletBalance = v),
                    walletBalance: _walletBalance,
                    selectedUpiApp: _selectedUpiApp,
                    onSelectUpiApp: (app) => setState(() => _selectedUpiApp = app),
                  ),
                  const SizedBox(height: 16),
                  if (_pricing != null) ...[
                    CheckoutBillSummary(
                      pricing: _pricing!,
                      storeCount: _cart?.outlets.length ?? 1,
                    ),
                    const SizedBox(height: 24),
                    AllGoButton(
                      label: _isPlacingOrder
                          ? 'Placing Order...'
                          : 'Pay ₹${_payableAmount.toStringAsFixed(0)} & Place Order',
                      isLoading: _isPlacingOrder,
                      onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
