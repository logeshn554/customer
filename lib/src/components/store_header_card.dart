import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../widgets/app_network_image.dart';

class StoreHeaderCard extends StatelessWidget {
  final String outletName;
  final String? categoryName;
  final OutletOpenStatusModel? outletStatus;
  final bool isFavorite;
  final bool isTogglingFav;
  final VoidCallback onToggleFav;

  const StoreHeaderCard({
    super.key,
    required this.outletName,
    this.categoryName,
    required this.outletStatus,
    required this.isFavorite,
    required this.isTogglingFav,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = outletStatus?.isOpen ?? true;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
                height: 130,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                fallbackIcon: Icons.restaurant,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    onPressed: isTogglingFav ? null : onToggleFav,
                  ),
                ),
              ),
              if (!isOpen)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'TEMPORARILY CLOSED',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outletName, style: AllGoTypography.heading2.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('4.5', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(width: 2),
                          Icon(Icons.star, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• 25-30 mins • 2.4 km • ${categoryName ?? "Food & Groceries"}',
                      style: AllGoTypography.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
