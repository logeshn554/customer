import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About AllGo'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AllGoColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AllGo Super App',
            textAlign: TextAlign.center,
            style: AllGoTypography.heading2,
          ),
          const SizedBox(height: 4),
          Text(
            'Version 2.4.0 (Build 2026)',
            textAlign: TextAlign.center,
            style: AllGoTypography.caption,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.symmetric(horizontal: 80),
            decoration: BoxDecoration(
              color: AllGoColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_rounded, size: 14, color: AllGoColors.primary),
                SizedBox(width: 6),
                Text(
                  'Made with pride in India',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AllGoColors.primary),
                ),
              ],
            ),
          ),
          const Divider(height: 40),
          _buildInfoRow('Company', 'AllGo Technologies Pvt Ltd'),
          _buildInfoRow('Headquarters', 'Bengaluru, Karnataka, India'),
          _buildInfoRow('Support Email', 'support@allgo.in'),
          _buildInfoRow('Grievance Officer', 'grievance@allgo.in'),
          _buildInfoRow('Services Covered', 'Food, Groceries, Couriers, Rides, Drivers'),
          const Divider(height: 32),
          Text(
            'Open Source Licenses',
            style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'This software utilizes Flutter, Dart, Riverpod, Google Maps, and other open source packages under BSD and MIT licenses.',
            style: AllGoTypography.caption,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'AllGo Super App',
              applicationVersion: '2.4.0',
            ),
            child: const Text('View All Third-Party Licenses'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AllGoTypography.bodyMedium.copyWith(color: AllGoColors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
