import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store/active_store_scope.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/product_search.dart';

enum ProductCatalogFilter { all, lowStock, outOfStock }

class _ProductQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final productQueryProvider = NotifierProvider<_ProductQuery, String>(
  _ProductQuery.new,
);

class _ProductCatalogFilterNotifier extends Notifier<ProductCatalogFilter> {
  @override
  ProductCatalogFilter build() => ProductCatalogFilter.all;

  void set(ProductCatalogFilter value) => state = value;
}

final productCatalogFilterProvider =
    NotifierProvider<_ProductCatalogFilterNotifier, ProductCatalogFilter>(
  _ProductCatalogFilterNotifier.new,
);

class _BrandFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? brandId) => state = brandId;
}

final productBrandFilterProvider = NotifierProvider<_BrandFilter, String?>(
  _BrandFilter.new,
);

class ProductCatalogState {
  const ProductCatalogState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<Product> items;
  final ProductPageCursor? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;
}

final productCatalogProvider =
    AsyncNotifierProvider.autoDispose<ProductCatalogNotifier, ProductCatalogState>(
  ProductCatalogNotifier.new,
);

final productInventoryStatsProvider =
    FutureProvider.autoDispose<ProductInventoryCounts>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.productInventoryCounts(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
  );
});

class ProductCatalogNotifier extends AsyncNotifier<ProductCatalogState> {
  @override
  Future<ProductCatalogState> build() async {
    ref.watch(activeStoreScopeProvider);
    ref.listen(productQueryProvider, (_, __) => ref.invalidateSelf());
    ref.listen(productBrandFilterProvider, (_, __) => ref.invalidateSelf());
    ref.listen(productCatalogFilterProvider, (_, __) => ref.invalidateSelf());

    final query = ref.read(productQueryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final page = await _fetchFirstPage(query);
    return ProductCatalogState(
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }

  ProductListFilter _listFilter(ProductCatalogFilter filter) =>
      switch (filter) {
        ProductCatalogFilter.all => ProductListFilter.all,
        ProductCatalogFilter.lowStock => ProductListFilter.lowStock,
        ProductCatalogFilter.outOfStock => ProductListFilter.outOfStock,
      };

  Future<ProductSearchPage> _fetchFirstPage(String query) {
    final scope = ref.read(activeStoreScopeProvider);
    final db = ref.read(appDatabaseProvider);
    return db.fetchProductPage(
      storeId: scope.storeId,
      query: query,
      brandId: ref.read(productBrandFilterProvider),
      filter: _listFilter(ref.read(productCatalogFilterProvider)),
      limit: 48,
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      ProductCatalogState(
        items: current.items,
        nextCursor: current.nextCursor,
        isLoadingMore: true,
      ),
    );

    try {
      final scope = ref.read(activeStoreScopeProvider);
      final db = ref.read(appDatabaseProvider);
      final page = await db.fetchProductPage(
        storeId: scope.storeId,
        query: ref.read(productQueryProvider),
        brandId: ref.read(productBrandFilterProvider),
        filter: _listFilter(ref.read(productCatalogFilterProvider)),
        cursor: current.nextCursor,
        limit: 48,
      );
      state = AsyncData(
        ProductCatalogState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
