import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../widgets/app_network_image.dart';
import '../widgets/veg_badge.dart';

class CustomerProductCard extends StatelessWidget {
  final ProductItem product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback? onDecrement;

  const CustomerProductCard({
    super.key,
    required this.product,
    this.quantity = 0,
    required this.onAdd,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.salePriceInr != null && product.basePriceInr > product.effectivePriceInr;
    final discountPercent = hasDiscount
        ? (((product.basePriceInr - product.effectivePriceInr) / product.basePriceInr) * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VegNonVegBadge(isVeg: product.isVeg),
                      const SizedBox(width: 6),
                      if (product.optionGroups.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CUSTOMISABLE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${product.effectivePriceInr.toStringAsFixed(0)}',
                        style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${product.basePriceInr.toStringAsFixed(0)}',
                          style: AllGoTypography.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AllGoColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$discountPercent% OFF',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('4.2', style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('(40+)', style: AllGoTypography.caption.copyWith(color: AllGoColors.textTertiary)),
                    ],
                  ),
                  if (product.description != null && product.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      product.description!,
                      style: AllGoTypography.caption.copyWith(color: AllGoColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right image & add stepper
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    AppNetworkImage(
                      imageUrl: product.imageUrl ?? (product.images.isNotEmpty ? product.images.first : null),
                      width: 96,
                      height: 96,
                      borderRadius: BorderRadius.circular(12),
                      fallbackIcon: Icons.fastfood_outlined,
                      semanticsLabel: product.name,
                    ),
                    if (!product.isInStock)
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'OUT OF\nSTOCK',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActionButtons(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!product.isInStock) {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'UNAVAILABLE',
          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (quantity > 0) {
      return Container(
        height: 36,
        decoration: BoxDecoration(
          color: AllGoColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 16, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
              tooltip: 'Decrease quantity',
              onPressed: onDecrement,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '$quantity',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
              tooltip: 'Increase quantity',
              onPressed: onAdd,
            ),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: onAdd,
      style: OutlinedButton.styleFrom(
        foregroundColor: AllGoColors.primary,
        side: const BorderSide(color: AllGoColors.primary, width: 1.5),
        minimumSize: const Size(80, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
