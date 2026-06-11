import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/store/store_branding.dart';
import '../core/store_context.dart';
import '../core/money/currency_symbol.dart';
import '../core/utils/date_time_parse.dart';
import '../data/local/app_database.dart';
import 'supabase_bootstrap.dart';

/// Pulls cloud data into the local Drift database (offline-first hydrate).
///
/// Conflict strategy: cloud wins when local has no pending sync for that row,
/// or when cloud `updated_at` / `created_at` is newer than local.
class SyncPullService {
  SyncPullService(this._db);

  final AppDatabase _db;

  static const _pageSize = 500;

  /// Full hydrate: products, customers, suppliers, sales, purchases, store settings.
  Future<SyncPullResult> pullAll() async {
    final client = supabaseClient;
    if (client == null || client.auth.currentSession == null) {
      return SyncPullResult.skipped('No Supabase session');
    }

    final tenantId = StoreContext.tenantId;
    final storeId = StoreContext.storeId;
    var pulled = 0;

    try {
      pulled += await _pullProducts(client, tenantId, storeId, since: null);
      pulled += await _pullCategories(client, tenantId, storeId, since: null);
      pulled += await _pullBrands(client, tenantId, storeId, since: null);
      pulled += await _pullCustomers(client, tenantId, storeId, since: null);
      pulled += await _pullSuppliers(client, tenantId, storeId, since: null);
      pulled += await _pullSales(client, tenantId, storeId, since: null);
      pulled += await _pullPurchases(client, tenantId, storeId, since: null);
      pulled += await _pullExpenses(client, tenantId, storeId, since: null);
      pulled += await _pullDebts(client, tenantId, storeId, since: null);
      pulled += await _pullDebtPayments(client, tenantId, storeId, since: null);
      pulled += await _pullAccounting(client, tenantId, storeId);
      await _pullStoreSettings(client, tenantId, storeId);

      await _db.setLastPulledAt(
        storeId: storeId,
        entity: 'all',
        at: DateTime.now(),
      );

      if (kDebugMode) {
        debugPrint('Sync pull complete: $pulled rows for store $storeId');
      }
      return SyncPullResult.success(pulled);
    } catch (e, st) {
      if (kDebugMode) debugPrint('Sync pull failed: $e\n$st');
      return SyncPullResult.failed(e.toString());
    }
  }

  /// Incremental pull using per-entity last_pulled_at timestamps.
  Future<SyncPullResult> pullIncremental() async {
    final client = supabaseClient;
    if (client == null || client.auth.currentSession == null) {
      return SyncPullResult.skipped('No Supabase session');
    }

    final tenantId = StoreContext.tenantId;
    final storeId = StoreContext.storeId;
    var pulled = 0;

    try {
      pulled += await _pullProducts(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'products'),
      );
      pulled += await _pullCategories(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'categories'),
      );
      pulled += await _pullBrands(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'brands'),
      );
      pulled += await _pullCustomers(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'customers'),
      );
      pulled += await _pullSuppliers(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'suppliers'),
      );
      pulled += await _pullSales(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'sales'),
      );
      pulled += await _pullPurchases(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'purchases'),
      );
      pulled += await _pullExpenses(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'expenses'),
      );
      pulled += await _pullDebts(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'debts'),
      );
      pulled += await _pullDebtPayments(
        client,
        tenantId,
        storeId,
        since: await _db.getLastPulledAt(storeId: storeId, entity: 'debt_payments'),
      );
      pulled += await _pullAccounting(client, tenantId, storeId);

      await _db.setLastPulledAt(
        storeId: storeId,
        entity: 'all',
        at: DateTime.now(),
      );

      return SyncPullResult.success(pulled);
    } catch (e, st) {
      if (kDebugMode) debugPrint('Sync incremental pull failed: $e\n$st');
      return SyncPullResult.failed(e.toString());
    }
  }

  Future<int> _pullProducts(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('products')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }

    final rows = await query.order('updated_at').limit(_pageSize) as List;
    var count = 0;

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'products',
        entityId: id,
      )) {
        continue;
      }

      final local = await _db.getProductById(storeId: storeId, productId: id);
      final cloudUpdated = _parseDate(row['updated_at']) ?? DateTime.now();
      if (local != null && !local.updatedAt.isBefore(cloudUpdated)) {
        continue;
      }

      await _db.upsertProductFromCloud(
        ProductsCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          name: Value(row['name'] as String? ?? 'Product'),
          secondaryName: Value(row['secondary_name'] as String?),
          barcode: Value(row['barcode'] as String?),
          barcodeType: Value(row['barcode_type'] as String? ?? 'code128'),
          sku: Value(row['sku'] as String?),
          scanCount: Value((row['scan_count'] as num?)?.toInt() ?? 0),
          quantity: Value((row['quantity'] as num?)?.toInt() ?? 0),
          purchasePriceCents:
              Value((row['purchase_price_cents'] as num?)?.toInt() ?? 0),
          sellingPriceCents:
              Value((row['selling_price_cents'] as num?)?.toInt() ?? 0),
          imageUrl: Value(row['image_url'] as String?),
          thumbnailUrl: Value(row['thumbnail_url'] as String?),
          categoryIcon: Value(row['category_icon'] as String?),
          hasImage: Value(row['has_image'] as bool? ?? false),
          updatedAt: Value(cloudUpdated),
        ),
      );
      count++;
    }

    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'products',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullCategories(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('categories')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);
    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }
    final rows = await query.order('updated_at').limit(_pageSize) as List;
    var count = 0;
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'categories',
        entityId: id,
      )) {
        continue;
      }
      await _db.upsertCategoryFromCloud(
        CategoriesCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          name: Value(row['name'] as String? ?? 'Category'),
          parentId: Value(row['parent_id'] as String?),
          createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
        ),
      );
      count++;
    }
    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'categories',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullBrands(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('brands')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);
    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }
    final rows = await query.order('updated_at').limit(_pageSize) as List;
    var count = 0;
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'brands',
        entityId: id,
      )) {
        continue;
      }
      await _db.upsertBrandFromCloud(
        BrandsCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          name: Value(row['name'] as String? ?? 'Brand'),
          createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
        ),
      );
      count++;
    }
    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'brands',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullExpenses(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('expenses')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);
    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }
    final rows = await query.order('updated_at').limit(_pageSize) as List;
    var count = 0;
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'expenses',
        entityId: id,
      )) {
        continue;
      }
      await _db.upsertExpenseFromCloud(
        ExpensesCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          name: Value(row['name'] as String? ?? 'Expense'),
          category: Value(row['category'] as String? ?? 'General'),
          amountCents: Value((row['amount_cents'] as num?)?.toInt() ?? 0),
          expenseDate: Value(_parseDate(row['expense_date']) ?? DateTime.now()),
          paidBy: Value(row['paid_by'] as String?),
          notes: Value(row['notes'] as String?),
          createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
        ),
      );
      count++;
    }
    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'expenses',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullDebts(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('debts')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);
    if (since != null) {
      query = query.gte('created_at', since.toUtc().toIso8601String());
    }
    final rows = await query.order('created_at').limit(_pageSize) as List;
    var count = 0;
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'debts',
        entityId: id,
      )) {
        continue;
      }
      await _db.upsertDebtFromCloud(
        DebtsCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          debtType: Value(row['debt_type'] as String? ?? 'customer'),
          supplierId: Value(row['supplier_id'] as String?),
          customerId: Value(row['customer_id'] as String?),
          originalCents: Value((row['original_cents'] as num?)?.toInt() ?? 0),
          paidCents: Value((row['paid_cents'] as num?)?.toInt() ?? 0),
          remainingCents: Value((row['remaining_cents'] as num?)?.toInt() ?? 0),
          dueDate: Value(_parseDate(row['due_date'])),
          status: Value(row['status'] as String? ?? 'active'),
          notes: Value(row['notes'] as String?),
          saleId: Value(row['sale_id'] as String?),
          purchaseId: Value(row['purchase_id'] as String?),
          invoiceNumber: Value(row['invoice_number'] as String?),
          createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
        ),
      );
      count++;
    }
    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'debts',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullDebtPayments(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('debt_payments')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);
    if (since != null) {
      query = query.gte('created_at', since.toUtc().toIso8601String());
    }
    final rows = await query.order('created_at').limit(_pageSize) as List;
    var count = 0;
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'debt_payments',
        entityId: id,
      )) {
        continue;
      }
      await _db.upsertDebtPaymentFromCloud(
        DebtPaymentsCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          debtId: Value(row['debt_id'] as String),
          amountCents: Value((row['amount_cents'] as num?)?.toInt() ?? 0),
          paidAt: Value(_parseDate(row['paid_at']) ?? DateTime.now()),
          method: Value(row['method'] as String?),
          paymentAccountId: Value(row['payment_account_id'] as String?),
          notes: Value(row['notes'] as String?),
          userId: Value(row['user_id'] as String?),
          createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
        ),
      );
      count++;
    }
    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'debt_payments',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullAccounting(
    SupabaseClient client,
    String tenantId,
    String storeId,
  ) async {
    var pulled = 0;

    Future<int> pullSimple({
      required String table,
      required String entity,
      required Future<void> Function(Map<String, dynamic> row) apply,
    }) async {
      final since = await _db.getLastPulledAt(storeId: storeId, entity: entity);
      var q = client.from(table).select().eq('tenant_id', tenantId).eq('store_id', storeId);
      if (since != null) {
        q = q.gte('created_at', since.toUtc().toIso8601String());
      }
      final rows = await q.order('created_at').limit(_pageSize) as List;
      var c = 0;
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final id = row['id'] as String;
        if (await _db.hasPendingSyncForEntity(storeId: storeId, entity: entity, entityId: id)) {
          continue;
        }
        await apply(row);
        c++;
      }
      await _db.setLastPulledAt(storeId: storeId, entity: entity, at: DateTime.now());
      return c;
    }

    pulled += await pullSimple(
      table: 'chart_of_accounts',
      entity: 'chart_of_accounts',
      apply: (row) async {
        await _db.upsertChartOfAccountFromCloud(
          ChartOfAccountsCompanion(
            id: Value(row['id'] as String),
            tenantId: Value(tenantId),
            storeId: Value(storeId),
            code: Value(row['code'] as String? ?? ''),
            name: Value(row['name'] as String? ?? ''),
            type: Value(row['type'] as String? ?? 'asset'),
            parentId: Value(row['parent_id'] as String?),
            openingBalanceCents: Value((row['opening_balance_cents'] as num?)?.toInt() ?? 0),
            isSystem: Value(row['is_system'] as bool? ?? false),
            isActive: Value(row['is_active'] as bool? ?? true),
            createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
          ),
        );
      },
    );

    pulled += await pullSimple(
      table: 'payment_accounts',
      entity: 'payment_accounts',
      apply: (row) async {
        await _db.upsertPaymentAccountFromCloud(
          PaymentAccountsCompanion(
            id: Value(row['id'] as String),
            tenantId: Value(tenantId),
            storeId: Value(storeId),
            name: Value(row['name'] as String? ?? ''),
            accountType: Value(row['account_type'] as String? ?? 'cash'),
            chartAccountId: Value(row['chart_account_id'] as String? ?? ''),
            isDefault: Value(row['is_default'] as bool? ?? false),
            isActive: Value(row['is_active'] as bool? ?? true),
            createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
          ),
        );
      },
    );

    pulled += await pullSimple(
      table: 'journal_entries',
      entity: 'journal_entries',
      apply: (row) async {
        await _db.upsertJournalEntryFromCloud(
          JournalEntriesCompanion(
            id: Value(row['id'] as String),
            tenantId: Value(tenantId),
            storeId: Value(storeId),
            entryDate: Value(_parseDate(row['entry_date']) ?? DateTime.now()),
            description: Value(row['description'] as String? ?? ''),
            sourceModule: Value(row['source_module'] as String? ?? 'manual'),
            sourceId: Value(row['source_id'] as String?),
            status: Value(row['status'] as String? ?? 'posted'),
            createdBy: Value(row['created_by'] as String?),
            notes: Value(row['notes'] as String?),
            createdAt: Value(_parseDate(row['created_at']) ?? DateTime.now()),
          ),
        );
      },
    );

    // journal_lines: store-scoped incremental pull via updated_at
    final sinceLines = await _db.getLastPulledAt(storeId: storeId, entity: 'journal_lines');
    var linesQuery = client
        .from('journal_lines')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);
    if (sinceLines != null) {
      linesQuery = linesQuery.gte(
        'updated_at',
        sinceLines.toUtc().toIso8601String(),
      );
    }
    final lineRows = await linesQuery.limit(_pageSize) as List;
    for (final raw in lineRows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(storeId: storeId, entity: 'journal_lines', entityId: id)) {
        continue;
      }
      await _db.upsertJournalLineFromCloud(
        JournalLinesCompanion(
          id: Value(id),
          tenantId: Value(row['tenant_id'] as String? ?? tenantId),
          storeId: Value(row['store_id'] as String? ?? storeId),
          journalEntryId: Value(row['journal_entry_id'] as String),
          accountId: Value(row['account_id'] as String),
          debitCents: Value((row['debit_cents'] as num?)?.toInt() ?? 0),
          creditCents: Value((row['credit_cents'] as num?)?.toInt() ?? 0),
          lineDescription: Value(row['line_description'] as String?),
          updatedAt: Value(_parseDate(row['updated_at']) ?? DateTime.now()),
        ),
      );
      pulled++;
    }
    await _db.setLastPulledAt(storeId: storeId, entity: 'journal_lines', at: DateTime.now());

    return pulled;
  }

  Future<int> _pullCustomers(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('customers')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }

    final rows = await query.order('updated_at').limit(_pageSize) as List;
    var count = 0;

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'customers',
        entityId: id,
      )) {
        continue;
      }

      final cloudUpdated = _parseDate(row['updated_at']) ?? DateTime.now();
      await _db.upsertCustomerFromCloud(
        CustomersCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          name: Value(row['name'] as String? ?? 'Customer'),
          phone: Value(row['phone'] as String?),
          email: Value(row['email'] as String?),
          address: Value(row['address'] as String?),
          updatedAt: Value(cloudUpdated),
        ),
      );
      count++;
    }

    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'customers',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullSuppliers(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('suppliers')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);

    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }

    final rows = await query.order('updated_at').limit(_pageSize) as List;
    var count = 0;

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'suppliers',
        entityId: id,
      )) {
        continue;
      }

      final cloudUpdated = _parseDate(row['updated_at']) ?? DateTime.now();
      await _db.upsertSupplierFromCloud(
        SuppliersCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          name: Value(row['name'] as String? ?? 'Supplier'),
          phone: Value(row['phone'] as String?),
          email: Value(row['email'] as String?),
          address: Value(row['address'] as String?),
          updatedAt: Value(cloudUpdated),
        ),
      );
      count++;
    }

    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'suppliers',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullSales(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('sales')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);

    if (since != null) {
      query = query.gte('created_at', since.toUtc().toIso8601String());
    }

    final rows = await query.order('created_at').limit(_pageSize) as List;
    var count = 0;

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'sales',
        entityId: id,
      )) {
        continue;
      }

      final local = await (_db.select(_db.sales)
            ..where((s) => s.id.equals(id)))
          .getSingleOrNull();
      final cloudCreated = _parseDate(row['created_at']) ?? DateTime.now();
      if (local != null && !local.createdAt.isBefore(cloudCreated)) {
        continue;
      }

      final itemRows = await client
          .from('sale_items')
          .select()
          .eq('sale_id', id) as List;

      final items = [
        for (final itemRaw in itemRows)
          SaleItemsCompanion(
            id: Value((itemRaw as Map)['id'] as String),
            tenantId: Value(tenantId),
            storeId: Value(storeId),
            saleId: Value(id),
            productId: Value(itemRaw['product_id'] as String?),
            name: Value(itemRaw['name'] as String? ?? 'Item'),
            quantity: Value((itemRaw['quantity'] as num?)?.toInt() ?? 0),
            unitPriceCents:
                Value((itemRaw['unit_price_cents'] as num?)?.toInt() ?? 0),
            lineTotalCents:
                Value((itemRaw['line_total_cents'] as num?)?.toInt() ?? 0),
            refundedQuantity:
                Value((itemRaw['refunded_quantity'] as num?)?.toInt() ?? 0),
          ),
      ];

      await _db.upsertSaleFromCloud(
        applyStockDeduction: true,
        sale: SalesCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          customerId: Value(row['customer_id'] as String?),
          subtotalCents: Value((row['subtotal_cents'] as num?)?.toInt() ?? 0),
          discountCents: Value((row['discount_cents'] as num?)?.toInt() ?? 0),
          taxCents: Value((row['tax_cents'] as num?)?.toInt() ?? 0),
          totalCents: Value((row['total_cents'] as num?)?.toInt() ?? 0),
          refundedTotalCents:
              Value((row['refunded_total_cents'] as num?)?.toInt() ?? 0),
          status: Value(row['status'] as String? ?? 'completed'),
          paymentJson: Value(_paymentJsonToString(row['payment_json'])),
          paidCents: Value((row['paid_cents'] as num?)?.toInt() ?? 0),
          paymentStatus: Value(row['payment_status'] as String? ?? 'paid'),
          createdAt: Value(cloudCreated),
        ),
        items: items,
      );
      count++;
    }

    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'sales',
      at: DateTime.now(),
    );
    return count;
  }

  Future<int> _pullPurchases(
    SupabaseClient client,
    String tenantId,
    String storeId, {
    DateTime? since,
  }) async {
    var query = client
        .from('purchases')
        .select()
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId);

    if (since != null) {
      query = query.gte('created_at', since.toUtc().toIso8601String());
    }

    final rows = await query.order('created_at').limit(_pageSize) as List;
    var count = 0;

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['id'] as String;
      if (await _db.hasPendingSyncForEntity(
        storeId: storeId,
        entity: 'purchases',
        entityId: id,
      )) {
        continue;
      }

      final local = await (_db.select(_db.purchases)
            ..where((p) => p.id.equals(id)))
          .getSingleOrNull();
      final cloudCreated =
          _parseDate(row['created_at']) ??
          _parseDate(row['purchase_date']) ??
          DateTime.now();
      if (local != null && !local.createdAt.isBefore(cloudCreated)) {
        continue;
      }

      final itemRows = await client
          .from('purchase_items')
          .select()
          .eq('purchase_id', id) as List;

      final items = [
        for (final itemRaw in itemRows)
          PurchaseItemsCompanion(
            id: Value((itemRaw as Map)['id'] as String),
            tenantId: Value(tenantId),
            storeId: Value(storeId),
            purchaseId: Value(id),
            productId: Value(itemRaw['product_id'] as String),
            quantity: Value((itemRaw['quantity'] as num?)?.toInt() ?? 0),
            purchasePriceCents:
                Value((itemRaw['purchase_price_cents'] as num?)?.toInt() ?? 0),
            lineTotalCents:
                Value((itemRaw['line_total_cents'] as num?)?.toInt() ?? 0),
          ),
      ];

      await _db.upsertPurchaseFromCloud(
        purchase: PurchasesCompanion(
          id: Value(id),
          tenantId: Value(tenantId),
          storeId: Value(storeId),
          supplierId: Value(row['supplier_id'] as String),
          invoiceNumber: Value(row['invoice_number'] as String?),
          purchaseDate: Value(
            _parseDate(row['purchase_date']) ?? cloudCreated,
          ),
          totalCents: Value((row['total_cents'] as num?)?.toInt() ?? 0),
          paidCents: Value((row['paid_cents'] as num?)?.toInt() ?? 0),
          paymentStatus: Value(row['payment_status'] as String? ?? 'paid'),
          createdAt: Value(cloudCreated),
        ),
        items: items,
      );
      count++;
    }

    await _db.setLastPulledAt(
      storeId: storeId,
      entity: 'purchases',
      at: DateTime.now(),
    );
    return count;
  }

  Future<void> _pullStoreSettings(
    SupabaseClient client,
    String tenantId,
    String storeId,
  ) async {
    final row = await client
        .from('stores')
        .select(
          'name, phone, email, address, country, invoice_footer, logo_url, tax_number, currency_code, locale_code, tenants(country, currency_code)',
        )
        .eq('id', storeId)
        .eq('tenant_id', tenantId)
        .maybeSingle();

    if (row == null) return;

    final existing = await (_db.select(_db.storeSettings)
          ..where((s) => s.storeId.equals(storeId)))
        .getSingleOrNull();

    final tenantData = row['tenants'];
    final tenantCurrency = tenantData is Map
        ? tenantData['currency_code'] as String?
        : null;
    final tenantCountry = tenantData is Map
        ? tenantData['country'] as String?
        : null;
    final currency = (row['currency_code'] as String? ??
            tenantCurrency ??
            existing?.currencyCode ??
            'USD')
        .toUpperCase();
    final country = (row['country'] as String?)?.trim().isNotEmpty == true
        ? (row['country'] as String).trim()
        : ((tenantCountry?.trim().isNotEmpty ?? false)
            ? tenantCountry!.trim()
            : (existing?.country ?? 'Somalia'));

    // Prefer freshly saved local branding (pull can race with offline save).
    if (existing != null) {
      final age = DateTime.now().difference(existing.updatedAt);
      if (age < const Duration(minutes: 5)) return;
    }

    await _db.upsertStoreSettingsFromCloud(
      StoreSettingsCompanion(
        storeId: Value(storeId),
        tenantId: Value(tenantId),
        storeName: Value(
          _resolveStoreName(
            cloud: row['name'] as String?,
            existing: existing?.storeName,
          ),
        ),
        phone: Value(row['phone'] as String? ?? existing?.phone),
        address: Value(row['address'] as String? ?? existing?.address),
        email: Value(row['email'] as String? ?? existing?.email),
        invoiceFooter: Value(row['invoice_footer'] as String? ?? existing?.invoiceFooter),
        logoUrl: Value(row['logo_url'] as String? ?? existing?.logoUrl),
        taxNumber: Value(row['tax_number'] as String? ?? existing?.taxNumber),
        country: Value(country),
        currencyCode: Value(currency),
        currencySymbol: Value(currencySymbolFor(currency)),
        localeCode: Value(
          row['locale_code'] as String? ?? existing?.localeCode ?? 'en',
        ),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final merged = await _db.getStoreSettings(storeId: storeId);
    StoreBranding.applyToSession(merged);
  }

  DateTime? _parseDate(Object? value) => SafeDateTime.tryParse(value);

  String _paymentJsonToString(Object? payment) {
    if (payment == null) return '{}';
    if (payment is String) return payment;
    if (payment is Map) return jsonEncode(payment);
    return '{}';
  }

  String _resolveStoreName({String? cloud, String? existing}) {
    final c = cloud?.trim();
    if (c != null && c.isNotEmpty && c != 'My Store') return c;
    final e = existing?.trim();
    if (e != null && e.isNotEmpty && e != 'My Store') return e;
    final ctx = StoreContext.storeName?.trim();
    if (ctx != null && ctx.isNotEmpty && ctx != 'My Store') return ctx;
    return c ?? e ?? ctx ?? 'My Store';
  }
}

class SyncPullResult {
  const SyncPullResult._({
    required this.ok,
    this.pulled = 0,
    this.message,
  });

  final bool ok;
  final int pulled;
  final String? message;

  factory SyncPullResult.success(int pulled) =>
      SyncPullResult._(ok: true, pulled: pulled);

  factory SyncPullResult.failed(String message) =>
      SyncPullResult._(ok: false, message: message);

  factory SyncPullResult.skipped(String message) =>
      SyncPullResult._(ok: true, message: message);
}
