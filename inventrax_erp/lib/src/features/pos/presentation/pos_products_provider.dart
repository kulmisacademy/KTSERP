import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store/active_store_scope.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';

final posSearchProvider = NotifierProvider<_PosSearch, String>(_PosSearch.new);

class _PosSearch extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

/// Local SQLite search with debounce — no table stream, bounded results.
final posProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  final storeId = scope.storeId;
  final query = ref.watch(posSearchProvider);

  await Future<void>.delayed(const Duration(milliseconds: 200));

  return db.searchProductsForPos(
    storeId: storeId,
    query: query,
    limit: 60,
  );
});
