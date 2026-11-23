import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class MapLocationResult {
  final double latitude;
  final double longitude;
  final String addressText;

  const MapLocationResult({
    required this.latitude,
    required this.longitude,
    required this.addressText,
  });
}

class MapCoordinatePickerModal extends ConsumerStatefulWidget {
  final double initialLat;
  final double initialLng;

  const MapCoordinatePickerModal({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  ConsumerState<MapCoordinatePickerModal> createState() => _MapCoordinatePickerModalState();
}

class _MapCoordinatePickerModalState extends ConsumerState<MapCoordinatePickerModal> {
  GoogleMapController? _mapController;
  late double _currentLat;
  late double _currentLng;
  String _currentAddress = 'Detecting address...';
  bool _isReverseGeocoding = false;
  bool _isLocatingUser = false;

  final TextEditingController _searchController = TextEditingController();
  List<PlacePredictionModel> _placePredictions = [];
  bool _isSearchingPlaces = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;
    _fetchAddressForCoordinates(_currentLat, _currentLng);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchAddressForCoordinates(double lat, double lng) async {
    if (!mounted) return;
    setState(() => _isReverseGeocoding = true);
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.reverseGeocode(lat, lng);
      if (mounted) {
        setState(() {
          _currentAddress = res.formattedAddress;
          _isReverseGeocoding = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentAddress = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
          _isReverseGeocoding = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _placePredictions = [];
        _isSearchingPlaces = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _isSearchingPlaces = true);
      try {
        final client = ref.read(apiClientProvider);
        final predictions = await client.searchPlaces(
          query.trim(),
          lat: _currentLat,
          lng: _currentLng,
        );
        if (mounted) {
          setState(() {
            _placePredictions = predictions;
            _isSearchingPlaces = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearchingPlaces = false);
      }
    });
  }

  Future<void> _selectPlacePrediction(PlacePredictionModel prediction) async {
    setState(() {
      _searchController.text = prediction.mainText;
      _placePredictions = [];
      _isSearchingPlaces = true;
    });

    try {
      final client = ref.read(apiClientProvider);
      final results = await client.geocodeAddress(prediction.description);
      if (results.isNotEmpty && mounted) {
        final target = results.first;
        _currentLat = target.latitude;
        _currentLng = target.longitude;
        _currentAddress = target.formattedAddress.isNotEmpty ? target.formattedAddress : prediction.description;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(_currentLat, _currentLng), 16.5),
        );
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isSearchingPlaces = false);
    }
  }

  Future<void> _locateCurrentGpsPosition() async {
    setState(() => _isLocatingUser = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
        if (mounted) {
          _currentLat = pos.latitude;
          _currentLng = pos.longitude;
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(_currentLat, _currentLng), 17.0),
          );
          await _fetchAddressForCoordinates(_currentLat, _currentLng);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required to detect GPS position.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not obtain GPS location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocatingUser = false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentLat = position.target.latitude;
    _currentLng = position.target.longitude;
  }

  void _onCameraIdle() {
    _fetchAddressForCoordinates(_currentLat, _currentLng);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Confirm Delivery Location', style: AllGoTypography.heading3),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // Google Places Autocomplete Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search area, landmark, or apartment...',
                prefixIcon: const Icon(Icons.search, color: AllGoColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // Search predictions overlay
          if (_placePredictions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _placePredictions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final p = _placePredictions[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, color: AllGoColors.primary, size: 20),
                    title: Text(p.mainText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(p.secondaryText, style: const TextStyle(fontSize: 11)),
                    onTap: () => _selectPlacePrediction(p),
                  );
                },
              ),
            ),

          // Interactive Map Area with Centered Pin
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentLat, _currentLng),
                    zoom: 16.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                ),

                // Center Pin Marker
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Order will be delivered here',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.location_pin, size: 44, color: AllGoColors.primary),
                      ],
                    ),
                  ),
                ),

                // Locate Me Button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'map_locate_me',
                    backgroundColor: Colors.white,
                    onPressed: _locateCurrentGpsPosition,
                    child: _isLocatingUser
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location, color: AllGoColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Address Bar & Confirmation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: AllGoColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delivery Address', style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          _isReverseGeocoding
                              ? const Text('Fetching exact street address...', style: TextStyle(color: Colors.grey, fontSize: 13))
                              : Text(
                                  _currentAddress,
                                  style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          const SizedBox(height: 2),
                          Text(
                            'GPS: ${_currentLat.toStringAsFixed(5)}, ${_currentLng.toStringAsFixed(5)}',
                            style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AllGoButton(
                  label: 'Confirm Pin Location',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MapLocationResult(
                        latitude: _currentLat,
                        longitude: _currentLng,
                        addressText: _currentAddress,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
