import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class DeliverySlotPicker extends StatelessWidget {
  final bool isScheduled;
  final String selectedSlot;
  final void Function(bool scheduled, String slot) onSlotChanged;

  const DeliverySlotPicker({
    super.key,
    required this.isScheduled,
    required this.selectedSlot,
    required this.onSlotChanged,
  });

  static const List<String> scheduleSlots = [
    'Today: 7:00 PM - 8:00 PM',
    'Today: 8:00 PM - 9:00 PM',
    'Tomorrow: 8:00 AM - 9:00 AM',
    'Tomorrow: 12:00 PM - 1:00 PM',
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
          Row(
            children: [
              const Icon(Icons.schedule, size: 20, color: AllGoColors.primary),
              const SizedBox(width: 8),
              Text(
                'Delivery Slot',
                style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Deliver Now (25-35m)', style: TextStyle(fontSize: 12)),
                  selected: !isScheduled,
                  onSelected: (val) {
                    if (val) onSlotChanged(false, 'NOW');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Schedule Later', style: TextStyle(fontSize: 12)),
                  selected: isScheduled,
                  onSelected: (val) {
                    if (val) onSlotChanged(true, scheduleSlots.first);
                  },
                ),
              ),
            ],
          ),
          if (isScheduled) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSlot == 'NOW' ? scheduleSlots.first : selectedSlot,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: scheduleSlots.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) onSlotChanged(true, val);
              },
            ),
          ],
        ],
      ),
    );
  }
}
