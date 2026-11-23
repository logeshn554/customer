import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/customer_home_tab.dart';
import '../components/customer_orders_tab.dart';
import '../components/customer_explore_tab.dart';
import '../components/unified_active_bookings_tray.dart';
import '../screens/account_screen.dart';
import '../screens/outlet_catalog_screen.dart';
import '../screens/delivery_tracking_screen.dart';
import '../screens/ride_booking_screen.dart';
import '../screens/parcel_send_screen.dart';
import '../screens/hire_driver_screen.dart';
import '../screens/support_screen.dart';
import '../screens/map_coordinate_picker_modal.dart';

class CustomerHomePage extends ConsumerStatefulWidget {
  const CustomerHomePage({super.key});

  @override
  ConsumerState<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends ConsumerState<CustomerHomePage> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _activeOrderFilter = 'ALL';

  double _currentLatitude = 13.0827;
  double _currentLongitude = 80.2707;
  String _currentAddressLabel = 'Detecting location...';
  List<CustomerAddressModel> _savedAddresses = [];

  List<DeliveryJobModel> _activeDeliveries = [];
  List<UnifiedActiveBookingItem> _unifiedBookings = [];
  List<CustomerOrderDetail> _orders = [];
  List<DiscoveryOutlet> _outlets = [];
  List<DiscoveryCategory> _categories = [];
  final TextEditingController _searchController = TextEditingController();

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _resolveUserLocationAndLoad();
    _startPeriodicPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startPeriodicPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _pollAllActiveBookings();
      }
    });
  }

  Future<void> _resolveUserLocationAndLoad() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);

    // 1. Check saved customer addresses
    try {
      final addresses = await client.listCustomerAddresses().catchError((_) => <CustomerAddressModel>[]);
      _savedAddresses = addresses;
      if (addresses.isNotEmpty) {
        final def = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        _currentLatitude = def.latitude;
        _currentLongitude = def.longitude;
        _currentAddressLabel = '${def.label}: ${def.addressLine1}, ${def.city}';
      }
    } catch (_) {}

    // 2. If no saved address, detect GPS position
    if (_savedAddresses.isEmpty) {
      try {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
          _currentLatitude = pos.latitude;
          _currentLongitude = pos.longitude;
          try {
            final rev = await client.reverseGeocode(pos.latitude, pos.longitude);
            _currentAddressLabel = rev.formattedAddress;
          } catch (_) {
            _currentAddressLabel = 'Current GPS Location';
          }
        }
      } catch (_) {
        _currentAddressLabel = 'Chennai, Anna Nagar';
      }
    }

    if (_currentAddressLabel == 'Detecting location...') {
      _currentAddressLabel = 'Current Location';
    }

    await Future.wait([
      _pollAllActiveBookings(),
      _loadOrders(),
      _loadDiscovery(),
    ]);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pollAllActiveBookings() async {
    final client = ref.read(apiClientProvider);
    final List<UnifiedActiveBookingItem> combined = [];

    // A. Active food & grocery delivery jobs
    try {
      final deliveries = await client.getCustomerActiveDeliveries().catchError((_) => <DeliveryJobModel>[]);
      if (mounted) _activeDeliveries = deliveries;
      for (final d in deliveries) {
        combined.add(
          UnifiedActiveBookingItem(
            id: d.id,
            verticalType: d.verticalType.isNotEmpty ? d.verticalType : 'FOOD',
            title: d.outletName.isNotEmpty ? d.outletName : 'Order #${d.jobNumber}',
            subtitle: 'To: ${d.destinationAddress}',
            status: d.status,
            verificationPin: d.deliveryPin,
            onTrack: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(jobId: d.id)),
              );
            },
            onSupport: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
              );
            },
          ),
        );
      }
    } catch (_) {}

    // B. Active rides
    try {
      final rides = await client.listRides().catchError((_) => <RideModel>[]);
      final activeRides = rides.where((r) => !['COMPLETED', 'CANCELLED', 'FAILED'].contains(r.status));
      for (final r in activeRides) {
        combined.add(
          UnifiedActiveBookingItem(
            id: r.id,
            verticalType: 'RIDE',
            title: '${r.serviceType.replaceAll("_", " ")} Ride',
            subtitle: 'To: ${r.destinationAddress}',
            status: r.status,
            verificationPin: r.startOtp,
            onTrack: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RideBookingScreen(activeRideId: r.id)),
              );
            },
            onSupport: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
              );
            },
          ),
        );
      }
    } catch (_) {}

    // C. Active parcels
    try {
      final parcels = await client.listCustomerParcels().catchError((_) => <ParcelModel>[]);
      final activeParcels = parcels.where((p) => !['DELIVERED', 'CANCELLED', 'FAILED', 'RETURNED'].contains(p.status));
      for (final p in activeParcels) {
        combined.add(
          UnifiedActiveBookingItem(
            id: p.id,
            verticalType: 'PARCEL',
            title: 'Parcel: ${p.packageCategory}',
            subtitle: 'To: ${p.recipientName} (${p.dropoffAddress})',
            status: p.status,
            verificationPin: p.deliveryOtp,
            onTrack: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ParcelSendScreen(activeParcelId: p.id)),
              );
            },
            onSupport: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
              );
            },
          ),
        );
      }
    } catch (_) {}

    // D. Active driver bookings
    try {
      final driverBookings = await client.listBookings().catchError((_) => <HireDriverBookingModel>[]);
      final activeDrivers = driverBookings.where((b) => !['COMPLETED', 'CANCELLED', 'FAILED'].contains(b.status));
      for (final b in activeDrivers) {
        combined.add(
          UnifiedActiveBookingItem(
            id: b.id,
            verticalType: 'HIRE_DRIVER',
            title: 'Driver (${b.durationHours} hrs - ${b.transmissionType})',
            subtitle: 'At: ${b.reportingAddress}',
            status: b.status,
            verificationPin: b.startOtp,
            onTrack: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => HireDriverScreen(activeBookingId: b.id)),
              );
            },
            onSupport: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
              );
            },
          ),
        );
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _unifiedBookings = combined);
    }
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
      final outlets = await client.listServiceableOutlets(
        lat: _currentLatitude,
        lng: _currentLongitude,
      ).catchError((_) => <DiscoveryOutlet>[]);
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

  Future<void> _handleSelectAddress() async {
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Delivery Location', style: AllGoTypography.heading3),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.my_location, color: AllGoColors.primary),
              title: const Text('Use Current GPS Location', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(ctx, {'action': 'GPS'});
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: AllGoColors.primary),
              title: const Text('Pin On Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(ctx, {'action': 'MAP'});
              },
            ),
            if (_savedAddresses.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              ..._savedAddresses.map((addr) => ListTile(
                leading: Icon(addr.label.toUpperCase() == 'HOME' ? Icons.home : Icons.work, color: AllGoColors.primary),
                title: Text('${addr.label}: ${addr.addressLine1}'),
                subtitle: Text('${addr.city}, ${addr.postalCode}'),
                onTap: () {
                  Navigator.pop(ctx, {'action': 'SELECT', 'address': addr});
                },
              )),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (picked == null || !mounted) return;

    if (picked['action'] == 'SELECT') {
      final addr = picked['address'] as CustomerAddressModel;
      setState(() {
        _currentLatitude = addr.latitude;
        _currentLongitude = addr.longitude;
        _currentAddressLabel = '${addr.label}: ${addr.addressLine1}, ${addr.city}';
      });
      _loadDiscovery();
    } else if (picked['action'] == 'MAP') {
      final result = await showModalBottomSheet<MapLocationResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MapCoordinatePickerModal(
          initialLat: _currentLatitude,
          initialLng: _currentLongitude,
        ),
      );
      if (result != null && mounted) {
        setState(() {
          _currentLatitude = result.latitude;
          _currentLongitude = result.longitude;
          _currentAddressLabel = result.addressText;
        });
        _loadDiscovery();
      }
    } else if (picked['action'] == 'GPS') {
      _resolveUserLocationAndLoad();
    }
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
              unifiedBookings: _unifiedBookings,
              currentAddressLabel: _currentAddressLabel,
              currentLatitude: _currentLatitude,
              currentLongitude: _currentLongitude,
              onSelectAddress: _handleSelectAddress,
              isLoading: _isLoading,
              onRefresh: _resolveUserLocationAndLoad,
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
