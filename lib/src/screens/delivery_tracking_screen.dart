import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../components/live_trip_tracking_bottom_sheet.dart';
import 'chat_with_driver_screen.dart';

class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  final String jobId;

  const DeliveryTrackingScreen({
    super.key,
    required this.jobId,
  });

  @override
  ConsumerState<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends ConsumerState<DeliveryTrackingScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  bool _isLoading = true;
  DeliveryJobModel? _job;
  Timer? _pollingTimer;
  int _backoffSeconds = 3;
  bool _isReconnecting = false;

  double? _driverLat;
  double? _driverLng;
  double? _heading;
  double? _speedMps;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadJob();
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pollingTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _backoffSeconds = 3;
      _startPolling();
      _loadJob();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer(Duration(seconds: _backoffSeconds), () async {
      if (mounted) {
        await _syncTracking();
        _startPolling();
      }
    });
  }

  Future<void> _loadJob() async {
    try {
      final job = await ref.read(apiClientProvider).getCustomerDeliveryTracking(widget.jobId);
      if (mounted) {
        setState(() {
          _job = job;
          _isLoading = false;
          _isReconnecting = false;
          _backoffSeconds = 3; // Reset on success
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
          _backoffSeconds = (_backoffSeconds * 2).clamp(3, 10); // Exponential backoff
        });
      }
    }
  }

  Future<void> _syncTracking() async {
    try {
      final syncResult = await ref.read(apiClientProvider).syncMissedDeliveryEvents(widget.jobId);
      if (mounted && syncResult['currentSnapshot'] != null) {
        final current = syncResult['currentSnapshot'] as Map<String, dynamic>;
        final live = current['assignedPartner']?['liveLocation'] as Map<String, dynamic>?;
        setState(() {
          _isReconnecting = false;
          _backoffSeconds = 3;
          if (live != null) {
            _driverLat = (live['latitude'] as num?)?.toDouble() ?? _driverLat;
            _driverLng = (live['longitude'] as num?)?.toDouble() ?? _driverLng;
            _heading = (live['heading'] as num?)?.toDouble() ?? _heading;
            _speedMps = (live['speedMps'] as num?)?.toDouble() ?? _speedMps;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isReconnecting = true;
          _backoffSeconds = (_backoffSeconds * 2).clamp(3, 10);
        });
      }
    }
  }

  void _snapCameraToDriver() {
    if (_driverLat == null || _driverLng == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(_driverLat!, _driverLng!), 16.0),
    );
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _shareTracking() {
    final orderNum = _job?.jobNumber ?? widget.jobId;
    Share.share('Track my AllGo delivery live for order #$orderNum: https://allgo.app/track/${widget.jobId}');
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};
    if (_driverLat != null && _driverLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('courier'),
          position: LatLng(_driverLat!, _driverLng!),
          rotation: _heading ?? 0.0,
          infoWindow: InfoWindow(title: _job?.assignedPartner?.name ?? 'Partner'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final partner = _job?.assignedPartner;

    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), tooltip: 'Share Tracking', onPressed: _shareTracking),
          IconButton(icon: const Icon(Icons.my_location), tooltip: 'Snap to driver', onPressed: _snapCameraToDriver),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
              ? const Center(child: Text('Delivery job details not found'))
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_driverLat ?? 13.0827, _driverLng ?? 80.2707),
                        zoom: 15.5,
                      ),
                      markers: _buildMapMarkers(),
                      onMapCreated: (ctrl) {
                        _mapController = ctrl;
                        _snapCameraToDriver();
                      },
                    ),
                    // ETA Chip on top
                    Positioned(
                      top: 14,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_bike, color: AllGoColors.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _isReconnecting ? 'Reconnecting...' : 'Estimated: 15-20 mins',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Quick Action Buttons (Call, Chat)
                    if (partner != null)
                      Positioned(
                        top: 14,
                        right: 16,
                        child: Row(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'chat_partner',
                              backgroundColor: Colors.white,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatWithDriverScreen(
                                      driverName: partner.name,
                                      driverPhone: partner.phone,
                                      orderId: widget.jobId,
                                    ),
                                  ),
                                );
                              },
                              child: const Icon(Icons.chat_bubble_outline, color: AllGoColors.primary),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton.small(
                              heroTag: 'call_partner',
                              backgroundColor: AllGoColors.primary,
                              onPressed: () => _callPhone(partner.phone),
                              child: const Icon(Icons.call, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    // Bottom Tracking Sheet
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
