import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../common/friendly_error.dart';
import '../components/customer_product_card.dart';
import '../components/product_customizer_modal.dart';
import '../components/store_header_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_retry_view.dart';
import 'cart_screen.dart';

class OutletCatalogScreen extends ConsumerStatefulWidget {
  final String outletId;
  final String outletName;
  final String? categoryName;

  const OutletCatalogScreen({
    super.key,
    required this.outletId,
    required this.outletName,
    this.categoryName,
  });

  @override
  ConsumerState<OutletCatalogScreen> createState() => _OutletCatalogScreenState();
}

class _OutletCatalogScreenState extends ConsumerState<OutletCatalogScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  bool _isTogglingFav = false;
  bool _vegOnly = false;
  String _selectedSort = 'POPULAR';
  String _selectedCategory = 'ALL';

  OutletOpenStatusModel? _outletStatus;
  List<ProductItem> _products = [];
  final TextEditingController _searchCtrl = TextEditingController();
  CartModel? _cart;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final favs = await ref.read(apiClientProvider).getFavoriteStores();
      if (mounted) setState(() => _isFavorite = favs.any((f) => f.id == widget.outletId));
    } catch (_) {}
  }

  Future<void> _handleToggleFavorite() async {
    setState(() => _isTogglingFav = true);
    try {
      final newStatus = await ref.read(apiClientProvider).toggleFavoriteStore(widget.outletId);
      if (mounted) {
        setState(() {
          _isFavorite = newStatus;
          _isTogglingFav = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e, st) {
      if (mounted) {
        setState(() => _isTogglingFav = false);
        final err = FriendlyError.from(e, st);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message)));
      }
    }
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final client = ref.read(apiClientProvider);
    try {
      final results = await Future.wait<dynamic>([
        client.getCustomerOutletStatus(widget.outletId),
        client.getCustomerOutletProducts(widget.outletId),
        client.getCart().catchError((_) => CartModel.empty()),
      ]);

      if (mounted) {
        final prodData = results[1] as Map<String, dynamic>;
        final items = (prodData['items'] as List<dynamic>?) ?? [];
        setState(() {
          _outletStatus = results[0] as OutletOpenStatusModel;
          _products = items.map((p) => ProductItem.fromJson(p as Map<String, dynamic>)).toList();
          _cart = results[2] as CartModel;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      if (mounted) {
        final err = FriendlyError.from(e, st);
        setState(() {
          _errorMessage = err.message;
          _isLoading = false;
        });
      }
    }
  }

  int _getItemQuantity(String productId) {
    if (_cart == null) return 0;
    final item = _cart!.items.where((i) => i.itemId == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  Future<void> _addToCart(ProductItem product, {List<String>? optionIds}) async {
    try {
      final updatedCart = await ref.read(apiClientProvider).addToCart(
        outletId: widget.outletId,
        productId: product.id,
        quantity: 1,
        selectedOptionIds: optionIds,
      );
      if (mounted) setState(() => _cart = updatedCart);
    } catch (e, st) {
      if (mounted) {
        final err = FriendlyError.from(e, st);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message)));
      }
    }
  }

  Future<void> _decrementItem(ProductItem product) async {
    final cartItem = _cart?.items.where((i) => i.itemId == product.id).firstOrNull;
    if (cartItem == null) return;
    try {
      final client = ref.read(apiClientProvider);
      final CartModel updatedCart;
      if (cartItem.quantity <= 1) {
        updatedCart = await client.removeCartItem(cartItem.id);
      } else {
        updatedCart = await client.updateCartItemQuantity(cartItem.id, cartItem.quantity - 1);
      }
      if (mounted) setState(() => _cart = updatedCart);
    } catch (e, st) {
      if (mounted) {
        final err = FriendlyError.from(e, st);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message)));
      }
    }
  }

  void _showCustomizer(ProductItem product) async {
    try {
      final groups = await ref.read(apiClientProvider).getProductOptionGroups(product.id);
      if (groups.isEmpty) {
        _addToCart(product);
        return;
      }
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ProductCustomizerModal(
          product: product,
          optionGroups: groups,
          onAddToCart: (qty, opts) => _addToCart(product, optionIds: opts),
        ),
      );
    } catch (_) {
      _addToCart(product);
    }
  }

  List<ProductItem> get _filteredProducts {
    var list = _products;
    if (_vegOnly) {
      list = list.where((p) => p.isVeg).toList();
    }
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) =>
        p.name.toLowerCase().contains(query) ||
        (p.description != null && p.description!.toLowerCase().contains(query))
      ).toList();
    }
    if (_selectedCategory != 'ALL') {
      list = list.where((p) => p.categoryName.toUpperCase() == _selectedCategory).toList();
    }
    if (_selectedSort == 'PRICE_LOW') {
      list.sort((a, b) => a.effectivePriceInr.compareTo(b.effectivePriceInr));
    } else if (_selectedSort == 'PRICE_HIGH') {
      list.sort((a, b) => b.effectivePriceInr.compareTo(a.effectivePriceInr));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.outletName),
        actions: [
          IconButton(
            icon: Badge.count(
              count: _cart?.items.length ?? 0,
              isLabelVisible: (_cart?.items.isNotEmpty ?? false),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            tooltip: 'View Cart',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ErrorRetryView.fromException(exception: _errorMessage!, onRetry: _loadAll)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          StoreHeaderCard(
                            outletName: widget.outletName,
                            categoryName: widget.categoryName,
                            outletStatus: _outletStatus,
                            isFavorite: _isFavorite,
                            isTogglingFav: _isTogglingFav,
                            onToggleFav: _handleToggleFavorite,
                          ),
                          _buildFilterBar(),
                          const SizedBox(height: 8),
                          if (_filteredProducts.isEmpty)
                            const EmptyStateView(
                              icon: Icons.search_off,
                              title: 'No products match your filter',
                              message: 'Try searching for another dish or turn off Veg Only filter.',
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: _filteredProducts.map((p) {
                                  return CustomerProductCard(
                                    product: p,
                                    quantity: _getItemQuantity(p.id),
                                    onAdd: () => _showCustomizer(p),
                                    onDecrement: () => _decrementItem(p),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomSheet: (_cart != null && _cart!.items.isNotEmpty)
          ? _buildCartBottomBar()
          : null,
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search in store menu...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchCtrl.clear()))
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: const Text('Veg Only', style: TextStyle(fontSize: 12)),
                selected: _vegOnly,
                onSelected: (val) => setState(() => _vegOnly = val),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Price: Low to High', style: TextStyle(fontSize: 12)),
                selected: _selectedSort == 'PRICE_LOW',
                onSelected: (val) => setState(() => _selectedSort = val ? 'PRICE_LOW' : 'POPULAR'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AllGoColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_cart!.items.length} item(s) in Cart',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AllGoColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            child: const Text('VIEW CART', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
