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

final chartAccountBalancesProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  final accounts = await db.listChartOfAccounts(
    storeId: StoreContext.storeId,
    includeInactive: true,
  );
  final balances = <String, int>{};
  for (final a in accounts) {
    balances[a.id] = await db.getAccountBalanceCents(a.id);
  }
  return balances;
});

final accountDetailProvider =
    FutureProvider.autoDispose.family<AccountBalanceRow?, String>(
  (ref, accountId) async {
    ref.watch(accountingInitProvider);
    final db = ref.watch(appDatabaseProvider);
    final account = await db.getAccountById(accountId);
    if (account == null) return null;
    final activity = await db.sumAccountActivity(accountId: accountId);
    final balance = db.signedBalanceCents(
      accountType: account.type,
      openingBalanceCents: account.openingBalanceCents,
      debitSum: activity.debit,
      creditSum: activity.credit,
    );
    return AccountBalanceRow(
      account: account,
      debitCents: activity.debit,
      creditCents: activity.credit,
      balanceCents: balance,
    );
  },
);

final accountLedgerProvider =
    FutureProvider.autoDispose.family<List<LedgerLineRow>, String>(
  (ref, accountId) async {
    final db = ref.watch(appDatabaseProvider);
    return db.ledgerForAccount(accountId: accountId);
  },
);

final accountMonthlyActivityProvider =
    FutureProvider.autoDispose.family<List<AccountMonthActivityPoint>, String>(
  (ref, accountId) async {
    final db = ref.watch(appDatabaseProvider);
    return db.accountMonthlyActivity(accountId: accountId);
  },
);

final defaultPaymentAccountProvider = FutureProvider.autoDispose<String?>(
  (ref) async {
    final db = ref.watch(appDatabaseProvider);
    return db.getDefaultPaymentAccountId(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
    );
  },
);
