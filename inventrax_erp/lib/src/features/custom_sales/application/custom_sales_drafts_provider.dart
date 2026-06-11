import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../domain/custom_sales_models.dart';

final customSalesDraftsProvider =
    StreamProvider.autoDispose<List<HeldSale>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .watchHeldSales(
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
      )
      .map(
        (held) => held
            .where((h) => h.id.startsWith(customSalesDraftPrefix))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
});
