import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class MaintenanceScreen extends StatelessWidget {
  final VoidCallback? onRefresh;

  const MaintenanceScreen({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AllGoColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.build_circle_outlined, size: 54, color: AllGoColors.warning),
              ),
              const SizedBox(height: 28),
              Text(
                'Scheduled Maintenance',
                textAlign: TextAlign.center,
                style: AllGoTypography.heading1.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'We are performing scheduled infrastructure upgrades to enhance ordering speed and real-time courier tracking. We expect to be back online shortly.',
                textAlign: TextAlign.center,
                style: AllGoTypography.bodyMedium.copyWith(color: AllGoColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Estimated uptime: Today at 04:00 AM IST',
                  style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 36),
              AllGoButton(
                label: 'Check Server Status',
                icon: Icons.refresh,
                onPressed: onRefresh ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForceUpdateScreen extends StatelessWidget {
  final String currentVersion;
  final String requiredVersion;

  const ForceUpdateScreen({
    super.key,
    this.currentVersion = '2.3.0',
    this.requiredVersion = '2.4.0',
  });

  Future<void> _openStore() async {
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.allgo.customer');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AllGoColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update_rounded, size: 54, color: AllGoColors.primary),
              ),
              const SizedBox(height: 28),
              Text(
                'Update Required',
                textAlign: TextAlign.center,
                style: AllGoTypography.heading1.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'A new version of AllGo Super App ($requiredVersion) is available with critical security enhancements, multi-merchant checkout, and live GPS route polyline improvements.',
                textAlign: TextAlign.center,
                style: AllGoTypography.bodyMedium.copyWith(color: AllGoColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 36),
              AllGoButton(
                label: 'Update Now on Play Store',
                icon: Icons.download_rounded,
                onPressed: _openStore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AllGoColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded, size: 54, color: AllGoColors.error),
              ),
              const SizedBox(height: 28),
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: AllGoTypography.heading1.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your Wi-Fi network or cellular mobile data connection and try again to view restaurants and active deliveries.',
                textAlign: TextAlign.center,
                style: AllGoTypography.bodyMedium.copyWith(color: AllGoColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 36),
              AllGoButton(
                label: 'Retry Connection',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
