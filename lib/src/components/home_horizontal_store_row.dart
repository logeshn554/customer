import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../widgets/app_network_image.dart';

class HomeHorizontalStoreRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<DiscoveryOutlet> outlets;
  final void Function(DiscoveryOutlet outlet) onOutletTap;
  final VoidCallback? onViewAll;

  const HomeHorizontalStoreRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.outlets,
    required this.onOutletTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (outlets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AllGoTypography.heading3),
                if (subtitle != null)
                  Text(subtitle!, style: AllGoTypography.caption),
              ],
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All', style: TextStyle(color: AllGoColors.primary, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: outlets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final outlet = outlets[index];
              return InkWell(
                onTap: () => onOutletTap(outlet),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AppNetworkImage(
                            imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300',
                            width: 150,
                            height: 100,
                            borderRadius: BorderRadius.circular(14),
                            fallbackIcon: Icons.storefront,
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    outlet.rating.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${outlet.estimatedDeliveryMins}m',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        outlet.outletName,
                        style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${outlet.verticalType} • ${outlet.distanceKm.toStringAsFixed(1)} km',
                        style: AllGoTypography.caption.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
