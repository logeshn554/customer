import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class DeliveryInstructionsSelector extends StatelessWidget {
  final Set<String> selectedInstructions;
  final ValueChanged<Set<String>> onChanged;
  final TextEditingController cookingNotesController;

  const DeliveryInstructionsSelector({
    super.key,
    required this.selectedInstructions,
    required this.onChanged,
    required this.cookingNotesController,
  });

  static const List<Map<String, dynamic>> options = [
    {'id': 'LEAVE_AT_DOOR', 'label': 'Leave at door', 'icon': Icons.door_front_door_outlined},
    {'id': 'DONT_RING_BELL', 'label': "Don't ring bell", 'icon': Icons.notifications_off_outlined},
    {'id': 'AVOID_CALLING', 'label': 'Avoid calling', 'icon': Icons.phone_disabled_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Instructions',
            style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: options.map((opt) {
              final id = opt['id'] as String;
              final isSelected = selectedInstructions.contains(id);
              final icon = opt['icon'] as IconData;
              final label = opt['label'] as String;

              return FilterChip(
                avatar: Icon(icon, size: 16, color: isSelected ? AllGoColors.primary : AllGoColors.textSecondary),
                label: Text(label, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (val) {
                  final next = Set<String>.from(selectedInstructions);
                  if (val) {
                    next.add(id);
                  } else {
                    next.remove(id);
                  }
                  onChanged(next);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cookingNotesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Any cooking / packaging requests? (e.g. less spicy, cutlery)',
              prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
