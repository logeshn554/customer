import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class CustomerExploreTab extends StatelessWidget {
  final TextEditingController searchController;
  final List<DiscoveryOutlet> outlets;
  final List<DiscoveryCategory> categories;
  final bool isLoading;
  final ValueChanged<String> onSearch;
  final void Function(DiscoveryOutlet outlet) onOutletSelected;

  const CustomerExploreTab({
    super.key,
    required this.searchController,
    required this.outlets,
    required this.categories,
    required this.isLoading,
    required this.onSearch,
    required this.onOutletSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AllGoColors.surface,
          child: AllGoTextField(
            label: 'Search restaurants, groceries, dishes',
            hint: 'Biryani, Pizza, Milk, Fruits...',
            controller: searchController,
            prefixIcon: const Icon(Icons.search),
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : outlets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: AllGoColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('No outlets found nearby', style: AllGoTypography.subtitle),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: outlets.length,
                      itemBuilder: (context, index) {
                        final outlet = outlets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AllGoColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.storefront, color: AllGoColors.primary),
                            ),
                            title: Text(outlet.outletName, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text('${outlet.rating.toStringAsFixed(1)} ★ • ${outlet.estimatedDeliveryMins} mins • ${outlet.distanceKm.toStringAsFixed(1)} km', style: AllGoTypography.caption),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => onOutletSelected(outlet),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
