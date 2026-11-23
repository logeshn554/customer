import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
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
    _mapController?.dispose();
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
        _snapCameraToDriver();
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
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(_driverLat!, _driverLng!), 16.0),
    );
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};
    if (_driverLat != null && _driverLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('courier_partner'),
          position: LatLng(_driverLat!, _driverLng!),
          rotation: _heading ?? 0.0,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: _job?.assignedPartner?.name ?? 'Delivery Partner',
            snippet: _speedMps != null ? 'Speed: ${(_speedMps! * 3.6).toStringAsFixed(1)} km/h' : 'En route',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }
    return markers;
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
                    // Live Google Maps Viewport
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_driverLat ?? 13.0827, _driverLng ?? 80.2707),
                          zoom: 15.5,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: true,
                        markers: _buildMapMarkers(),
                        onMapCreated: (ctrl) {
                          _mapController = ctrl;
                          _snapCameraToDriver();
                        },
                      ),
                    ),

                    // Reconnecting banner overlay
                    if (_isReconnecting)
                      Positioned(
                        top: 12,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade800,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 8),
                              Text('Reconnecting to live telemetry stream...', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
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
