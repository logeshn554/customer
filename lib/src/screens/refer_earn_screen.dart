import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class ReferEarnScreen extends StatelessWidget {
  final String referralCode;

  const ReferEarnScreen({super.key, this.referralCode = 'ALLGO987'});

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code "$referralCode" copied to clipboard!'),
        backgroundColor: AllGoColors.success,
      ),
    );
  }

  void _shareInvite() {
    Share.share(
      'Join me on AllGo Super App! Use my referral code $referralCode to get ₹100 instant wallet cash on your first food, grocery, or ride booking: https://allgo.in/refer/$referralCode',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AllGoColors.primary,
                  AllGoColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.card_giftcard_rounded, size: 60, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Earn ₹100 Wallet Cash',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Invite friends to AllGo. You both get ₹100 credited when they complete their first order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        referralCode,
                        style: const TextStyle(
                          color: AllGoColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: AllGoColors.primary, size: 20),
                        tooltip: 'Copy Code',
                        onPressed: () => _copyCode(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AllGoButton(
            label: 'Share Invite with Friends',
            icon: Icons.share_rounded,
            onPressed: _shareInvite,
          ),
          const SizedBox(height: 28),
          Text('How It Works', style: AllGoTypography.heading2.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          _buildStep(
            number: '1',
            title: 'Invite Friends',
            description: 'Share your personal referral code via WhatsApp, SMS, or social apps.',
          ),
          _buildStep(
            number: '2',
            title: 'Friend Places Order',
            description: 'Your friend signs up and completes their first food delivery or ride.',
          ),
          _buildStep(
            number: '3',
            title: 'Both Earn ₹100',
            description: '₹100 is credited automatically to both of your AllGo Wallets with no expiry.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required String number, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AllGoColors.primary.withValues(alpha: 0.12),
            child: Text(
              number,
              style: const TextStyle(color: AllGoColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description, style: AllGoTypography.caption.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
