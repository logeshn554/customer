import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  double _balance = 0.00;
  double _promoBalance = 0.00;
  double _refundableBalance = 0.00;
  List<dynamic> _transactions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final walletData = await _apiClient.getCustomerWallet();
      final txData = await _apiClient.getCustomerWalletTransactions();
      if (mounted) {
        setState(() {
          _balance = (walletData['balanceInr'] as num?)?.toDouble() ?? 0.0;
          _promoBalance = (walletData['promotionalBalanceInr'] as num?)?.toDouble() ?? 0.0;
          _refundableBalance = (walletData['refundableBalanceInr'] as num?)?.toDouble() ?? 0.0;
          _transactions = txData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showTopupDialog() async {
    final amountController = TextEditingController(text: '500');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Top Up AllGo Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter amount to add via UPI / Card:'),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
                hintText: '500',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Proceed to Pay'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final amt = double.tryParse(amountController.text) ?? 0.0;
      if (amt > 0) {
        try {
          await _apiClient.topupCustomerWallet(amt);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully credited ₹$amt to wallet!')),
            );
            _loadWallet();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Top up failed: $e'), backgroundColor: AllGoColors.error),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: const AllGoAppBar(title: 'AllGo Wallet', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWallet,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Wallet Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AllGoColors.primaryDark, AllGoColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AllGoColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL AVAILABLE BALANCE',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Refundable', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  Text('₹${_refundableBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Promotional', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  Text('₹${_promoBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showTopupDialog,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Money'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AllGoColors.primaryDark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction History Header
                  const Text(
                    'TRANSACTION HISTORY',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AllGoColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  if (_transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AllGoColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AllGoColors.divider),
                      ),
                      child: const Text('No transactions yet in this wallet.', style: TextStyle(color: AllGoColors.textTertiary)),
                    )
                  else
                    ..._transactions.map((tx) {
                      final isCredit = tx['direction'] == 'CREDIT';
                      final amount = (tx['amount_inr'] as num?)?.toDouble() ?? 0.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AllGoColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AllGoColors.divider, width: 0.6),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isCredit ? AllGoColors.success.withOpacity(0.12) : AllGoColors.error.withOpacity(0.12),
                              child: Icon(
                                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                size: 18,
                                color: isCredit ? AllGoColors.success : AllGoColors.error,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx['description']?.toString() ?? 'Wallet Transaction',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tx['created_at'] != null ? tx['created_at'].toString().split('T').first : '',
                                    style: const TextStyle(fontSize: 11, color: AllGoColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isCredit ? "+" : "-"}₹${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCredit ? AllGoColors.success : AllGoColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
