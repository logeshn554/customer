import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../screens/map_coordinate_picker_modal.dart';

class DeliveryAddressSelectionSheet extends StatelessWidget {
  final List<CustomerAddressModel> savedAddresses;
  final double currentLatitude;
  final double currentLongitude;
  final void Function(double lat, double lng, String label) onLocationSelected;
  final VoidCallback onUseGps;

  const DeliveryAddressSelectionSheet({
    super.key,
    required this.savedAddresses,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.onLocationSelected,
    required this.onUseGps,
  });

  static Future<void> show({
    required BuildContext context,
    required List<CustomerAddressModel> savedAddresses,
    required double currentLatitude,
    required double currentLongitude,
    required void Function(double lat, double lng, String label) onLocationSelected,
    required VoidCallback onUseGps,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryAddressSelectionSheet(
        savedAddresses: savedAddresses,
        currentLatitude: currentLatitude,
        currentLongitude: currentLongitude,
        onLocationSelected: onLocationSelected,
        onUseGps: onUseGps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Delivery Location', style: AllGoTypography.heading3),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close location selector',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.my_location, color: AllGoColors.primary),
            title: const Text('Use Current GPS Location', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              onUseGps();
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: AllGoColors.primary),
            title: const Text('Pin On Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () async {
              Navigator.pop(context);
              final result = await showModalBottomSheet<MapLocationResult>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => MapCoordinatePickerModal(
                  initialLat: currentLatitude,
                  initialLng: currentLongitude,
                ),
              );
              if (result != null) {
                onLocationSelected(result.latitude, result.longitude, result.addressText);
              }
            },
          ),
          if (savedAddresses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Saved Addresses', style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...savedAddresses.map((addr) => ListTile(
              leading: Icon(
                addr.label.toUpperCase() == 'HOME' ? Icons.home : Icons.work,
                color: AllGoColors.primary,
              ),
              title: Text('${addr.label}: ${addr.addressLine1}'),
              subtitle: Text('${addr.city}, ${addr.postalCode}'),
              onTap: () {
                Navigator.pop(context);
                onLocationSelected(addr.latitude, addr.longitude, '${addr.label}: ${addr.addressLine1}, ${addr.city}');
              },
            )),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
