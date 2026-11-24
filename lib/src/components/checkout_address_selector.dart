import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class CheckoutAddressSelector extends StatelessWidget {
  final List<CustomerAddressModel> addresses;
  final CustomerAddressModel? selectedAddress;
  final bool isLoading;
  final ValueChanged<CustomerAddressModel> onSelect;
  final VoidCallback onAddNew;

  const CheckoutAddressSelector({
    super.key,
    required this.addresses,
    required this.selectedAddress,
    required this.isLoading,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllGoColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AllGoColors.primary),
                  const SizedBox(width: 8),
                  Text('Delivery Address', style: AllGoTypography.heading3.copyWith(fontSize: 15)),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add New'),
                onPressed: onAddNew,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else if (addresses.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('No saved address found. Please add a delivery address.')),
                ],
              ),
            )
          else
            ...addresses.map((addr) {
              final isSelected = selectedAddress?.id == addr.id;
              return InkWell(
                onTap: () => onSelect(addr),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AllGoColors.primary.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AllGoColors.primary : AllGoColors.divider, width: isSelected ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AllGoColors.primary : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AllGoColors.primary)),
                            const SizedBox(height: 2),
                            Text('${addr.addressLine1}, ${addr.city} ${addr.postalCode}', style: AllGoTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
