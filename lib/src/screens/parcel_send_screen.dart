import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/parcel_spec_and_address_cards.dart';
import '../components/parcel_active_tracking_card.dart';
import '../components/parcel_history_view.dart';
import 'map_coordinate_picker_modal.dart';

class ParcelSendScreen extends ConsumerStatefulWidget {
  final String? activeParcelId;

  const ParcelSendScreen({super.key, this.activeParcelId});

  @override
  ConsumerState<ParcelSendScreen> createState() => _ParcelSendScreenState();
}

class _ParcelSendScreenState extends ConsumerState<ParcelSendScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _senderNameCtrl;
  late TextEditingController _senderPhoneCtrl;
  final _pickupAddressCtrl = TextEditingController(text: 'Current Location');
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _dropoffAddressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  double _pickupLat = 13.0827;
  double _pickupLng = 80.2707;
  double _dropoffLat = 13.0405;
  double _dropoffLng = 80.2337;

  String _selectedServiceCode = 'STANDARD';
  String _selectedCategory = 'DOCUMENTS';
  double _weightKg = 1.0;

  bool _isQuoting = false;
  bool _isBooking = false;
  bool _isCancelling = false;
  bool _isLoadingHistory = false;

  ParcelQuote? _quote;
  ParcelModel? _activeParcel;
  List<ParcelModel> _history = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final user = ref.read(currentUserProvider);
    _senderNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _senderPhoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');

    if (widget.activeParcelId != null) {
      _loadActiveParcel(widget.activeParcelId!);
    }
    _initPickupAddress();
    _loadHistory();
    _startPolling();
  }

  Future<void> _initPickupAddress() async {
    try {
      final addresses = await ref.read(apiClientProvider).listCustomerAddresses();
      if (addresses.isNotEmpty && mounted) {
        final def = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        _pickupAddressCtrl.text = '${def.addressLine1}, ${def.city}';
        _pickupLat = def.latitude;
        _pickupLng = def.longitude;
        return;
      }
    } catch (_) {}

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 4));
        if (mounted) {
          _pickupLat = pos.latitude;
          _pickupLng = pos.longitude;
          try {
            final rev = await ref.read(apiClientProvider).reverseGeocode(pos.latitude, pos.longitude);
            _pickupAddressCtrl.text = rev.formattedAddress;
          } catch (_) {
            _pickupAddressCtrl.text = 'Current GPS Location';
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    _senderNameCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _pickupAddressCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _dropoffAddressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_activeParcel != null && mounted) {
        _loadActiveParcel(_activeParcel!.id);
      }
    });
  }

  Future<void> _loadActiveParcel(String parcelId) async {
    try {
      final p = await ref.read(apiClientProvider).getParcelDetails(parcelId);
      if (mounted) setState(() => _activeParcel = p);
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final res = await ref.read(apiClientProvider).listCustomerParcels();
      if (mounted) setState(() => _history = res);
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _handleGetQuote() async {
    if (_recipientNameCtrl.text.isEmpty || _dropoffAddressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill recipient address & name')));
      return;
    }
    setState(() => _isQuoting = true);
    try {
      final quote = await ref.read(apiClientProvider).quoteParcel({
        'serviceLevel': _selectedServiceCode,
        'packageCategory': _selectedCategory,
        'weightKg': _weightKg,
        'pickupLatitude': _pickupLat,
        'pickupLongitude': _pickupLng,
        'dropoffLatitude': _dropoffLat,
        'dropoffLongitude': _dropoffLng,
      });
      if (mounted) setState(() => _quote = quote);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quote failed: $e')));
    } finally {
      if (mounted) setState(() => _isQuoting = false);
    }
  }

  Future<void> _handleBookParcel() async {
    if (_quote == null) return;
    setState(() => _isBooking = true);
    try {
      final p = await ref.read(apiClientProvider).createParcelBooking({
        'quoteId': _quote!.quoteId,
        'senderName': _senderNameCtrl.text,
        'senderPhone': _senderPhoneCtrl.text,
        'pickupAddress': _pickupAddressCtrl.text,
        'pickupLatitude': _pickupLat,
        'pickupLongitude': _pickupLng,
        'recipientName': _recipientNameCtrl.text,
        'recipientPhone': _recipientPhoneCtrl.text,
        'dropoffAddress': _dropoffAddressCtrl.text,
        'dropoffLatitude': _dropoffLat,
        'dropoffLongitude': _dropoffLng,
        'packageDescription': _descriptionCtrl.text,
      });
      if (mounted) {
        setState(() {
          _activeParcel = p;
          _quote = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Future<void> _handleCancelParcel() async {
    if (_activeParcel == null) return;
    setState(() => _isCancelling = true);
    try {
      final p = await ref.read(apiClientProvider).cancelParcelBooking(_activeParcel!.id, reason: 'Customer cancelled');
      if (mounted) setState(() => _activeParcel = p);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AppBar(
        title: const Text('City Parcel Delivery'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Send Package'), Tab(text: 'Active / History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ParcelSpecAndAddressCards(
                selectedServiceCode: _selectedServiceCode,
                selectedCategory: _selectedCategory,
                weightKg: _weightKg,
                senderNameCtrl: _senderNameCtrl,
                senderPhoneCtrl: _senderPhoneCtrl,
                pickupAddressCtrl: _pickupAddressCtrl,
                recipientNameCtrl: _recipientNameCtrl,
                recipientPhoneCtrl: _recipientPhoneCtrl,
                dropoffAddressCtrl: _dropoffAddressCtrl,
                descriptionCtrl: _descriptionCtrl,
                onSelectService: (s) => setState(() => _selectedServiceCode = s),
                onSelectCategory: (c) => setState(() => _selectedCategory = c),
                onWeightChanged: (w) => setState(() => _weightKg = w),
              ),
              const SizedBox(height: 16),
              AllGoButton(
                label: 'Get Cost & ETA Estimate',
                isLoading: _isQuoting,
                onPressed: _handleGetQuote,
              ),
              if (_quote != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.deepPurple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Fare Estimate:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('₹${_quote!.fareInr}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepPurple)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Distance: ${_quote!.distanceKm} km | Est. Delivery: ${_quote!.estimatedDurationMinutes} mins', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 16),
                        AllGoButton(
                          label: 'Confirm & Dispatch Porter',
                          isLoading: _isBooking,
                          onPressed: _handleBookParcel,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          _activeParcel != null
              ? ParcelActiveTrackingCard(
                  parcel: _activeParcel!,
                  isCancelling: _isCancelling,
                  onCancel: _handleCancelParcel,
                )
              : ParcelHistoryView(
                  isLoading: _isLoadingHistory,
                  history: _history,
                  onRefresh: _loadHistory,
                ),
        ],
      ),
    );
  }
}
