import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../common/friendly_error.dart';
import '../components/unified_active_bookings_tray.dart';

class CustomerHomeState {
  final bool isLoading;
  final String currentAddressLabel;
  final double currentLatitude;
  final double currentLongitude;
  final List<CustomerAddressModel> savedAddresses;
  final List<DiscoveryOutlet> outlets;
  final List<DiscoveryCategory> categories;
  final List<CustomerOrderDetail> orders;
  final List<DeliveryJobModel> activeDeliveries;
  final List<UnifiedActiveBookingItem> unifiedBookings;
  final String activeOrderFilter;

  const CustomerHomeState({
    this.isLoading = true,
    this.currentAddressLabel = 'Detecting location...',
    this.currentLatitude = 13.0827,
    this.currentLongitude = 80.2707,
    this.savedAddresses = const [],
    this.outlets = const [],
    this.categories = const [],
    this.orders = const [],
    this.activeDeliveries = const [],
    this.unifiedBookings = const [],
    this.activeOrderFilter = 'ALL',
  });

  CustomerHomeState copyWith({
    bool? isLoading,
    String? currentAddressLabel,
    double? currentLatitude,
    double? currentLongitude,
    List<CustomerAddressModel>? savedAddresses,
    List<DiscoveryOutlet>? outlets,
    List<DiscoveryCategory>? categories,
    List<CustomerOrderDetail>? orders,
    List<DeliveryJobModel>? activeDeliveries,
    List<UnifiedActiveBookingItem>? unifiedBookings,
    String? activeOrderFilter,
  }) {
    return CustomerHomeState(
      isLoading: isLoading ?? this.isLoading,
      currentAddressLabel: currentAddressLabel ?? this.currentAddressLabel,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      outlets: outlets ?? this.outlets,
      categories: categories ?? this.categories,
      orders: orders ?? this.orders,
      activeDeliveries: activeDeliveries ?? this.activeDeliveries,
      unifiedBookings: unifiedBookings ?? this.unifiedBookings,
      activeOrderFilter: activeOrderFilter ?? this.activeOrderFilter,
    );
  }
}

class CustomerHomeNotifier extends StateNotifier<CustomerHomeState> {
  final Ref _ref;

  CustomerHomeNotifier(this._ref) : super(const CustomerHomeState()) {
    init();
  }

  ApiClient get _client => _ref.read(apiClientProvider);

  Future<void> init() async {
    await resolveLocationAndLoad();
  }

  Future<void> resolveLocationAndLoad() async {
    state = state.copyWith(isLoading: true);
    double lat = state.currentLatitude;
    double lng = state.currentLongitude;
    String addrLabel = state.currentAddressLabel;

    try {
      final addresses = await _client.listCustomerAddresses().catchError((_) => <CustomerAddressModel>[]);
      final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
      if (defaultAddr != null) {
        lat = defaultAddr.latitude;
        lng = defaultAddr.longitude;
        addrLabel = '${defaultAddr.label}: ${defaultAddr.addressLine1}, ${defaultAddr.city}';
      } else {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
          lat = pos.latitude;
          lng = pos.longitude;
          try {
            final rev = await _client.reverseGeocode(pos.latitude, pos.longitude);
            addrLabel = rev.formattedAddress;
          } catch (_) {
            addrLabel = 'Current GPS Location';
          }
        }
      }
      state = state.copyWith(savedAddresses: addresses);
    } catch (_) {
      addrLabel = 'Chennai, Anna Nagar';
    }

    if (addrLabel == 'Detecting location...') {
      addrLabel = 'Current Location';
    }

    state = state.copyWith(
      currentLatitude: lat,
      currentLongitude: lng,
      currentAddressLabel: addrLabel,
    );

    await Future.wait([
      pollActiveBookings(),
      loadOrders(),
      loadDiscovery(),
    ]);

    state = state.copyWith(isLoading: false);
  }

  Future<void> pollActiveBookings() async {
    final List<UnifiedActiveBookingItem> combined = [];

    // A. Deliveries
    try {
      final deliveries = await _client.getCustomerActiveDeliveries().catchError((_) => <DeliveryJobModel>[]);
      state = state.copyWith(activeDeliveries: deliveries);
      for (final d in deliveries) {
        combined.add(
          UnifiedActiveBookingItem(
            id: d.id,
            verticalType: d.verticalType.isNotEmpty ? d.verticalType : 'FOOD',
            title: (d.outletName != null && d.outletName!.isNotEmpty) ? d.outletName! : 'Order #${d.jobNumber}',
            subtitle: 'To: ${d.dropoffAddress}',
            status: d.status,
            verificationPin: d.deliveryPin,
            onTrack: () {},
            onSupport: () {},
          ),
        );
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }

    // B. Rides
    try {
      final rides = await _client.listRides().catchError((_) => <RideModel>[]);
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
            onTrack: () {},
            onSupport: () {},
          ),
        );
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }

    // C. Parcels
    try {
      final parcels = await _client.listCustomerParcels().catchError((_) => <ParcelModel>[]);
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
            onTrack: () {},
            onSupport: () {},
          ),
        );
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }

    // D. Driver bookings
    try {
      final driverBookings = await _client.listBookings().catchError((_) => <HireDriverBookingModel>[]);
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
            onTrack: () {},
            onSupport: () {},
          ),
        );
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }

    state = state.copyWith(unifiedBookings: combined);
  }

  Future<void> loadOrders() async {
    try {
      final orders = await _client.listCustomerOrders().catchError((_) => <CustomerOrderDetail>[]);
      state = state.copyWith(orders: orders);
    } catch (e, st) {
      FriendlyError.from(e, st);
    }
  }

  Future<void> loadDiscovery() async {
    try {
      final outlets = await _client.listServiceableOutlets(
        lat: state.currentLatitude,
        lng: state.currentLongitude,
      ).catchError((_) => <DiscoveryOutlet>[]);
      final cats = await _client.listCategories().catchError((_) => <DiscoveryCategory>[]);
      state = state.copyWith(outlets: outlets, categories: cats);
    } catch (e, st) {
      FriendlyError.from(e, st);
    }
  }

  void setLocation(double lat, double lng, String label) {
    state = state.copyWith(
      currentLatitude: lat,
      currentLongitude: lng,
      currentAddressLabel: label,
    );
    loadDiscovery();
  }

  void setOrderFilter(String filter) {
    state = state.copyWith(activeOrderFilter: filter);
  }
}

final customerHomeProvider = StateNotifierProvider<CustomerHomeNotifier, CustomerHomeState>((ref) {
  return CustomerHomeNotifier(ref);
});
