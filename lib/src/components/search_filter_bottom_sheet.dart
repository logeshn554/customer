import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class SearchFilters {
  final bool vegOnly;
  final bool rating4Plus;
  final bool under30Mins;
  final String sortBy; // POPULAR, RATING, TIME, PRICE_LOW

  const SearchFilters({
    this.vegOnly = false,
    this.rating4Plus = false,
    this.under30Mins = false,
    this.sortBy = 'POPULAR',
  });

  SearchFilters copyWith({
    bool? vegOnly,
    bool? rating4Plus,
    bool? under30Mins,
    String? sortBy,
  }) {
    return SearchFilters(
      vegOnly: vegOnly ?? this.vegOnly,
      rating4Plus: rating4Plus ?? this.rating4Plus,
      under30Mins: under30Mins ?? this.under30Mins,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters => vegOnly || rating4Plus || under30Mins || sortBy != 'POPULAR';
}

class SearchFilterBottomSheet extends StatefulWidget {
  final SearchFilters initialFilters;
  final ValueChanged<SearchFilters> onApply;

  const SearchFilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required SearchFilters initialFilters,
    required ValueChanged<SearchFilters> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SearchFilterBottomSheet(
        initialFilters: initialFilters,
        onApply: onApply,
      ),
    );
  }

  @override
  State<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SearchFilters _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter & Sort', style: AllGoTypography.heading3),
                TextButton(
                  onPressed: () => setState(() => _current = const SearchFilters()),
                  child: const Text('Reset All', style: TextStyle(color: AllGoColors.error)),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('Dietary & Timing', style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Veg Only'),
                  selected: _current.vegOnly,
                  onSelected: (v) => setState(() => _current = _current.copyWith(vegOnly: v)),
                ),
                FilterChip(
                  label: const Text('Rating 4.0+'),
                  selected: _current.rating4Plus,
                  onSelected: (v) => setState(() => _current = _current.copyWith(rating4Plus: v)),
                ),
                FilterChip(
                  label: const Text('Under 30 Mins'),
                  selected: _current.under30Mins,
                  onSelected: (v) => setState(() => _current = _current.copyWith(under30Mins: v)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Sort By', style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Relevance / Popularity'),
              value: 'POPULAR',
              groupValue: _current.sortBy,
              onChanged: (v) => setState(() => _current = _current.copyWith(sortBy: v)),
            ),
            RadioListTile<String>(
              title: const Text('Fastest Delivery'),
              value: 'TIME',
              groupValue: _current.sortBy,
              onChanged: (v) => setState(() => _current = _current.copyWith(sortBy: v)),
            ),
            RadioListTile<String>(
              title: const Text('Rating: High to Low'),
              value: 'RATING',
              groupValue: _current.sortBy,
              onChanged: (v) => setState(() => _current = _current.copyWith(sortBy: v)),
            ),
            const SizedBox(height: 16),
            AllGoButton(
              label: 'Apply Filters',
              onPressed: () {
                widget.onApply(_current);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
