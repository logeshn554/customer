import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class CustomerSupportScreen extends ConsumerStatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  ConsumerState<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends ConsumerState<CustomerSupportScreen> {
  bool _isLoading = true;
  List<dynamic> _tickets = [];
  Map<String, dynamic>? _activeTicket;
  List<dynamic> _threadMessages = [];
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.getUserSupportTickets(role: 'CUSTOMER');
      if (mounted) {
        setState(() {
          _tickets = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openTicketDetail(String ticketId) async {
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.getSupportTicketDetails(ticketId);
      if (mounted) {
        setState(() {
          _activeTicket = res['ticket'] as Map<String, dynamic>?;
          _threadMessages = (res['messages'] as List<dynamic>?) ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreateTicketDialog() async {
    String category = 'ORDER_ISSUE';
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('New Support Ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: category,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'ORDER_ISSUE', child: Text('Order / Delivery Issue')),
                    DropdownMenuItem(value: 'PAYMENT_FAILED', child: Text('Payment or Refund Query')),
                    DropdownMenuItem(value: 'RIDE_DISPUTE', child: Text('Ride / Driver Dispute')),
                    DropdownMenuItem(value: 'PARCEL_QUERY', child: Text('Parcel Delivery Inquiry')),
                    DropdownMenuItem(value: 'APP_FEEDBACK', child: Text('General Feedback')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => category = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Subject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                TextField(controller: subjectCtrl, decoration: const InputDecoration(hintText: 'Brief summary')),
                const SizedBox(height: 12),
                const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Describe what happened in detail')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.primary),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Submit Ticket'),
            ),
          ],
        ),
      ),
    );

    if (created == true && mounted) {
      try {
        final client = ref.read(apiClientProvider);
        await client.createSupportTicket({
          'category': category,
          'subject': subjectCtrl.text.trim(),
          'description': descCtrl.text.trim(),
        }, role: 'CUSTOMER');
        _loadTickets();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _activeTicket == null) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.addSupportTicketMessage(_activeTicket!['id'].toString(), text);
      _replyController.clear();
      _openTicketDetail(_activeTicket!['id'].toString());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reply failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeTicket != null) {
      return Scaffold(
        backgroundColor: AllGoColors.background,
        appBar: AllGoAppBar(
          title: _activeTicket!['subject']?.toString() ?? 'Support Conversation',
          showBackButton: true,
          onBack: () => setState(() => _activeTicket = null),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _threadMessages.length,
                itemBuilder: (ctx, idx) {
                  final msg = _threadMessages[idx];
                  final isCustomer = msg['sender_role'] == 'CUSTOMER';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCustomer ? AllGoColors.primary : AllGoColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: isCustomer ? null : Border.all(color: AllGoColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCustomer ? 'You' : 'AllGo Support Agent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCustomer ? Colors.white70 : AllGoColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['message']?.toString() ?? '',
                            style: TextStyle(
                              color: isCustomer ? Colors.white : AllGoColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: AllGoColors.surface,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        decoration: const InputDecoration(
                          hintText: 'Type your reply...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AllGoColors.primary),
                      onPressed: _sendReply,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: const AllGoAppBar(title: 'Customer Support', showBackButton: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTicketDialog,
        backgroundColor: AllGoColors.primary,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text('New Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTickets,
              child: _tickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headset_mic_outlined, size: 56, color: AllGoColors.textTertiary),
                          const SizedBox(height: 12),
                          const Text('No support tickets opened.', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Need help? Tap the button below to submit a ticket.', style: TextStyle(color: AllGoColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tickets.length,
                      itemBuilder: (ctx, idx) {
                        final t = _tickets[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () => _openTicketDetail(t['id'].toString()),
                            title: Text(t['subject']?.toString() ?? 'Ticket', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Status: ${t['status']} • Category: ${t['category']}', style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
