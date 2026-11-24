import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../screens/phone_login_screen.dart';

class GuestLoginPromptSheet extends StatelessWidget {
  final String title;
  final String subtitle;

  const GuestLoginPromptSheet({
    super.key,
    this.title = 'Sign In to Proceed',
    this.subtitle = 'Please log in with your phone number to place orders, save delivery addresses, and track couriers in real time.',
  });

  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GuestLoginPromptSheet(
        title: title ?? 'Sign In to Proceed',
        subtitle: subtitle ??
            'Please log in with your phone number to place orders, save delivery addresses, and track couriers in real time.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AllGoColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AllGoColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AllGoTypography.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AllGoTypography.bodyMedium.copyWith(
              color: AllGoColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          AllGoButton(
            label: 'Continue with Phone Number',
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Continue Browsing',
              style: AllGoTypography.bodyMedium.copyWith(
                color: AllGoColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
