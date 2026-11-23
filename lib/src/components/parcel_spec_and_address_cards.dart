import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class ParcelSpecAndAddressCards extends StatelessWidget {
  final String selectedServiceCode;
  final ValueChanged<String> onSelectService;
  final TextEditingController senderNameCtrl;
  final TextEditingController senderPhoneCtrl;
  final TextEditingController pickupAddressCtrl;
  final TextEditingController recipientNameCtrl;
  final TextEditingController recipientPhoneCtrl;
  final TextEditingController dropoffAddressCtrl;
  final TextEditingController descriptionCtrl;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final double weightKg;
  final ValueChanged<double> onWeightChanged;
  final ParcelQuote? quote;
  final bool isQuoting;
  final VoidCallback? onGetQuote;

  final String selectedVehicleType;
  final ValueChanged<String>? onSelectVehicle;
  final bool isFragile;
  final ValueChanged<bool>? onFragileChanged;

  const ParcelSpecAndAddressCards({
    super.key,
    required this.selectedServiceCode,
    required this.onSelectService,
    required this.senderNameCtrl,
    required this.senderPhoneCtrl,
    required this.pickupAddressCtrl,
    required this.recipientNameCtrl,
    required this.recipientPhoneCtrl,
    required this.dropoffAddressCtrl,
    required this.descriptionCtrl,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.weightKg,
    required this.onWeightChanged,
    this.quote,
    this.isQuoting = false,
    this.onGetQuote,
    this.selectedVehicleType = 'TWO_WHEELER',
    this.onSelectVehicle,
    this.isFragile = false,
    this.onFragileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final vehicles = [
      {'code': 'TWO_WHEELER', 'name': '2-Wheeler', 'capacity': 'Up to 20kg', 'icon': Icons.two_wheeler},
      {'code': 'THREE_WHEELER', 'name': '3-Wheeler Cargo', 'capacity': 'Up to 500kg', 'icon': Icons.electric_rickshaw},
      {'code': 'TATA_ACE', 'name': 'Tata Ace', 'capacity': 'Up to 1000kg', 'icon': Icons.local_shipping},
      {'code': 'PICKUP_TRUCK', 'name': 'Pickup Truck', 'capacity': 'Up to 1500kg', 'icon': Icons.fire_truck},
    ];

    final categories = [
      'DOCUMENTS',
      'ELECTRONICS',
      'HOUSEHOLD',
      'APPAREL',
      'FRAGILE',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vehicle Category Selector (Porter-style)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Transport Vehicle', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, idx) {
                      final v = vehicles[idx];
                      final isSelected = v['code'] == selectedVehicleType;
                      return InkWell(
                        onTap: () => onSelectVehicle?.call(v['code'] as String),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? AllGoColors.primary.withOpacity(0.12) : AllGoColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AllGoColors.primary : AllGoColors.divider,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(v['icon'] as IconData, color: isSelected ? AllGoColors.primary : AllGoColors.textSecondary, size: 28),
                              const SizedBox(height: 4),
                              Text(v['name'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              Text(v['capacity'] as String, style: const TextStyle(fontSize: 9, color: AllGoColors.textTertiary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Service Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Delivery Speed', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onSelectService('STANDARD'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectedServiceCode == 'STANDARD' ? AllGoColors.primary.withOpacity(0.1) : null,
                          side: BorderSide(color: selectedServiceCode == 'STANDARD' ? AllGoColors.primary : AllGoColors.divider),
                        ),
                        child: const Text('Standard (2-4 hrs)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onSelectService('EXPRESS'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectedServiceCode == 'EXPRESS' ? AllGoColors.primary.withOpacity(0.1) : null,
                          side: BorderSide(color: selectedServiceCode == 'EXPRESS' ? AllGoColors.primary : AllGoColors.divider),
                        ),
                        child: const Text('Express (60 mins)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Package Specification
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cargo & Package Category', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: categories.map((cat) {
                    final isSelected = cat == selectedCategory;
                    return ChoiceChip(
                      label: Text(cat, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AllGoColors.textPrimary)),
                      selected: isSelected,
                      selectedColor: AllGoColors.primary,
                      onSelected: (_) => onSelectCategory(cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                AllGoTextField(label: 'Item Description (e.g. Office files, Fragile monitor)', controller: descriptionCtrl),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fragile Cargo Handling', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Courier will secure package with bubble cushion', style: TextStyle(fontSize: 11)),
                  value: isFragile,
                  onChanged: (val) => onFragileChanged?.call(val),
                ),
                const Divider(height: 16),
                Text('Billable Weight: ${weightKg.toStringAsFixed(1)} kg', style: AllGoTypography.bodyMedium),
                Slider(
                  value: weightKg,
                  min: 0.5,
                  max: selectedVehicleType == 'TWO_WHEELER' ? 20.0 : 1000.0,
                  divisions: selectedVehicleType == 'TWO_WHEELER' ? 39 : 100,
                  label: '${weightKg.toStringAsFixed(1)} kg',
                  onChanged: onWeightChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Sender
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sender Details (Pickup)', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                AllGoTextField(label: 'Sender Name', controller: senderNameCtrl),
                const SizedBox(height: 8),
                AllGoTextField(label: 'Sender Phone', controller: senderPhoneCtrl, keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                AllGoTextField(label: 'Pickup Address', controller: pickupAddressCtrl),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Recipient
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recipient Details (Dropoff)', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                AllGoTextField(label: 'Recipient Name', controller: recipientNameCtrl),
                const SizedBox(height: 8),
                AllGoTextField(label: 'Recipient Phone', controller: recipientPhoneCtrl, keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                AllGoTextField(label: 'Dropoff Address', controller: dropoffAddressCtrl),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (onGetQuote != null) ...[
          AllGoButton(
            label: 'Calculate Fare Estimate',
            isLoading: isQuoting,
            onPressed: onGetQuote,
          ),
        ],
        if (quote != null) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Delivery Fare', style: AllGoTypography.caption.copyWith(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                      Text('₹${quote!.totalFareInr.toStringAsFixed(2)}', style: AllGoTypography.heading2.copyWith(color: Colors.green.shade900)),
                    ],
                  ),
                  Text('${quote!.distanceKm.toStringAsFixed(1)} km', style: AllGoTypography.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
