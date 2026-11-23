import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class UnifiedActiveBookingItem {
  final String id;
  final String verticalType; // 'FOOD', 'GROCERY', 'RIDE', 'PARCEL', 'HIRE_DRIVER', 'HOMEMADE'
  final String title;
  final String subtitle;
  final String status;
  final String? eta;
  final String? verificationPin;
  final VoidCallback onTrack;
  final VoidCallback? onSupport;

  const UnifiedActiveBookingItem({
    required this.id,
    required this.verticalType,
    required this.title,
    required this.subtitle,
    required this.status,
    this.eta,
    this.verificationPin,
    required this.onTrack,
    this.onSupport,
  });
}

class UnifiedActiveBookingsTray extends StatelessWidget {
  final List<UnifiedActiveBookingItem> bookings;
  final VoidCallback? onRefresh;

  const UnifiedActiveBookingsTray({
    super.key,
    required this.bookings,
    this.onRefresh,
  });

  Color _getBadgeColor(String vertical) {
    switch (vertical.toUpperCase()) {
      case 'FOOD':
        return Colors.orange;
      case 'GROCERY':
        return Colors.green;
      case 'RIDE':
        return Colors.teal;
      case 'PARCEL':
        return Colors.deepPurple;
      case 'HIRE_DRIVER':
        return Colors.indigo;
      case 'HOMEMADE':
        return Colors.pink;
      default:
        return AllGoColors.primary;
    }
  }

  IconData _getServiceIcon(String vertical) {
    switch (vertical.toUpperCase()) {
      case 'FOOD':
        return Icons.restaurant;
      case 'GROCERY':
        return Icons.shopping_basket;
      case 'RIDE':
        return Icons.directions_car;
      case 'PARCEL':
        return Icons.local_shipping;
      case 'HIRE_DRIVER':
        return Icons.airline_seat_recline_normal;
      case 'HOMEMADE':
        return Icons.cookie;
      default:
        return Icons.local_shipping;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, color: AllGoColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Active Bookings & Orders (${bookings.length})',
                  style: AllGoTypography.heading3.copyWith(fontSize: 16),
                ),
              ],
            ),
            if (onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: onRefresh,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final b = bookings[i];
              final color = _getBadgeColor(b.verticalType);
              return Container(
                width: 290,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Service Header with Badge & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getServiceIcon(b.verticalType), size: 14, color: color),
                              const SizedBox(width: 4),
                              Text(
                                b.verticalType.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            b.status.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Title & Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.subtitle,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (b.verificationPin != null && b.verificationPin!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Text('PIN/OTP: ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                Text(
                                  b.verificationPin!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: AllGoColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (b.eta != null)
                          Text(
                            'ETA: ${b.eta}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AllGoColors.primary),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          children: [
                            if (b.onSupport != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: b.onSupport,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Help', style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                              ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: const Size(0, 32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.navigation, size: 12),
                              label: const Text('Track Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: b.onTrack,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
