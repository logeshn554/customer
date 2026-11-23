import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'outlet_catalog_screen.dart';

class FavoriteAndRecentStoresScreen extends ConsumerStatefulWidget {
  const FavoriteAndRecentStoresScreen({super.key});

  @override
  ConsumerState<FavoriteAndRecentStoresScreen> createState() => _FavoriteAndRecentStoresScreenState();
}

class _FavoriteAndRecentStoresScreenState extends ConsumerState<FavoriteAndRecentStoresScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DiscoveryOutlet> _favorites = [];
  List<DiscoveryOutlet> _recent = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);
    try {
      final results = await Future.wait([
        client.getFavoriteStores().catchError((_) => <DiscoveryOutlet>[]),
        client.getRecentlyViewedStores().catchError((_) => <DiscoveryOutlet>[]),
      ]);
      if (mounted) {
        setState(() {
          _favorites = results[0];
          _recent = results[1];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStoreCard(DiscoveryOutlet outlet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllGoColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AllGoColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.storefront, color: AllGoColors.primary),
        ),
        title: Text(outlet.name, style: AllGoTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(outlet.address, style: AllGoTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  outlet.isOpen ? Icons.check_circle : Icons.access_time,
                  size: 14,
                  color: outlet.isOpen ? AllGoColors.success : AllGoColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  outlet.isOpen ? 'Open Now' : 'Closed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: outlet.isOpen ? AllGoColors.success : AllGoColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Text('•  ${outlet.distanceKm.toStringAsFixed(1)} km', style: AllGoTypography.caption),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AllGoColors.textTertiary),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OutletCatalogScreen(
                outletId: outlet.id,
                outletName: outlet.name,
              ),
            ),
          ).then((_) => _loadStores());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: const Text('My Stores'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AllGoColors.primary,
          unselectedLabelColor: AllGoColors.textSecondary,
          indicatorColor: AllGoColors.primary,
          tabs: [
            Tab(text: 'Favorites (${_favorites.length})'),
            Tab(text: 'Recently Viewed (${_recent.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Favorites tab
                _favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_border, size: 64, color: AllGoColors.textTertiary),
                            const SizedBox(height: 16),
                            Text('No favorite stores yet', style: AllGoTypography.heading3),
                            const SizedBox(height: 8),
                            Text('Tap the heart icon in any store to save it here', style: AllGoTypography.caption),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStores,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _favorites.length,
                          itemBuilder: (_, i) => _buildStoreCard(_favorites[i]),
                        ),
                      ),
                // Recent tab
                _recent.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history, size: 64, color: AllGoColors.textTertiary),
                            const SizedBox(height: 16),
                            Text('No recently viewed stores', style: AllGoTypography.heading3),
                            const SizedBox(height: 8),
                            Text('Stores you browse will show up here for quick access', style: AllGoTypography.caption),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStores,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _recent.length,
                          itemBuilder: (_, i) => _buildStoreCard(_recent[i]),
                        ),
                      ),
              ],
            ),
    );
  }
}
