import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/ride_booking_form.dart';
import '../components/active_ride_tracking_view.dart';
import 'map_coordinate_picker_modal.dart';
import '../common/friendly_error.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  final String? activeRideId;

  const RideBookingScreen({super.key, this.activeRideId});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  final _pickupCtrl = TextEditingController(text: 'Current Location');
  final _destCtrl = TextEditingController();

  double _pickupLat = 13.0827;
  double _pickupLng = 80.2707;
  double _destLat = 13.0405;
  double _destLng = 80.2337;

  String _selectedCategory = 'AUTO';
  Map<String, dynamic>? _estimateData;
  bool _isEstimating = false;
  bool _isBooking = false;
  bool _isCancelling = false;
  bool _isTriggeringSos = false;

  RideModel? _activeRide;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.activeRideId != null) {
      _loadRide(widget.activeRideId!);
    }
    _initPickupLocation();
    _startPolling();
  }

  Future<void> _initPickupLocation() async {
    try {
      final addresses = await ref.read(apiClientProvider).listCustomerAddresses();
      if (addresses.isNotEmpty && mounted) {
        final def = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        _pickupCtrl.text = '${def.addressLine1}, ${def.city}';
        _pickupLat = def.latitude;
        _pickupLng = def.longitude;
        return;
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }

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
        if (mounted) {
          _pickupLat = pos.latitude;
          _pickupLng = pos.longitude;
          try {
            final rev = await ref.read(apiClientProvider).reverseGeocode(pos.latitude, pos.longitude);
            _pickupCtrl.text = rev.formattedAddress;
          } catch (e, st) {
            FriendlyError.from(e, st);
            _pickupCtrl.text = 'Current GPS Location';
          }
        }
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pickupCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_activeRide != null && mounted) {
        _loadRide(_activeRide!.id);
      }
    });
  }

  Future<void> _loadRide(String rideId) async {
    try {
      final ride = await ref.read(apiClientProvider).getRide(rideId);
      if (mounted) setState(() => _activeRide = ride);
    } catch (e, st) {
      FriendlyError.from(e, st);
    }
  }

  Future<void> _pickPickupOnMap() async {
    final res = await showModalBottomSheet<MapLocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapCoordinatePickerModal(
        initialLat: _pickupLat,
        initialLng: _pickupLng,
      ),
    );
    if (res != null && mounted) {
      setState(() {
        _pickupLat = res.latitude;
        _pickupLng = res.longitude;
        _pickupCtrl.text = res.addressText;
      });
    }
  }

  Future<void> _pickDestOnMap() async {
    final res = await showModalBottomSheet<MapLocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapCoordinatePickerModal(
        initialLat: _destLat,
        initialLng: _destLng,
      ),
    );
    if (res != null && mounted) {
      setState(() {
        _destLat = res.latitude;
        _destLng = res.longitude;
        _destCtrl.text = res.addressText;
      });
    }
  }

  Future<void> _handleGetEstimate() async {
    if (_destCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or pin destination location')),
      );
      return;
    }
    setState(() => _isEstimating = true);
    try {
      final res = await ref.read(apiClientProvider).estimateRideFare({
        'serviceType': _selectedCategory,
        'pickupLatitude': _pickupLat,
        'pickupLongitude': _pickupLng,
        'destinationLatitude': _destLat,
        'destinationLongitude': _destLng,
      });
      if (mounted) setState(() => _estimateData = res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estimate failed: $e')));
    } finally {
      if (mounted) setState(() => _isEstimating = false);
    }
  }

  Future<void> _handleConfirmRide() async {
    setState(() => _isBooking = true);
    try {
      final ride = await ref.read(apiClientProvider).bookRide({
        'serviceType': _selectedCategory,
        'pickupAddress': _pickupCtrl.text,
        'destinationAddress': _destCtrl.text,
        'pickupLatitude': _pickupLat,
        'pickupLongitude': _pickupLng,
        'destinationLatitude': _destLat,
        'destinationLongitude': _destLng,
      });
      if (mounted) setState(() => _activeRide = ride);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Future<void> _handleCancelRide() async {
    if (_activeRide == null) return;
    setState(() => _isCancelling = true);
    try {
      await ref.read(apiClientProvider).cancelRide(_activeRide!.id, reason: 'Customer cancelled');
      if (mounted) setState(() => _activeRide = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _handleTriggerSos() async {
    if (_activeRide == null) return;
    setState(() => _isTriggeringSos = true);
    try {
      await ref.read(apiClientProvider).triggerRideSos(
        _activeRide!.id,
        latitude: _pickupLat,
        longitude: _pickupLng,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('EMERGENCY SOS ALERT BROADCASTED'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS failed: $e')));
    } finally {
      if (mounted) setState(() => _isTriggeringSos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: const Text('Mobility Rides'),
        actions: [
          if (_activeRide != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadRide(_activeRide!.id),
            ),
        ],
      ),
      body: _activeRide != null
          ? ActiveRideTrackingView(
              ride: _activeRide!,
              isCancelling: _isCancelling,
              isTriggeringSos: _isTriggeringSos,
              onCancel: _handleCancelRide,
              onTriggerSos: _handleTriggerSos,
            )
          : RideBookingForm(
              pickupCtrl: _pickupCtrl,
              destCtrl: _destCtrl,
              selectedCategory: _selectedCategory,
              onSelectCategory: (c) => setState(() => _selectedCategory = c),
              estimateData: _estimateData,
              isEstimating: _isEstimating,
              isBooking: _isBooking,
              onGetEstimate: _handleGetEstimate,
              onConfirmRide: _handleConfirmRide,
              onPickPickupOnMap: _pickPickupOnMap,
              onPickDestOnMap: _pickDestOnMap,
            ),
    );
  }
}
