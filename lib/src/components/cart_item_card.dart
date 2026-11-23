import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AllGoColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('₹${item.unitPriceInr.toStringAsFixed(0)} each', style: AllGoTypography.caption),
                if (item.options.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.options.map((o) => o.name).join(', '), style: AllGoTypography.caption.copyWith(color: AllGoColors.textTertiary)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AllGoColors.primary, size: 20),
                onPressed: () {
                  if (item.quantity > 1) {
                    onQuantityChanged(item.quantity - 1);
                  } else {
                    onRemove();
                  }
                },
              ),
              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AllGoColors.primary, size: 20),
                onPressed: () => onQuantityChanged(item.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
