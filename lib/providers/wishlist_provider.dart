import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class WishlistNotifier extends StateNotifier<List<Product>> {
  WishlistNotifier() : super([]);

  void toggleWishlist(Product product) {
    if (state.contains(product)) {
      state = state.where((item) => item.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  bool isInWishlist(Product product) {
    return state.contains(product);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<Product>>((ref) {
  return WishlistNotifier();
});
