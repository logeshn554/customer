import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../components/map_grid_canvas.dart';

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

class MapCoordinatePickerModal extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const MapCoordinatePickerModal({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<MapCoordinatePickerModal> createState() => _MapCoordinatePickerModalState();
}

class _MapCoordinatePickerModalState extends State<MapCoordinatePickerModal> {
  late double _currentLat;
  late double _currentLng;
  String _selectedLocality = 'Anna Nagar, Chennai';

  static const List<Map<String, dynamic>> _quickLocations = [
    {'name': 'Anna Nagar, Chennai', 'lat': 13.0850, 'lng': 80.2101},
    {'name': 'T. Nagar, Chennai', 'lat': 13.0418, 'lng': 80.2341},
    {'name': 'Adyar, Chennai', 'lat': 13.0067, 'lng': 80.2570},
    {'name': 'Velachery, Chennai', 'lat': 12.9815, 'lng': 80.2180},
    {'name': 'OMR IT Corridor', 'lat': 12.9249, 'lng': 80.2290},
  ];

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;
  }

  void _adjustCoordinates(double dLat, double dLng) {
    setState(() {
      _currentLat = double.parse((_currentLat + dLat).toStringAsFixed(5));
      _currentLng = double.parse((_currentLng + dLng).toStringAsFixed(5));
      _selectedLocality = 'Custom Pin Location';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AllGoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pin Delivery Location', style: AllGoTypography.heading3),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: MapGridCanvas(
              currentLat: _currentLat,
              currentLng: _currentLng,
              locality: _selectedLocality,
              onAdjust: _adjustCoordinates,
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickLocations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final loc = _quickLocations[i];
                return ActionChip(
                  avatar: const Icon(Icons.near_me, size: 14),
                  label: Text(loc['name'] as String, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    setState(() {
                      _currentLat = loc['lat'] as double;
                      _currentLng = loc['lng'] as double;
                      _selectedLocality = loc['name'] as String;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Selected GPS Lat/Lng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '${_currentLat.toStringAsFixed(5)}, ${_currentLng.toStringAsFixed(5)}',
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AllGoColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AllGoButton(
                  label: 'Confirm Selected Location',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MapLocationResult(
                        latitude: _currentLat,
                        longitude: _currentLng,
                        addressText: _selectedLocality,
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
