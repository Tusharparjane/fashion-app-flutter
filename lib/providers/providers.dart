import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/mock_data.dart';

// ── Products ──────────────────────────────────────────────────────────────────

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final productsProvider = Provider<List<Product>>((ref) => MockData.products);

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final products = ref.watch(productsProvider);
  if (category == 'All') return products;
  return products.where((p) => p.category == category).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<Product>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return MockData.products;
  return MockData.products
      .where(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query),
      )
      .toList();
});

// ── Favourites ────────────────────────────────────────────────────────────────

class FavouritesNotifier extends StateNotifier<Set<String>> {
  FavouritesNotifier() : super({'1'}); // product id '1' pre-favourited

  void toggle(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  bool isFavourite(String productId) => state.contains(productId);
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, Set<String>>(
      (ref) => FavouritesNotifier(),
    );

final favouriteProductsProvider = Provider<List<Product>>((ref) {
  final ids = ref.watch(favouritesProvider);
  return MockData.products.where((p) => ids.contains(p.id)).toList();
});

// ── Cart ──────────────────────────────────────────────────────────────────────

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product, String size, String color) {
    final idx = state.indexWhere(
      (i) => i.product.id == product.id && i.size == size && i.color == color,
    );
    if (idx >= 0) {
      final updated = [...state];
      updated[idx].quantity++;
      state = updated;
    } else {
      state = [...state, CartItem(product: product, size: size, color: color)];
    }
  }

  void removeItem(int index) {
    final updated = [...state];
    updated.removeAt(index);
    state = updated;
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    final updated = [...state];
    updated[index].quantity = quantity;
    state = updated;
  }

  void clear() => state = [];

  double get subtotal => state.fold(0, (sum, i) => sum + i.total);
  double get shipping => state.isEmpty ? 0 : 12.0;
  double get total => subtotal + shipping;
  int get itemCount => state.fold(0, (sum, i) => sum + i.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.subtotal;
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.total;
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider.notifier);
  ref.watch(cartProvider);
  return cart.itemCount;
});

// ── Orders ────────────────────────────────────────────────────────────────────

final ordersProvider = Provider<List<Order>>((ref) => MockData.orders);

// ── Selected product detail ────────────────────────────────────────────────

final selectedSizeProvider = StateProvider.family<String, String>((
  ref,
  productId,
) {
  final product = MockData.products.firstWhere((p) => p.id == productId);
  return product.sizes.first;
});

final selectedColorProvider = StateProvider.family<String, String>((
  ref,
  productId,
) {
  final product = MockData.products.firstWhere((p) => p.id == productId);
  return product.colors.first;
});
