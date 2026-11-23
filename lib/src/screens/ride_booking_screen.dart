import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/ride_booking_form.dart';
import '../components/active_ride_tracking_view.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  final String? activeRideId;

  const RideBookingScreen({super.key, this.activeRideId});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  final _pickupCtrl = TextEditingController(text: 'Current Location (Anna Nagar, Chennai)');
  final _destCtrl = TextEditingController(text: 'Chennai Central Railway Station');

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
    _startPolling();
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
    } catch (_) {}
  }

  Future<void> _handleGetEstimate() async {
    setState(() => _isEstimating = true);
    try {
      final res = await ref.read(apiClientProvider).estimateRideFare({
        'serviceType': _selectedCategory,
        'pickupLatitude': 13.0827,
        'pickupLongitude': 80.2707,
        'destinationLatitude': 13.0837,
        'destinationLongitude': 80.2750,
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
        'pickupLatitude': 13.0827,
        'pickupLongitude': 80.2707,
        'destinationLatitude': 13.0837,
        'destinationLongitude': 80.2750,
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
      await ref.read(apiClientProvider).triggerRideSos(_activeRide!.id, latitude: 13.0827, longitude: 80.2707);
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
            ),
    );
  }
}
