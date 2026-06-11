import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store/active_store_scope.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';

final customerDebtsListProvider =
    StreamProvider.autoDispose.family<List<Debt>, String>((ref, customerId) {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchDebtsForCustomer(
    storeId: scope.storeId,
    customerId: customerId,
  );
});

final storeDebtPaymentsProvider =
    StreamProvider.autoDispose<List<DebtPayment>>((ref) {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchPaymentsForStore(storeId: scope.storeId);
});

final customerDebtPaymentsProvider =
    Provider.autoDispose.family<List<DebtPayment>, String>((ref, customerId) {
  final debts = ref.watch(customerDebtsListProvider(customerId));
  final payments = ref.watch(storeDebtPaymentsProvider);
  final debtIds = debts.asData?.value.map((d) => d.id).toSet() ?? {};
  return payments.when(
    data: (rows) => rows.where((p) => debtIds.contains(p.debtId)).toList(),
    loading: () => const [],
    error: (_, __) => const [],
  );
});
