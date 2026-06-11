import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pos_models.dart';
import 'pos_controller.dart';
import 'pos_products_provider.dart';

/// Cart-only slice — product catalog widgets should not watch full [PosState].
final posCartProvider = Provider<List<PosCartItem>>((ref) {
  return ref.watch(posControllerProvider.select((s) => s.cart));
});

final posCartItemCountProvider = Provider<int>((ref) {
  return ref.watch(posCartProvider).length;
});

final posCartQtyByIdProvider = Provider<Map<String, int>>((ref) {
  final cart = ref.watch(posCartProvider);
  return {for (final i in cart) i.productId: i.quantity};
});

/// Alias for catalog — decoupled from cart mutations.
final productCatalogProvider = posProductsProvider;
