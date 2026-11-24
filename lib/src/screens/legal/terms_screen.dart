import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'AllGo Customer Terms of Use',
            style: AllGoTypography.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: November 2026',
            style: AllGoTypography.caption,
          ),
          const Divider(height: 32),
          _buildSection(
            title: '1. Platform Marketplace Role',
            body:
                'AllGo operates an online aggregation platform connecting independent customers with third-party merchant outlets, delivery contractors, and transport providers. AllGo does not manufacture food products or own courier fleet vehicles directly.',
          ),
          _buildSection(
            title: '2. User Accounts and Verification',
            body:
                'You must provide a valid Indian mobile number (+91) and accurately verify your account using OTP authentication. You are responsible for safeguarding your device and session tokens against unauthorized use.',
          ),
          _buildSection(
            title: '3. Pricing, Payments & Invoicing',
            body:
                'All item prices are determined by respective merchant outlets. Payment options include In-App Wallet balance, UPI gateways, Debit/Credit cards, and Cash on Delivery (where supported). Applicable taxes and platform delivery charges are calculated transparently at checkout.',
          ),
          _buildSection(
            title: '4. Cancellations and Refunds',
            body:
                'Orders may be cancelled before merchant confirmation without fee. Once food preparation or partner dispatch commences, cancellation may incur compensation charges. Approved refunds are credited back to the original payment source or wallet within statutory timeframes.',
          ),
          _buildSection(
            title: '5. Limitation of Liability',
            body:
                'To the maximum extent permitted under applicable law, AllGo shall not be liable for incidental, indirect, or consequential damages resulting from third-party merchant service quality, vehicle delays due to traffic, or force majeure events.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AllGoTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: AllGoTypography.bodyMedium.copyWith(
              height: 1.5,
              color: AllGoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
