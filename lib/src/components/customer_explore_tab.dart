import 'dart:async';
import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../widgets/app_network_image.dart';
import '../widgets/empty_state_view.dart';
import 'search_filter_bottom_sheet.dart';

class CustomerExploreTab extends StatefulWidget {
  final TextEditingController searchController;
  final List<DiscoveryOutlet> outlets;
  final List<DiscoveryCategory> categories;
  final bool isLoading;
  final ValueChanged<String> onSearch;
  final void Function(DiscoveryOutlet outlet) onOutletSelected;

  const CustomerExploreTab({
    super.key,
    required this.searchController,
    required this.outlets,
    required this.categories,
    required this.isLoading,
    required this.onSearch,
    required this.onOutletSelected,
  });

  @override
  State<CustomerExploreTab> createState() => _CustomerExploreTabState();
}

class _CustomerExploreTabState extends State<CustomerExploreTab> {
  Timer? _debounce;
  SearchFilters _filters = const SearchFilters();
  final List<String> _recentSearches = ['Biryani', 'Pizza', 'Milk & Curd', 'Dosa', 'Burgers'];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(query);
    });
  }

  List<DiscoveryOutlet> get _filteredOutlets {
    var list = widget.outlets;
    final query = widget.searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((o) =>
        o.outletName.toLowerCase().contains(query) ||
        o.businessName.toLowerCase().contains(query) ||
        o.verticalType.toLowerCase().contains(query)
      ).toList();
    }
    if (_filters.rating4Plus) {
      list = list.where((o) => o.rating >= 4.0).toList();
    }
    if (_filters.under30Mins) {
      list = list.where((o) => o.estimatedDeliveryMins <= 30).toList();
    }
    if (_filters.sortBy == 'TIME') {
      list.sort((a, b) => a.estimatedDeliveryMins.compareTo(b.estimatedDeliveryMins));
    } else if (_filters.sortBy == 'RATING') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.searchController.text.trim();

    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search restaurants, groceries, dishes...',
                        prefixIcon: const Icon(Icons.search, size: 22),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  widget.searchController.clear();
                                  widget.onSearch('');
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Badge(
                      isLabelVisible: _filters.hasActiveFilters,
                      child: const Icon(Icons.tune),
                    ),
                    tooltip: 'Filters',
                    onPressed: () {
                      SearchFilterBottomSheet.show(
                        context: context,
                        initialFilters: _filters,
                        onApply: (f) => setState(() => _filters = f),
                      );
                    },
                  ),
                ],
              ),
              if (_recentSearches.isNotEmpty && query.isEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentSearches.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final item = _recentSearches[i];
                      return ActionChip(
                        avatar: const Icon(Icons.history, size: 14),
                        label: Text(item, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          widget.searchController.text = item;
                          widget.onSearch(item);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        // Results
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredOutlets.isEmpty
                  ? EmptyStateView(
                      icon: Icons.search_off,
                      title: 'No outlets found',
                      message: 'We could not find any matches for "$query". Try searching for something else.',
                      actionLabel: 'Reset Filters',
                      onAction: () {
                        widget.searchController.clear();
                        setState(() => _filters = const SearchFilters());
                        widget.onSearch('');
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredOutlets.length,
                      itemBuilder: (context, index) {
                        final outlet = _filteredOutlets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                          ),
                          child: InkWell(
                            onTap: () => widget.onOutletSelected(outlet),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  AppNetworkImage(
                                    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
                                    width: 72,
                                    height: 72,
                                    borderRadius: BorderRadius.circular(10),
                                    fallbackIcon: Icons.storefront,
                                    semanticsLabel: outlet.outletName,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          outlet.outletName,
                                          style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 14, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              outlet.rating.toStringAsFixed(1),
                                              style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 6),
                                            Text('• ${outlet.estimatedDeliveryMins} mins • ${outlet.distanceKm.toStringAsFixed(1)} km', style: AllGoTypography.caption),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${outlet.verticalType} • ${outlet.businessName}',
                                          style: AllGoTypography.caption.copyWith(color: AllGoColors.textTertiary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: AllGoColors.textTertiary),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
