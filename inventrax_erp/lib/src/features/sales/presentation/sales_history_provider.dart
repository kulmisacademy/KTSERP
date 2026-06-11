import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/sales_search.dart';
import '../../../observability/system_health_providers.dart';

class SalesHistoryQuery {
  const SalesHistoryQuery({
    this.search = '',
    this.paymentFilter = SalesPaymentFilter.all,
    this.datePreset = SalesDatePreset.month,
    this.customFrom,
    this.customTo,
  });

  final String search;
  final SalesPaymentFilter paymentFilter;
  final SalesDatePreset datePreset;
  final DateTime? customFrom;
  final DateTime? customTo;

  (DateTime from, DateTime to) resolveRange() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return switch (datePreset) {
      SalesDatePreset.today => (
          startOfToday,
          startOfToday.add(const Duration(days: 1)),
        ),
      SalesDatePreset.week => (
          startOfToday.subtract(const Duration(days: 6)),
          startOfToday.add(const Duration(days: 1)),
        ),
      SalesDatePreset.month => (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        ),
      SalesDatePreset.custom => (
          customFrom ?? startOfToday.subtract(const Duration(days: 30)),
          customTo ?? startOfToday.add(const Duration(days: 1)),
        ),
    };
  }
}

class _SalesQuery extends Notifier<SalesHistoryQuery> {
  @override
  SalesHistoryQuery build() => const SalesHistoryQuery();

  void patch(SalesHistoryQuery q) => state = q;
}

final salesHistoryQueryProvider =
    NotifierProvider<_SalesQuery, SalesHistoryQuery>(_SalesQuery.new);

final salesHistorySummaryProvider =
    FutureProvider.autoDispose<SalesHistorySummary>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final query = ref.watch(salesHistoryQueryProvider);
  final range = query.resolveRange();
  return db.fetchSalesHistorySummary(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
    from: range.$1,
    to: range.$2,
  );
});

final salesHistoryPendingSyncProvider = Provider.autoDispose<int>((ref) {
  final health = ref.watch(systemHealthSnapshotProvider);
  return health.value?.pendingQueue ?? 0;
});

class SalesCatalogState {
  const SalesCatalogState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<SaleListEntry> items;
  final SalePageCursor? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;
}

final salesCatalogProvider =
    AsyncNotifierProvider.autoDispose<SalesCatalogNotifier, SalesCatalogState>(
  SalesCatalogNotifier.new,
);

class SalesCatalogNotifier extends AsyncNotifier<SalesCatalogState> {
  @override
  Future<SalesCatalogState> build() async {
    ref.listen(salesHistoryQueryProvider, (_, __) => ref.invalidateSelf());

    final query = ref.read(salesHistoryQueryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final page = await _fetchPage(query);
    return SalesCatalogState(
      items: page.items,
      nextCursor: page.nextCursor,
    );
  }

  Future<SaleSearchPage> _fetchPage(SalesHistoryQuery query) {
    final db = ref.read(appDatabaseProvider);
    final range = query.resolveRange();
    return db.fetchSalesPage(
      storeId: StoreContext.storeId,
      from: range.$1,
      to: range.$2,
      query: query.search,
      paymentFilter: query.paymentFilter,
      limit: 50,
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(
      SalesCatalogState(
        items: current.items,
        nextCursor: current.nextCursor,
        isLoadingMore: true,
      ),
    );

    try {
      final query = ref.read(salesHistoryQueryProvider);
      final db = ref.read(appDatabaseProvider);
      final range = query.resolveRange();
      final page = await db.fetchSalesPage(
        storeId: StoreContext.storeId,
        from: range.$1,
        to: range.$2,
        query: query.search,
        paymentFilter: query.paymentFilter,
        cursor: current.nextCursor,
        limit: 50,
      );
      state = AsyncData(
        SalesCatalogState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
