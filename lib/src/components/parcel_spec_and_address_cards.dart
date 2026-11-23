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
  final VoidCallback onGetQuote;

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
    required this.quote,
    required this.isQuoting,
    required this.onGetQuote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

        // Sender
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sender Details', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
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
                Text('Recipient Details', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
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

        // Package Specification
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Package Specifications', style: AllGoTypography.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                AllGoTextField(label: 'Package Description (e.g. Documents, Keys)', controller: descriptionCtrl),
                const SizedBox(height: 12),
                Text('Estimated Weight: ${weightKg.toStringAsFixed(1)} kg', style: AllGoTypography.bodyMedium),
                Slider(
                  value: weightKg,
                  min: 0.5,
                  max: 20.0,
                  divisions: 39,
                  label: '${weightKg.toStringAsFixed(1)} kg',
                  onChanged: onWeightChanged,
                ),
                const SizedBox(height: 12),
                AllGoButton(
                  label: 'Calculate Fare Estimate',
                  isLoading: isQuoting,
                  onPressed: onGetQuote,
                ),
              ],
            ),
          ),
        ),
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
