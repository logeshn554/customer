import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'welcome_screen.dart';
import 'wallet_screen.dart';
import 'payments_and_refunds_screen.dart';
import 'support_screen.dart';
import 'notifications_screen.dart';
import 'edit_profile_screen.dart';
import 'privacy_security_screen.dart';
import 'saved_addresses_screen.dart';
import 'favorite_and_recent_stores_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of AllGo?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  String _getLanguageSubtitle(String? lang) {
    switch (lang) {
      case 'ta': return 'தமிழ் (Tamil)';
      case 'hi': return 'हिन्दी (Hindi)';
      default: return 'English';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: const AllGoAppBar(title: 'My Account', showBackButton: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // User Header Card - Interactive Edit Profile Trigger
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AllGoColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AllGoColors.divider),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AllGoColors.primaryLight.withOpacity(0.3),
                      child: Text(
                        (user?.fullName != null && user!.fullName!.isNotEmpty)
                            ? user.fullName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AllGoColors.primaryDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.fullName ?? 'AllGo Customer', style: AllGoTypography.heading3),
                          const SizedBox(height: 4),
                          Text(user?.phone ?? '+91 --', style: AllGoTypography.bodyMedium.copyWith(color: AllGoColors.textSecondary)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AllGoColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Status: ${user?.status.toApiString() ?? "ACTIVE"}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AllGoColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, color: AllGoColors.primary, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Wallet & Payments
            _buildSectionHeader('Finances & Addresses'),
            _buildOptionTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Delivery Addresses',
              subtitle: 'Manage home, work & customized GPS coordinates',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedAddressesScreen()),
              ),
            ),
            _buildOptionTile(
              icon: Icons.favorite_border,
              title: 'Favorites & Recently Viewed Stores',
              subtitle: 'Quick access to your preferred food & grocery outlets',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoriteAndRecentStoresScreen()),
              ),
            ),
            _buildOptionTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'AllGo Wallet',
              subtitle: 'Check balance, refunds, and promotional credits',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              ),
            ),
            _buildOptionTile(
              icon: Icons.receipt_long_outlined,
              title: 'Payments & Refunds',
              subtitle: 'Transaction history, payment modes, and refund tracking',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaymentsAndRefundsScreen()),
              ),
            ),
            const SizedBox(height: 16),

            // Settings Options
            _buildSectionHeader('Preferences'),
            _buildOptionTile(
              icon: Icons.language,
              title: 'App Language',
              subtitle: _getLanguageSubtitle(user?.defaultLanguage),
              onTap: () => LanguageSelectionSheet.show(context),
            ),
            _buildOptionTile(
              icon: Icons.notifications_none,
              title: 'Notifications & Alerts',
              subtitle: 'Order and promotional SMS/Push notifications',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('Account & Security'),
            _buildOptionTile(
              icon: Icons.shield_outlined,
              title: 'Privacy & Security',
              subtitle: 'Device sessions, biometrics & account controls',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
              ),
            ),
            _buildOptionTile(
              icon: Icons.help_outline,
              title: 'Help & Customer Support',
              subtitle: '24x7 customer support tickets & dispute resolution',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            AllGoButton(
              label: 'Log Out',
              variant: AllGoButtonVariant.outlined,
              icon: Icons.logout,
              onPressed: () => _handleLogout(context, ref),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'AllGo Super App v0.1.0 (Phase 1 Local)',
                style: AllGoTypography.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllGoColors.divider, width: 0.6),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: AllGoColors.textPrimary, size: 24),
          title: Text(title, style: AllGoTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: AllGoTypography.caption),
          trailing: const Icon(Icons.chevron_right, size: 20, color: AllGoColors.textTertiary),
          onTap: onTap,
        ),
      ),
    );
  }
}

