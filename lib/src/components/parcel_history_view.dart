import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class ParcelHistoryView extends StatelessWidget {
  final List<ParcelModel> parcels;
  final bool isLoading;
  final VoidCallback onRefresh;
  final void Function(ParcelModel parcel) onSelect;

  const ParcelHistoryView({
    super.key,
    required this.parcels,
    required this.isLoading,
    required this.onRefresh,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (parcels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping_outlined, size: 48, color: AllGoColors.textTertiary),
            const SizedBox(height: 12),
            Text('No past parcel bookings found', style: AllGoTypography.subtitle),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parcels.length,
        itemBuilder: (context, index) {
          final p = parcels[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.deepPurple),
              title: Text('Pkg #${p.id.substring(0, 8)}', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('${p.status} • ₹${p.totalFareInr.toStringAsFixed(0)}', style: AllGoTypography.caption),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelect(p),
            ),
          );
        },
      ),
    );
  }
}
