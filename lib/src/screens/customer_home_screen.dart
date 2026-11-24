import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../components/customer_explore_tab.dart';
import '../components/customer_home_tab.dart';
import '../components/customer_orders_tab.dart';
import '../components/delivery_address_selection_sheet.dart';
import '../components/unified_active_bookings_tray.dart';
import '../localization/app_localizations.dart';
import '../providers/customer_home_provider.dart';
import '../widgets/connectivity_banner.dart';
import 'account_screen.dart';
import 'delivery_tracking_screen.dart';
import 'hire_driver_screen.dart';
import 'outlet_catalog_screen.dart';
import 'parcel_send_screen.dart';
import 'ride_booking_screen.dart';
import 'support_screen.dart';

class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _handleSelectAddress(CustomerHomeState state) {
    DeliveryAddressSelectionSheet.show(
      context: context,
      savedAddresses: state.savedAddresses,
      currentLatitude: state.currentLatitude,
      currentLongitude: state.currentLongitude,
      onLocationSelected: (lat, lng, label) {
        ref.read(customerHomeProvider.notifier).setLocation(lat, lng, label);
      },
      onUseGps: () {
        ref.read(customerHomeProvider.notifier).resolveLocationAndLoad();
      },
    );
  }

  List<UnifiedActiveBookingItem> _enrichBookings(List<UnifiedActiveBookingItem> items) {
    return items.map((item) {
      return UnifiedActiveBookingItem(
        id: item.id,
        verticalType: item.verticalType,
        title: item.title,
        subtitle: item.subtitle,
        status: item.status,
        verificationPin: item.verificationPin,
        onTrack: () => _navigateToTracking(item),
        onSupport: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
          );
        },
      );
    }).toList();
  }

  void _navigateToTracking(UnifiedActiveBookingItem item) {
    switch (item.verticalType) {
      case 'RIDE':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RideBookingScreen(activeRideId: item.id)),
        );
        break;
      case 'PARCEL':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ParcelSendScreen(activeParcelId: item.id)),
        );
        break;
      case 'HIRE_DRIVER':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HireDriverScreen(activeBookingId: item.id)),
        );
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(jobId: item.id)),
        );
    }
  }

  Future<bool> _showExitAppDialog() async {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.exitAppTitle ?? 'Exit AllGo?';
    final message = l10n?.exitAppMessage ?? 'Do you want to exit the application?';
    final cancel = l10n?.cancel ?? 'Cancel';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final homeState = ref.watch(customerHomeProvider);
    final homeNotifier = ref.read(customerHomeProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final shouldExit = await _showExitAppDialog();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ConnectivityBanner(
                isOffline: homeState.isOffline,
                onRetry: homeNotifier.resolveLocationAndLoad,
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    CustomerHomeTab(
                      user: user,
                      activeDeliveries: homeState.activeDeliveries,
                      unifiedBookings: _enrichBookings(homeState.unifiedBookings),
                      currentAddressLabel: homeState.currentAddressLabel,
                      currentLatitude: homeState.currentLatitude,
                      currentLongitude: homeState.currentLongitude,
                      onSelectAddress: () => _handleSelectAddress(homeState),
                      isLoading: homeState.isLoading,
                      onRefresh: homeNotifier.resolveLocationAndLoad,
                      onNavigateTab: (idx) => setState(() => _currentIndex = idx),
                    ),
                    CustomerExploreTab(
                      searchController: _searchController,
                      outlets: homeState.outlets,
                      categories: homeState.categories,
                      isLoading: homeState.isLoading,
                      onSearch: (_) => homeNotifier.loadDiscovery(),
                      onOutletSelected: _onOutletSelected,
                    ),
                    CustomerOrdersTab(
                      orders: homeState.orders,
                      isLoading: homeState.isLoading,
                      onRefresh: homeNotifier.loadOrders,
                      activeFilter: homeState.activeOrderFilter,
                      onFilterChanged: homeNotifier.setOrderFilter,
                    ),
                    const AccountScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n?.tabHome ?? 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore),
              label: l10n?.tabExplore ?? 'Explore',
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: l10n?.tabOrders ?? 'Orders',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n?.tabAccount ?? 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
