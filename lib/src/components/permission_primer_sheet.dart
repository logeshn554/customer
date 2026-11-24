import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'package:geolocator/geolocator.dart';

enum PrimerPermissionType { location, notifications }

class PermissionPrimerSheet extends StatelessWidget {
  final PrimerPermissionType permissionType;
  final VoidCallback onGranted;
  final VoidCallback? onManualFallback;

  const PermissionPrimerSheet({
    super.key,
    required this.permissionType,
    required this.onGranted,
    this.onManualFallback,
  });

  static Future<void> show({
    required BuildContext context,
    required PrimerPermissionType permissionType,
    required VoidCallback onGranted,
    VoidCallback? onManualFallback,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PermissionPrimerSheet(
        permissionType: permissionType,
        onGranted: onGranted,
        onManualFallback: onManualFallback,
      ),
    );
  }

  Future<void> _handlePermissionRequest(BuildContext context) async {
    if (permissionType == PrimerPermissionType.location) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission is disabled. Please enable it in Settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        if (context.mounted) Navigator.pop(context);
        onGranted();
      }
    } else {
      if (context.mounted) Navigator.pop(context);
      onGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocation = permissionType == PrimerPermissionType.location;
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AllGoColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocation ? Icons.location_on_rounded : Icons.notifications_active_rounded,
              color: AllGoColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isLocation ? 'Enable Location for Accurate Delivery' : 'Stay Updated on Your Orders',
            textAlign: TextAlign.center,
            style: AllGoTypography.heading2,
          ),
          const SizedBox(height: 12),
          Text(
            isLocation
                ? 'AllGo uses your location to show available restaurants, calculate accurate delivery times, and guide couriers directly to your door.'
                : 'Receive live driver tracking updates, order confirmation alerts, and exclusive daily coupon discounts.',
            textAlign: TextAlign.center,
            style: AllGoTypography.bodyMedium.copyWith(
              color: AllGoColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          AllGoButton(
            label: isLocation ? 'Allow Location Access' : 'Turn On Notifications',
            onPressed: () => _handlePermissionRequest(context),
          ),
          if (isLocation && onManualFallback != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onManualFallback?.call();
              },
              child: Text(
                'Enter Address Manually',
                style: AllGoTypography.bodyMedium.copyWith(
                  color: AllGoColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
