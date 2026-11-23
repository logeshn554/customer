import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

import '../components/parcel_spec_and_address_cards.dart';
import '../components/parcel_active_tracking_card.dart';
import '../components/parcel_history_view.dart';

class ParcelSendScreen extends ConsumerStatefulWidget {
  final String? activeParcelId;

  const ParcelSendScreen({super.key, this.activeParcelId});

  @override
  ConsumerState<ParcelSendScreen> createState() => _ParcelSendScreenState();
}

class _ParcelSendScreenState extends ConsumerState<ParcelSendScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _senderNameCtrl = TextEditingController(text: 'Ramesh Kumar');
  final _senderPhoneCtrl = TextEditingController(text: '+919876543210');
  final _pickupAddressCtrl = TextEditingController(text: 'Flat 4A, Green Garden Apts, Anna Nagar');
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _dropoffAddressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

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
    if (widget.activeParcelId != null) {
      _loadActiveParcel(widget.activeParcelId!);
    }
    _loadHistory();
    _startPolling();
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
        'pickupLatitude': 13.0827,
        'pickupLongitude': 80.2707,
        'dropoffLatitude': 13.0405,
        'dropoffLongitude': 80.2337,
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
        'pickupLatitude': 13.0827,
        'pickupLongitude': 80.2707,
        'recipientName': _recipientNameCtrl.text,
        'recipientPhone': _recipientPhoneCtrl.text,
        'dropoffAddress': _dropoffAddressCtrl.text,
        'dropoffLatitude': 13.0405,
        'dropoffLongitude': 80.2337,
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
                onSelectService: (s) => setState(() => _selectedServiceCode = s),
                senderNameCtrl: _senderNameCtrl,
                senderPhoneCtrl: _senderPhoneCtrl,
                pickupAddressCtrl: _pickupAddressCtrl,
                recipientNameCtrl: _recipientNameCtrl,
                recipientPhoneCtrl: _recipientPhoneCtrl,
                dropoffAddressCtrl: _dropoffAddressCtrl,
                descriptionCtrl: _descriptionCtrl,
                selectedCategory: _selectedCategory,
                onSelectCategory: (c) => setState(() => _selectedCategory = c),
                weightKg: _weightKg,
                onWeightChanged: (w) => setState(() => _weightKg = w),
                quote: _quote,
                isQuoting: _isQuoting,
                onGetQuote: _handleGetQuote,
              ),
              if (_quote != null) ...[
                const SizedBox(height: 16),
                AllGoButton(
                  label: 'Book Courier Handover',
                  isLoading: _isBooking,
                  onPressed: _handleBookParcel,
                ),
              ],
            ],
          ),
          _activeParcel != null
              ? ParcelActiveTrackingCard(
                  parcel: _activeParcel!,
                  isCancelling: _isCancelling,
                  onCancel: _handleCancelParcel,
                  onRefresh: () => _loadActiveParcel(_activeParcel!.id),
                )
              : ParcelHistoryView(
                  parcels: _history,
                  isLoading: _isLoadingHistory,
                  onRefresh: _loadHistory,
                  onSelect: (p) => setState(() => _activeParcel = p),
                ),
        ],
      ),
    );
  }
}
