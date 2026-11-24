import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'support_screen.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<String> categories = ['All', 'Orders', 'Payments', 'Delivery', 'Account'];

  static const List<_FaqItem> allFaqs = [
    _FaqItem(
      category: 'Orders',
      question: 'How do I cancel my order?',
      answer: 'You can cancel your order directly from the Order Details screen before the restaurant confirms preparation. Once food preparation begins, cancellations may be subject to merchant cancellation fees.',
    ),
    _FaqItem(
      category: 'Orders',
      question: 'Can I modify items after placing an order?',
      answer: 'Currently, items cannot be edited after placement. You can reach out to support or the merchant via the Order Details screen to request modifications.',
    ),
    _FaqItem(
      category: 'Payments',
      question: 'When will I receive my refund?',
      answer: 'Approved refunds are credited to your AllGo Wallet instantly. Bank account, credit card, and UPI refunds take 3 to 5 business days to reflect in your statement depending on your bank.',
    ),
    _FaqItem(
      category: 'Payments',
      question: 'How does Wallet balance payment work?',
      answer: 'At checkout, simply toggle "Use AllGo Wallet balance". If your balance is less than the order total, you can pay the remainder via UPI, card, or cash on delivery.',
    ),
    _FaqItem(
      category: 'Delivery',
      question: 'How do I track my delivery partner in real time?',
      answer: 'Tap "Live Tracking" from the home screen or active order. You will see live courier GPS telemetry, estimated arrival time, and direct call/chat buttons.',
    ),
    _FaqItem(
      category: 'Delivery',
      question: 'What is the 4-digit Delivery PIN?',
      answer: 'The Delivery PIN ensures your order is delivered only to you. Share this 4-digit code with your courier partner upon arrival to complete handover.',
    ),
    _FaqItem(
      category: 'Account',
      question: 'How do I update my registered phone number?',
      answer: 'Under Account > Edit Profile, you can update your profile details. For security and anti-fraud purposes, mobile number updates require two-step OTP verification.',
    ),
    _FaqItem(
      category: 'Account',
      question: 'How do I request account and data deletion?',
      answer: 'Under Account > Privacy & Security, tap "Delete Account". Under DPDP Act rules, your request is subject to a 30-day grace period during which you can cancel deletion.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredFaqs = allFaqs.where((faq) {
      final matchesCategory = _selectedCategory == 'All' || faq.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Help Centre & FAQ')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search help questions...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: AllGoColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AllGoColors.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // FAQ List
          Expanded(
            child: filteredFaqs.isEmpty
                ? const Center(child: Text('No matching questions found'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredFaqs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredFaqs[index];
                      return ExpansionTile(
                        title: Text(
                          item.question,
                          style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              item.answer,
                              style: AllGoTypography.bodyMedium.copyWith(
                                color: AllGoColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          // Still need help bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Still need help?', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text('Chat with our 24x7 customer support team', style: AllGoTypography.caption),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.support_agent, size: 18),
                  label: const Text('Support'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  const _FaqItem({required this.category, required this.question, required this.answer});
}
