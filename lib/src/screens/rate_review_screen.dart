import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class RateReviewScreen extends StatefulWidget {
  final String orderId;
  final String outletName;
  final String? partnerName;

  const RateReviewScreen({
    super.key,
    required this.orderId,
    required this.outletName,
    this.partnerName,
  });

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  int _foodRating = 5;
  int _deliveryRating = 5;
  final Set<String> _selectedTags = {};
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  static const List<String> availableTags = [
    'Super Fast Delivery',
    'Food was Hot & Fresh',
    'Great Packaging',
    'Polite Partner',
    'Accurate Items',
    'Value for Money',
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Widget _buildStarRow(int rating, ValueChanged<int> onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          icon: Icon(
            star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: 36,
          ),
          onPressed: () => onRatingChanged(star),
        );
      }),
    );
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulating submission
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your feedback has been recorded.'),
        backgroundColor: AllGoColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Rate & Review')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'How was your experience?',
            style: AllGoTypography.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Order #${widget.orderId.substring(0, widget.orderId.length > 8 ? 8 : widget.orderId.length).toUpperCase()}',
            style: AllGoTypography.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Outlet & Food Rating
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text('Food & Restaurant Quality', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(widget.outletName, style: AllGoTypography.caption),
                const SizedBox(height: 8),
                _buildStarRow(_foodRating, (r) => setState(() => _foodRating = r)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Partner Rating
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text('Delivery Partner Service', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(widget.partnerName ?? 'AllGo Delivery Partner', style: AllGoTypography.caption),
                const SizedBox(height: 8),
                _buildStarRow(_deliveryRating, (r) => setState(() => _deliveryRating = r)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Feedback Tags
          Text('What did you like the most?', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: AllGoColors.primaryLight.withValues(alpha: 0.2),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Comment Box
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write detailed comments or suggestions for improvement...',
              prefixIcon: Icon(Icons.rate_review_outlined, size: 22),
            ),
          ),
          const SizedBox(height: 28),

          AllGoButton(
            label: 'Submit Feedback',
            isLoading: _isSubmitting,
            onPressed: _submitFeedback,
          ),
        ],
      ),
    );
  }
}
