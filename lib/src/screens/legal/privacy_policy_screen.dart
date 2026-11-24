import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'AllGo Privacy & Data Protection',
            style: AllGoTypography.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Compliant with Digital Personal Data Protection (DPDP) Act',
            style: AllGoTypography.caption,
          ),
          const Divider(height: 32),
          _buildSection(
            title: '1. Information We Collect',
            body:
                'We collect your verified phone number, delivery addresses, order history, device hardware identifiers for anti-fraud validation, and precise background/foreground geolocation during active delivery tracking.',
          ),
          _buildSection(
            title: '2. Purpose of Processing',
            body:
                'Data is processed strictly to fulfill ordered deliveries, navigate couriers to your chosen address, process electronic payments through RBI-authorized aggregators, and prevent multi-account coupon abuse.',
          ),
          _buildSection(
            title: '3. Data Retention and Telemetry',
            body:
                'Live GPS telemetry is retained only for the duration of the trip or delivery plus safety audit buffers. Financial transaction ledgers are preserved in accordance with financial regulatory statutory periods.',
          ),
          _buildSection(
            title: '4. Your DPDP Act Rights (Section 12)',
            body:
                'You possess the right to access, rectify, or request permanent erasure of your personal data. You may initiate an account deletion request directly from Account Settings with an immediate 30-day revocation grace period.',
          ),
          _buildSection(
            title: '5. Data Protection Officer',
            body:
                'For grievance redressal or privacy queries, contact our Data Protection Officer at privacy@allgo.in or through the Help & Support center in this application.',
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
