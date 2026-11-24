import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../common/friendly_error.dart';
import '../components/address_form_fields.dart';
import 'map_coordinate_picker_modal.dart';

class AddressEditorDialog extends ConsumerStatefulWidget {
  final CustomerAddressModel? existingAddress;

  const AddressEditorDialog({super.key, this.existingAddress});

  @override
  ConsumerState<AddressEditorDialog> createState() => _AddressEditorDialogState();
}

class _AddressEditorDialogState extends ConsumerState<AddressEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _label;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _line1Ctrl;
  late TextEditingController _line2Ctrl;
  late TextEditingController _landmarkCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _postalCtrl;
  late double _latitude;
  late double _longitude;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.existingAddress;
    _label = addr?.label ?? 'HOME';
    _nameCtrl = TextEditingController(text: addr?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: addr?.recipientPhone ?? '');
    _line1Ctrl = TextEditingController(text: addr?.addressLine1 ?? '');
    _line2Ctrl = TextEditingController(text: addr?.addressLine2 ?? '');
    _landmarkCtrl = TextEditingController(text: addr?.landmark ?? '');
    _cityCtrl = TextEditingController(text: addr?.city ?? '');
    _postalCtrl = TextEditingController(text: addr?.postalCode ?? '');
    _latitude = addr?.latitude ?? 0.0;
    _longitude = addr?.longitude ?? 0.0;
    _isDefault = addr?.isDefault ?? false;

    if (addr == null) {
      _detectGpsLocation();
    }
  }

  Future<void> _detectGpsLocation() async {
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
          setState(() {
            _latitude = pos.latitude;
            _longitude = pos.longitude;
          });
          _reverseGeocode(pos.latitude, pos.longitude);
        }
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.reverseGeocode(lat, lng);
      if (mounted) {
        setState(() {
          if (_line1Ctrl.text.isEmpty && res.formattedAddress.isNotEmpty) {
            _line1Ctrl.text = res.formattedAddress;
          }
        });
      }
    } catch (e, st) {
      FriendlyError.from(e, st);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final picked = await showModalBottomSheet<MapLocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapCoordinatePickerModal(
        initialLat: _latitude,
        initialLng: _longitude,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _latitude = picked.latitude;
        _longitude = picked.longitude;
        if (picked.addressText.isNotEmpty && _line1Ctrl.text.isEmpty) {
          _line1Ctrl.text = picked.addressText;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final client = ref.read(apiClientProvider);
      final model = CustomerAddressModel(
        id: widget.existingAddress?.id ?? '',
        label: _label,
        recipientName: _nameCtrl.text.trim(),
        recipientPhone: _phoneCtrl.text.trim(),
        addressLine1: _line1Ctrl.text.trim(),
        addressLine2: _line2Ctrl.text.trim().isEmpty ? null : _line2Ctrl.text.trim(),
        landmark: _landmarkCtrl.text.trim().isEmpty ? null : _landmarkCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: 'Tamil Nadu',
        postalCode: _postalCtrl.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        isDefault: _isDefault,
      );

      final result = widget.existingAddress == null
          ? await client.createCustomerAddress(model)
          : await client.updateCustomerAddress(widget.existingAddress!.id, model);

      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e'), backgroundColor: AllGoColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEditing ? 'Edit Address' : 'Add New Address', style: AllGoTypography.heading3),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    Text('Address Type', style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['HOME', 'WORK', 'OTHER'].map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tag),
                            selected: _label == tag,
                            onSelected: (_) => setState(() => _label = tag),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    AddressFormFields(
                      nameCtrl: _nameCtrl,
                      phoneCtrl: _phoneCtrl,
                      line1Ctrl: _line1Ctrl,
                      line2Ctrl: _line2Ctrl,
                      landmarkCtrl: _landmarkCtrl,
                      cityCtrl: _cityCtrl,
                      postalCtrl: _postalCtrl,
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _openMapPicker,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AllGoColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AllGoColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.pin_drop, color: AllGoColors.primary, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pin GPS Location on Map',
                                    style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AllGoColors.primary),
                                  ),
                                  Text('Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}', style: AllGoTypography.caption),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AllGoColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Set as default delivery address'),
                      value: _isDefault,
                      onChanged: (val) => setState(() => _isDefault = val ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AllGoButton(
                label: isEditing ? 'Save Changes' : 'Add Address',
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
