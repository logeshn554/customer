import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class DeliveryTipSelector extends StatelessWidget {
  final double selectedTip;
  final ValueChanged<double> onTipSelected;

  const DeliveryTipSelector({
    super.key,
    required this.selectedTip,
    required this.onTipSelected,
  });

  static const List<double> tipOptions = [0.0, 10.0, 20.0, 30.0, 50.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_outlined, size: 20, color: Colors.pink),
              const SizedBox(width: 8),
              Text(
                'Tip Your Delivery Partner',
                style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '100% of your tip goes directly to your delivery hero.',
            style: AllGoTypography.caption.copyWith(color: AllGoColors.textTertiary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: tipOptions.map((tip) {
              final isSelected = selectedTip == tip;
              final label = tip == 0.0 ? 'None' : '₹${tip.toStringAsFixed(0)}';
              return ChoiceChip(
                label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                selectedColor: AllGoColors.primaryLight.withValues(alpha: 0.2),
                onSelected: (_) => onTipSelected(tip),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
