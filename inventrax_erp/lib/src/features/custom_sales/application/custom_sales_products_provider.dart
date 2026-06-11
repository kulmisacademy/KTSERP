import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';

final customSalesSearchProvider =
    NotifierProvider<CustomSalesSearchNotifier, String>(
  CustomSalesSearchNotifier.new,
);

class CustomSalesSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final customSalesProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final query = ref.watch(customSalesSearchProvider);

  await Future<void>.delayed(const Duration(milliseconds: 180));
  if (ref.read(customSalesSearchProvider) != query) {
    throw StateError('stale');
  }

  return db.searchProductsForPos(
    storeId: StoreContext.storeId,
    query: query,
    limit: 40,
  );
});
