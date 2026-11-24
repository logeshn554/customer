import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class HomeCategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const HomeCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static const List<Map<String, dynamic>> categories = [
    {'id': 'ALL', 'label': 'All', 'icon': Icons.apps},
    {'id': 'FOOD', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'GROCERY', 'label': 'Grocery', 'icon': Icons.shopping_basket},
    {'id': 'BIRYANI', 'label': 'Biryani', 'icon': Icons.rice_bowl},
    {'id': 'VEG', 'label': 'Pure Veg', 'icon': Icons.eco},
    {'id': 'DESSERTS', 'label': 'Desserts', 'icon': Icons.cake},
    {'id': 'CHAI', 'label': 'Tea & Coffee', 'icon': Icons.local_cafe},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat['id'] == selectedCategory;
          final icon = cat['icon'] as IconData;
          final label = cat['label'] as String;

          return InkWell(
            onTap: () => onSelectCategory(cat['id'] as String),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AllGoColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AllGoColors.primary : Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : AllGoColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AllGoColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
