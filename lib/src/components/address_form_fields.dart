import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class AddressFormFields extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController line1Ctrl;
  final TextEditingController line2Ctrl;
  final TextEditingController landmarkCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCtrl;

  const AddressFormFields({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.line1Ctrl,
    required this.line2Ctrl,
    required this.landmarkCtrl,
    required this.cityCtrl,
    required this.postalCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AllGoTextField(
          label: 'Recipient Full Name',
          controller: nameCtrl,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 10),
        AllGoTextField(
          label: 'Phone Number',
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
        ),
        const SizedBox(height: 10),
        AllGoTextField(
          label: 'Street Address (Flat / House No / Road)',
          controller: line1Ctrl,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Street address is required' : null,
        ),
        const SizedBox(height: 10),
        AllGoTextField(
          label: 'Apartment / Suite (Optional)',
          controller: line2Ctrl,
        ),
        const SizedBox(height: 10),
        AllGoTextField(
          label: 'Landmark (Optional)',
          controller: landmarkCtrl,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AllGoTextField(
                label: 'City',
                controller: cityCtrl,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AllGoTextField(
                label: 'PIN Code',
                controller: postalCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
