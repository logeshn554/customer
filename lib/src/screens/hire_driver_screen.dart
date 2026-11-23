import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/hire_driver_booking_form.dart';
import '../components/hire_driver_active_view.dart';

class HireDriverScreen extends ConsumerStatefulWidget {
  final String? activeBookingId;

  const HireDriverScreen({super.key, this.activeBookingId});

  @override
  ConsumerState<HireDriverScreen> createState() => _HireDriverScreenState();
}

class _HireDriverScreenState extends ConsumerState<HireDriverScreen> {
  final _reportingCtrl = TextEditingController();

  int _hours = 4;
  String _transmission = 'MANUAL';
  Map<String, dynamic>? _estimateData;
  bool _isEstimating = false;
  bool _isBooking = false;
  double _reportingLat = 13.0827;
  double _reportingLng = 80.2707;

  HireDriverBookingModel? _activeBooking;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.activeBookingId != null) {
      _loadBooking(widget.activeBookingId!);
    }
    _resolveInitialAddress();
    _startPolling();
  }

  Future<void> _resolveInitialAddress() async {
    try {
      final addresses = await ref.read(apiClientProvider).listCustomerAddresses();
      if (addresses.isNotEmpty && mounted) {
        final def = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        _reportingCtrl.text = '${def.addressLine1}, ${def.city}';
        _reportingLat = def.latitude;
        _reportingLng = def.longitude;
        return;
      }
    } catch (_) {}

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 4));
        if (mounted) {
          _reportingLat = pos.latitude;
          _reportingLng = pos.longitude;
          _reportingCtrl.text = 'Current GPS Location (${pos.latitude.toFixed(4)}, ${pos.longitude.toFixed(4)})';
          return;
        }
      }
    } catch (_) {}

    if (mounted && _reportingCtrl.text.isEmpty) {
      _reportingCtrl.text = 'Current Location';
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _reportingCtrl.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_activeBooking != null && mounted) {
        _loadBooking(_activeBooking!.id);
      }
    });
  }

  Future<void> _loadBooking(String bookingId) async {
    try {
      final b = await ref.read(apiClientProvider).getHireDriverBooking(bookingId);
      if (mounted) setState(() => _activeBooking = b);
    } catch (_) {}
  }

  Future<void> _handleGetEstimate() async {
    setState(() => _isEstimating = true);
    try {
      final res = await ref.read(apiClientProvider).estimateHireDriver({
        'durationHours': _hours,
        'transmissionType': _transmission,
        'reportingLatitude': _reportingLat,
        'reportingLongitude': _reportingLng,
      });
      if (mounted) setState(() => _estimateData = res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estimate failed: $e')));
    } finally {
      if (mounted) setState(() => _isEstimating = false);
    }
  }

  Future<void> _handleBookDriver() async {
    setState(() => _isBooking = true);
    try {
      final b = await ref.read(apiClientProvider).bookHireDriver({
        'reportingAddress': _reportingCtrl.text.trim().isNotEmpty ? _reportingCtrl.text.trim() : 'Current Location',
        'reportingLatitude': _reportingLat,
        'reportingLongitude': _reportingLng,
        'durationHours': _hours,
        'transmissionType': _transmission,
      });
      if (mounted) setState(() => _activeBooking = b);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(title: const Text('Hire Professional Driver')),
      body: _activeBooking != null
          ? HireDriverActiveView(booking: _activeBooking!)
          : HireDriverBookingForm(
              reportingCtrl: _reportingCtrl,
              hours: _hours,
              onHoursChanged: (h) => setState(() => _hours = h),
              transmission: _transmission,
              onTransmissionChanged: (t) => setState(() => _transmission = t),
              estimateData: _estimateData,
              isEstimating: _isEstimating,
              isBooking: _isBooking,
              onGetEstimate: _handleGetEstimate,
              onBookDriver: _handleBookDriver,
            ),
    );
  }
}

extension DoubleFormatting on double {
  String toFixed(int digits) => toStringAsFixed(digits);
}
