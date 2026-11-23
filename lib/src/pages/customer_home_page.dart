import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/customer_home_tab.dart';
import '../components/customer_orders_tab.dart';
import '../components/customer_explore_tab.dart';
import '../screens/account_screen.dart';
import '../screens/outlet_catalog_screen.dart';

class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _activeOrderFilter = 'ALL';

  List<DeliveryJobModel> _activeDeliveries = [];
  List<CustomerOrderDetail> _orders = [];
  List<DiscoveryOutlet> _outlets = [];
  List<DiscoveryCategory> _categories = [];
  final TextEditingController _searchController = TextEditingController();

  Timer? _deliveryTrackingTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startDeliveryPolling();
  }

  @override
  void dispose() {
    _deliveryTrackingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startDeliveryPolling() {
    _deliveryTrackingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) _pollActiveDeliveries();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _pollActiveDeliveries(),
      _loadOrders(),
      _loadDiscovery(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pollActiveDeliveries() async {
    try {
      final client = ref.read(apiClientProvider);
      final deliveries = await client.getCustomerActiveDeliveries().catchError((_) => <DeliveryJobModel>[]);
      if (mounted) setState(() => _activeDeliveries = deliveries);
    } catch (_) {}
  }

  Future<void> _loadOrders() async {
    try {
      final client = ref.read(apiClientProvider);
      final orders = await client.listCustomerOrders().catchError((_) => <CustomerOrderDetail>[]);
      if (mounted) setState(() => _orders = orders);
    } catch (_) {}
  }

  Future<void> _loadDiscovery() async {
    try {
      final client = ref.read(apiClientProvider);
      final outlets = await client.listServiceableOutlets(lat: 13.0827, lng: 80.2707).catchError((_) => <DiscoveryOutlet>[]);
      final cats = await client.listCategories().catchError((_) => <DiscoveryCategory>[]);
      if (mounted) {
        setState(() {
          _outlets = outlets;
          _categories = cats;
        });
      }
    } catch (_) {}
  }

  void _onOutletSelected(DiscoveryOutlet outlet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OutletCatalogScreen(
          outletId: outlet.outletId,
          outletName: outlet.outletName,
          categoryName: outlet.verticalType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AllGoColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            CustomerHomeTab(
              user: user,
              activeDeliveries: _activeDeliveries,
              isLoading: _isLoading,
              onRefresh: _loadInitialData,
              onNavigateTab: (idx) => setState(() => _currentIndex = idx),
            ),
            CustomerExploreTab(
              searchController: _searchController,
              outlets: _outlets,
              categories: _categories,
              isLoading: _isLoading,
              onSearch: (_) => _loadDiscovery(),
              onOutletSelected: _onOutletSelected,
            ),
            CustomerOrdersTab(
              orders: _orders,
              isLoading: _isLoading,
              onRefresh: _loadOrders,
              activeFilter: _activeOrderFilter,
              onFilterChanged: (f) => setState(() => _activeOrderFilter = f),
            ),
            const AccountScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
