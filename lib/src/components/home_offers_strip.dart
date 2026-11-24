import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class HomeOffersStrip extends StatelessWidget {
  final VoidCallback? onTap;

  const HomeOffersStrip({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AllGoColors.primaryLight.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AllGoColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.percent, color: AllGoColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '50% OFF up to ₹100 • Use ALLGO50',
                    style: AllGoTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AllGoColors.primaryDark,
                    ),
                  ),
                  Text(
                    'Free delivery on all orders above ₹199',
                    style: AllGoTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AllGoColors.primary),
          ],
        ),
      ),
    );
  }
}
