import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class PaymentsAndRefundsScreen extends ConsumerStatefulWidget {
  const PaymentsAndRefundsScreen({super.key});

  @override
  ConsumerState<PaymentsAndRefundsScreen> createState() => _PaymentsAndRefundsScreenState();
}

class _PaymentsAndRefundsScreenState extends ConsumerState<PaymentsAndRefundsScreen> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _payments = [];
  List<dynamic> _refunds = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pList = await _apiClient.getCustomerPayments();
      final rList = await _apiClient.getCustomerRefunds();
      if (mounted) {
        setState(() {
          _payments = pList;
          _refunds = rList;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: const Text('Payments & Refunds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AllGoColors.primary,
          unselectedLabelColor: AllGoColors.textSecondary,
          indicatorColor: AllGoColors.primary,
          tabs: const [
            Tab(text: 'Payments'),
            Tab(text: 'Refund Status'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPaymentsTab(),
                  _buildRefundsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) {
      return const Center(child: Text('No payment history found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (ctx, i) {
        final p = _payments[i];
        final amount = (p['amount_inr'] as num?)?.toDouble() ?? 0.0;
        final status = p['status']?.toString() ?? 'PENDING';
        final isSuccess = status == 'CAPTURED';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AllGoColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AllGoColors.divider, width: 0.8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isSuccess ? AllGoColors.success.withOpacity(0.12) : AllGoColors.warning.withOpacity(0.12),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.pending_outlined,
                  color: isSuccess ? AllGoColors.success : AllGoColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment via ${p['payment_method'] ?? "ONLINE"}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Order #${p['order_number'] ?? (p['order_group_id']?.toString().substring(0, 8) ?? "N/A")}',
                      style: const TextStyle(fontSize: 12, color: AllGoColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSuccess ? AllGoColors.success.withOpacity(0.1) : AllGoColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? AllGoColors.success : AllGoColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRefundsTab() {
    if (_refunds.isEmpty) {
      return const Center(child: Text('No refunds requested or processed.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _refunds.length,
      itemBuilder: (ctx, i) {
        final r = _refunds[i];
        final amount = (r['amount_inr'] as num?)?.toDouble() ?? 0.0;
        final status = r['status']?.toString() ?? 'PENDING';
        final isProcessed = status == 'PROCESSED';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AllGoColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AllGoColors.divider, width: 0.8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isProcessed ? AllGoColors.success.withOpacity(0.12) : AllGoColors.warning.withOpacity(0.12),
                child: Icon(
                  isProcessed ? Icons.currency_rupee : Icons.hourglass_top,
                  color: isProcessed ? AllGoColors.success : AllGoColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund to ${r['destination'] == "WALLET" ? "AllGo Wallet" : "Original Method"}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      r['reason']?.toString() ?? 'Customer refund',
                      style: const TextStyle(fontSize: 12, color: AllGoColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AllGoColors.success)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isProcessed ? AllGoColors.success.withOpacity(0.1) : AllGoColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isProcessed ? AllGoColors.success : AllGoColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
