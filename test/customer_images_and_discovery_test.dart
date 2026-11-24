import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'package:allgo_customer_mobile/src/widgets/veg_badge.dart';
import 'package:allgo_customer_mobile/src/components/customer_product_card.dart';
import 'package:allgo_customer_mobile/src/components/home_banner_carousel.dart';
import 'package:allgo_customer_mobile/src/components/home_category_chips.dart';
import 'package:allgo_customer_mobile/src/components/search_filter_bottom_sheet.dart';

void main() {
  group('Customer Images & Discovery Tests (Phase 3)', () {
    testWidgets('VegNonVegBadge renders vegetarian and non-vegetarian semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                VegNonVegBadge(isVeg: true),
                VegNonVegBadge(isVeg: false),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(VegNonVegBadge), findsNWidgets(2));
    });

    testWidgets('CustomerProductCard renders product information, price and ADD button', (tester) async {
      const product = ProductItem(
        id: 'p-1',
        categoryId: 'c-1',
        categoryName: 'Biryani',
        name: 'Hyderabadi Chicken Biryani',
        description: 'Authentic dum biryani served with mirchi ka salan and raita.',
        basePriceInr: 350.0,
        salePriceInr: 280.0,
        effectivePriceInr: 280.0,
        isVeg: false,
        isPerishable: true,
        preparationTimeMinutes: 25,
        stockQuantity: 20,
        isInStock: true,
        lowStockThreshold: 5,
      );

      bool addPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerProductCard(
              product: product,
              onAdd: () => addPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Hyderabadi Chicken Biryani'), findsOneWidget);
      expect(find.text('₹280'), findsOneWidget);
      expect(find.text('₹350'), findsOneWidget);
      expect(find.text('20% OFF'), findsOneWidget);
      expect(find.text('ADD'), findsOneWidget);

      await tester.tap(find.text('ADD'));
      expect(addPressed, isTrue);
    });

    testWidgets('CustomerProductCard renders quantity stepper when quantity > 0', (tester) async {
      const product = ProductItem(
        id: 'p-1',
        categoryId: 'c-1',
        categoryName: 'Biryani',
        name: 'Veg Dum Biryani',
        basePriceInr: 220.0,
        effectivePriceInr: 220.0,
        isVeg: true,
        isPerishable: true,
        preparationTimeMinutes: 20,
        stockQuantity: 15,
        isInStock: true,
        lowStockThreshold: 3,
      );

      int count = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerProductCard(
              product: product,
              quantity: count,
              onAdd: () => count++,
              onDecrement: () => count--,
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('HomeCategoryChips renders chips and triggers onSelectCategory', (tester) async {
      String selected = 'ALL';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeCategoryChips(
              selectedCategory: selected,
              onSelectCategory: (cat) => selected = cat,
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Grocery'), findsOneWidget);

      await tester.tap(find.text('Food'));
      expect(selected, 'FOOD');
    });

    testWidgets('SearchFilterBottomSheet renders filter options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchFilterBottomSheet(
              initialFilters: const SearchFilters(),
              onApply: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Filter & Sort'), findsOneWidget);
      expect(find.text('Veg Only'), findsOneWidget);
      expect(find.text('Rating 4.0+'), findsOneWidget);
      expect(find.text('Under 30 Mins'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });
  });
}
