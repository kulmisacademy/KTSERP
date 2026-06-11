import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import 'accounting_engine.dart';

final accountingEngineProvider = Provider<AccountingEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AccountingEngine(db);
});

final accountingInitProvider = FutureProvider<void>((ref) async {
  final engine = ref.watch(accountingEngineProvider);
  await engine.ensureInitialized(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
  );
});

final chartOfAccountsProvider = StreamProvider.autoDispose<List<ChartOfAccount>>(
  (ref) {
    ref.watch(accountingInitProvider);
    final db = ref.watch(appDatabaseProvider);
    return db.watchChartOfAccounts(storeId: StoreContext.storeId);
  },
);

/// Same as `chartOfAccountsProvider`, with an option to include inactive accounts.
final chartOfAccountsAllProvider =
    StreamProvider.family<List<ChartOfAccount>, bool>((ref, includeInactive) {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchChartOfAccounts(
    storeId: StoreContext.storeId,
    includeInactive: includeInactive,
  );
});

/// Stable stream for accounting UI (not autoDispose — avoids dispose during modals).
final paymentAccountsProvider = StreamProvider<List<PaymentAccount>>((ref) {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchPaymentAccounts(storeId: StoreContext.storeId);
});

/// One-shot load for POS checkout and other dialogs.
final paymentAccountsListProvider = FutureProvider<List<PaymentAccount>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await db.ensureAccountingSeeded(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
  );
  return db.listPaymentAccounts(storeId: StoreContext.storeId);
});

final defaultPaymentAccountProvider = FutureProvider.autoDispose<String?>(
  (ref) async {
    final db = ref.watch(appDatabaseProvider);
    return db.getDefaultPaymentAccountId(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
    );
  },
);
