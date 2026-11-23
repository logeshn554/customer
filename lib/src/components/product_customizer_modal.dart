import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class ProductCustomizerModal extends StatefulWidget {
  final ProductItem product;
  final List<OptionGroup> optionGroups;
  final void Function(int quantity, List<String> selectedOptionIds) onAddToCart;

  const ProductCustomizerModal({
    super.key,
    required this.product,
    required this.optionGroups,
    required this.onAddToCart,
  });

  @override
  State<ProductCustomizerModal> createState() => _ProductCustomizerModalState();
}

class _ProductCustomizerModalState extends State<ProductCustomizerModal> {
  int _quantity = 1;
  final Set<String> _selectedOptionIds = {};

  double get _totalPrice {
    double total = widget.product.basePriceInr;
    for (final group in widget.optionGroups) {
      for (final opt in group.options) {
        if (_selectedOptionIds.contains(opt.id)) {
          total += opt.priceModifierInr;
        }
      }
    }
    return total * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.product.name, style: AllGoTypography.heading3),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.optionGroups.map((g) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.name, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ...g.options.map((opt) {
                  return CheckboxListTile(
                    value: _selectedOptionIds.contains(opt.id),
                    title: Text(opt.name),
                    subtitle: Text('+₹${opt.priceModifierInr.toStringAsFixed(0)}'),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedOptionIds.add(opt.id);
                        } else {
                          _selectedOptionIds.remove(opt.id);
                        }
                      });
                    },
                  );
                }),
              ],
            );
          }),
          const SizedBox(height: 16),
          AllGoButton(
            label: 'Add to Cart - ₹${_totalPrice.toStringAsFixed(0)}',
            onPressed: () {
              Navigator.pop(context);
              widget.onAddToCart(_quantity, _selectedOptionIds.toList());
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
