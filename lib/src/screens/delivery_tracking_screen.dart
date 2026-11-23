import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/live_trip_tracking_bottom_sheet.dart';

class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  final String jobId;

  const DeliveryTrackingScreen({
    super.key,
    required this.jobId,
  });

  @override
  ConsumerState<DeliveryTrackingScreen> createState() =>
      _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState
    extends ConsumerState<DeliveryTrackingScreen> {
  bool _isLoading = true;
  DeliveryJobModel? _job;
  Timer? _refreshTimer;
  double? _driverLat;
  double? _driverLng;
  double? _heading;
  double? _speedMps;
  String? _lastSyncedEventAt;
  bool _isReconnecting = false;

  @override
  void initState() {
    super.initState();
    _loadJob();
    // 3-5s tracking sync with reconnect and missed-event sync handling
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _syncLiveTracking();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadJob() async {
    try {
      final job = await ref
          .read(apiClientProvider)
          .getCustomerDeliveryTracking(widget.jobId);
      if (mounted) {
        setState(() {
          _job = job;
          _isLoading = false;
          _isReconnecting = false;
          final live = job.assignedPartner?.liveLocation;
          if (live != null) {
            _driverLat = live.latitude;
            _driverLng = live.longitude;
            _heading = live.heading;
            _speedMps = live.speedMps;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isReconnecting = true;
        });
      }
    }
  }

  Future<void> _syncLiveTracking() async {
    try {
      final syncResult = await ref
          .read(apiClientProvider)
          .syncMissedDeliveryEvents(widget.jobId, since: _lastSyncedEventAt);

      if (mounted && syncResult['syncedAt'] != null) {
        _lastSyncedEventAt = syncResult['syncedAt']?.toString();
        final current = syncResult['currentSnapshot'] as Map<String, dynamic>?;
        if (current != null) {
          final live = current['assignedPartner']?['liveLocation'] as Map<String, dynamic>?;
          setState(() {
            _isReconnecting = false;
            if (live != null) {
              _driverLat = (live['latitude'] as num?)?.toDouble() ?? _driverLat;
              _driverLng = (live['longitude'] as num?)?.toDouble() ?? _driverLng;
              _heading = (live['heading'] as num?)?.toDouble() ?? _heading;
              _speedMps = (live['speedMps'] as num?)?.toDouble() ?? _speedMps;
            }
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isReconnecting = true);
        _loadJob();
      }
    }
  }

  void _snapCameraToDriver() {
    if (_driverLat == null || _driverLng == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Camera centered on courier: ${_driverLat!.toStringAsFixed(4)}, ${_driverLng!.toStringAsFixed(4)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
        actions: [
          if (_isReconnecting)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                ),
              ),
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadJob),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
              ? const Center(child: Text('Delivery job details not found'))
              : Stack(
                  children: [
                    // Live Map Viewport
                    Positioned.fill(
                      child: Container(
                        color: Colors.blue.shade50,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map, size: 72, color: Colors.blue),
                              const SizedBox(height: 12),
                              Text(
                                'Live Map Viewport & Route Polyline',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _driverLat != null
                                    ? 'Live Courier Coordinates: ${_driverLat!.toStringAsFixed(4)}, ${_driverLng!.toStringAsFixed(4)}'
                                    : 'Awaiting courier location ping...',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                              ),
                              if (_isReconnecting)
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Reconnecting to live telemetry stream...',
                                    style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Persistent Bottom Sheet
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LiveTripTrackingBottomSheet(
                        status: _job!.status,
                        pickupAddress: _job!.pickupAddress,
                        dropoffAddress: _job!.destinationAddress,
                        deliveryOtp: _job!.deliveryPin,
                        driverLatitude: _driverLat,
                        driverLongitude: _driverLng,
                        driverHeading: _heading,
                        driverSpeedMps: _speedMps,
                        onSnapCameraToDriver: _snapCameraToDriver,
                      ),
                    ),
                  ],
                ),
    );
  }
}
