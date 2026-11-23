import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../components/address_card_item.dart';
import 'address_editor_dialog.dart';

class SavedAddressesScreen extends ConsumerStatefulWidget {
  final bool selectMode;
  final ValueChanged<CustomerAddressModel>? onSelect;

  const SavedAddressesScreen({
    super.key,
    this.selectMode = false,
    this.onSelect,
  });

  @override
  ConsumerState<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends ConsumerState<SavedAddressesScreen> {
  List<CustomerAddressModel> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await ref.read(apiClientProvider).listCustomerAddresses();
      if (mounted) {
        setState(() {
          _addresses = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSetDefault(CustomerAddressModel address) async {
    try {
      final updated = await ref.read(apiClientProvider).setDefaultCustomerAddress(address.id);
      if (mounted) {
        setState(() {
          _addresses = _addresses.map((a) => a.copyWith(isDefault: a.id == updated.id)).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Default address set to "${address.label}"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set default: $e'), backgroundColor: AllGoColors.error),
        );
      }
    }
  }

  Future<void> _handleDelete(CustomerAddressModel address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(apiClientProvider).deleteCustomerAddress(address.id);
        if (mounted) {
          setState(() {
            _addresses.removeWhere((a) => a.id == address.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AllGoColors.error),
          );
        }
      }
    }
  }

  void _openEditor({CustomerAddressModel? address}) async {
    final result = await showDialog<CustomerAddressModel>(
      context: context,
      builder: (ctx) => AddressEditorDialog(existingAddress: address),
    );

    if (result != null) {
      await _loadAddresses();
      if (widget.selectMode && widget.onSelect != null && mounted) {
        widget.onSelect!(result);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AllGoAppBar(
        title: widget.selectMode ? 'Select Delivery Address' : 'Saved Addresses',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Address',
            onPressed: () => _openEditor(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage', style: AllGoTypography.bodyMedium),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadAddresses, child: const Text('Retry')),
                    ],
                  ),
                )
              : _addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off_outlined, size: 64, color: AllGoColors.textTertiary),
                          const SizedBox(height: 16),
                          Text('No saved addresses yet', style: AllGoTypography.heading3),
                          const SizedBox(height: 8),
                          Text('Add your home or work address for quick checkout', style: AllGoTypography.caption),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text('Add Address'),
                            onPressed: () => _openEditor(),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final addr = _addresses[index];
                        return AddressCardItem(
                          address: addr,
                          selectMode: widget.selectMode,
                          onSelect: widget.onSelect,
                          onEdit: () => _openEditor(address: addr),
                          onSetDefault: () => _handleSetDefault(addr),
                          onDelete: () => _handleDelete(addr),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AllGoColors.primary,
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Add New Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
