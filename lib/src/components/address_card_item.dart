import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class AddressCardItem extends StatelessWidget {
  final CustomerAddressModel address;
  final bool selectMode;
  final ValueChanged<CustomerAddressModel>? onSelect;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const AddressCardItem({
    super.key,
    required this.address,
    required this.selectMode,
    this.onSelect,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final addr = address;
    return Container(
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: addr.isDefault ? AllGoColors.primary : AllGoColors.divider,
          width: addr.isDefault ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: selectMode && onSelect != null ? () => onSelect!(addr) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        addr.label.toUpperCase() == 'HOME'
                            ? Icons.home_outlined
                            : addr.label.toUpperCase() == 'WORK'
                                ? Icons.work_outline
                                : Icons.location_on_outlined,
                        color: AllGoColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(addr.label, style: AllGoTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      if (addr.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AllGoColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('DEFAULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AllGoColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'default') onSetDefault();
                      if (val == 'delete') onDelete();
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (!addr.isDefault) const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AllGoColors.error))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${addr.recipientName} • ${addr.recipientPhone}', style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${addr.addressLine1}${addr.addressLine2 != null ? ", ${addr.addressLine2}" : ""}', style: AllGoTypography.bodyMedium),
              if (addr.landmark != null && addr.landmark!.isNotEmpty) Text('Landmark: ${addr.landmark}', style: AllGoTypography.caption),
              Text('${addr.city}, ${addr.state} - ${addr.postalCode}', style: AllGoTypography.caption),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 14, color: AllGoColors.textTertiary),
                  const SizedBox(width: 4),
                  Text('${addr.latitude.toStringAsFixed(4)}, ${addr.longitude.toStringAsFixed(4)}', style: AllGoTypography.caption.copyWith(color: AllGoColors.textTertiary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
