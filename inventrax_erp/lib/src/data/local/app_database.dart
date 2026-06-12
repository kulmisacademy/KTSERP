import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/performance/db_pragmas.dart';
import '../../core/utils/date_time_parse.dart';
import '../../features/accounting/domain/accounting_constants.dart';
import '../../sync/sync_payload.dart';
import 'product_search.dart';
import 'sales_search.dart';
import 'tables.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

const _uuid = Uuid();
// Keep our own constant to avoid deprecated `Uuid.NAMESPACE_URL`.
const _uuidNamespaceUrl = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';

class InsufficientStockException implements Exception {
  const InsufficientStockException({
    required this.productId,
    required this.requested,
    this.available,
  });

  final String productId;
  final int requested;
  final int? available;

  @override
  String toString() =>
      'Insufficient stock for product $productId (requested $requested, available ${available ?? 0})';
}

@DriftDatabase(
  tables: [
    Products,
    Sales,
    SaleItems,
    InventoryMovements,
    Suppliers,
    Purchases,
    PurchaseItems,
    Debts,
    DebtPayments,
    DebtShareLinks,
    Expenses,
    Categories,
    Brands,
    Customers,
    StoreSettings,
    AppNotifications,
    AuditLogs,
    HeldSales,
    AppSessions,
    StoreStaff,
    SyncQueue,
    ChartOfAccounts,
    PaymentAccounts,
    JournalEntries,
    JournalLines,
    SmsPackages,
    StoreSmsWallets,
    SmsTemplates,
    SmsQueue,
    SmsLogs,
    SmsReminders,
    StoreSmsSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// In-memory or file DB for automated tests / QA seed tools.
  AppDatabase.forTest(super.executor);

  @override
  int get schemaVersion => 24;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaults();
          await ensureAccountingSeeded(
            tenantId: 'dev-tenant',
            storeId: 'dev-store',
          );
        },
        beforeOpen: (details) async {
          await _repairSchemaColumns();
          await _repairJournalLinesSchema();
          await applySqlitePerformancePragmas(this);
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(inventoryMovements);
          }
          if (from < 3) {
            await m.createTable(suppliers);
            await m.createTable(purchases);
            await m.createTable(purchaseItems);
            await m.createTable(debts);
          }
          if (from < 4) {
            await m.createTable(debtPayments);
          }
          if (from < 5) {
            await m.addColumn(saleItems, saleItems.unitCostCents);
            await m.createTable(expenses);
          }
          if (from < 6) {
            await m.createTable(categories);
            await m.createTable(brands);
            await m.createTable(customers);
            await m.createTable(storeSettings);
            await m.createTable(appNotifications);
            await _seedDefaults();
          }
          if (from < 7) {
            await m.addColumn(products, products.secondaryName);
            await m.addColumn(products, products.barcodeType);
            await m.addColumn(products, products.scanCount);
            await m.createTable(auditLogs);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_products_store_barcode '
              'ON products (store_id, barcode);',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_products_store_sku '
              'ON products (store_id, sku);',
            );
          }
          if (from < 8) {
            await m.addColumn(
              storeSettings,
              storeSettings.allowCashierPriceOverride,
            );
            await m.createTable(heldSales);
          }
          if (from < 9) {
            await m.addColumn(sales, sales.status);
            await m.addColumn(sales, sales.voidedAt);
            await m.addColumn(sales, sales.voidReason);
            await m.addColumn(storeSettings, storeSettings.autoPrintReceipt);
            await m.createTable(appSessions);
          }
          if (from < 10) {
            await m.addColumn(saleItems, saleItems.refundedQuantity);
            await m.addColumn(sales, sales.refundedTotalCents);
          }
          if (from < 11) {
            await m.addColumn(appSessions, appSessions.storeName);
            await m.addColumn(appSessions, appSessions.role);
            await m.addColumn(appSessions, appSessions.rememberMe);
          }
          if (from < 12) {
            await m.createTable(chartOfAccounts);
            await m.createTable(paymentAccounts);
            await m.createTable(journalEntries);
            await m.createTable(journalLines);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_journal_entries_store_date '
              'ON journal_entries (store_id, entry_date);',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_journal_lines_entry '
              'ON journal_lines (journal_entry_id);',
            );
            await ensureAccountingSeeded(
              tenantId: 'dev-tenant',
              storeId: 'dev-store',
            );
          }
          if (from < 13) {
            await m.addColumn(sales, sales.paidCents);
            await m.addColumn(sales, sales.paymentStatus);
            await m.addColumn(debts, debts.saleId);
            await m.addColumn(debts, debts.purchaseId);
            await m.addColumn(debts, debts.invoiceNumber);
            await m.addColumn(debtPayments, debtPayments.paymentAccountId);
            await m.createTable(debtShareLinks);
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_debt_share_token '
              'ON debt_share_links (token);',
            );
          }
          if (from < 14) {
            await m.addColumn(purchases, purchases.paymentStatus);
          }
          if (from < 15) {
            await _repairSchemaColumns();
          }
          if (from < 16) {
            await _repairSchemaColumns();
          }
          if (from < 17) {
            await m.createTable(storeStaff);
          }
          if (from < 19) {
            await _repairSchemaColumns();
          }
          if (from < 20) {
            await m.addColumn(journalLines, journalLines.tenantId);
            await m.addColumn(journalLines, journalLines.storeId);
            await m.addColumn(journalLines, journalLines.updatedAt);
          }
          if (from < 21) {
            await _repairJournalLinesSchema();
          }
          if (from < 22) {
            await m.addColumn(storeSettings, storeSettings.invoiceShowSku);
            await m.addColumn(storeSettings, storeSettings.invoiceShowDiscount);
            await m.addColumn(storeSettings, storeSettings.invoiceShowTax);
            await m.addColumn(storeSettings, storeSettings.invoiceCompactMode);
          }
          if (from < 23) {
            await m.createTable(smsPackages);
            await m.createTable(storeSmsWallets);
            await m.createTable(smsTemplates);
            await m.createTable(smsQueue);
            await m.createTable(smsLogs);
            await m.createTable(smsReminders);
            await m.createTable(storeSmsSettings);
            await _seedSmsPackages();
          }
          if (from < 24) {
            await m.addColumn(storeSettings, storeSettings.country);
            await m.addColumn(storeSettings, storeSettings.currencySymbol);
          }
          if (from < 18) {
            await m.addColumn(products, products.imageUrl);
            await m.addColumn(products, products.thumbnailUrl);
            await m.addColumn(products, products.categoryIcon);
            await m.addColumn(products, products.hasImage);
            await m.addColumn(storeSettings, storeSettings.invoiceFooter);
            await m.addColumn(storeSettings, storeSettings.email);
            await m.addColumn(storeSettings, storeSettings.taxNumber);
            await m.addColumn(storeSettings, storeSettings.logoUrl);
            await m.addColumn(storeSettings, storeSettings.logoLocalPath);
            await _migrateLegacyProductIcons();
          }
        },
      );

  /// Call before writes if the DB was opened before a schema update (e.g. hot reload).
  Future<void> ensureSchemaReady() async {
    await _repairSchemaColumns();
    await _repairJournalLinesSchema();
  }

  /// Adds missing columns using ALTER TABLE (works on drift WASM).
  Future<void> _repairSchemaColumns() async {
    Future<void> tryAlter(String sql) async {
      try {
        await customStatement(sql);
      } catch (_) {
        // Column already exists or benign failure.
      }
    }

    await tryAlter(
      'ALTER TABLE sales ADD COLUMN paid_cents INTEGER NOT NULL DEFAULT 0',
    );
    await tryAlter(
      "ALTER TABLE sales ADD COLUMN payment_status TEXT NOT NULL DEFAULT 'paid'",
    );
    await tryAlter(
      "ALTER TABLE purchases ADD COLUMN payment_status TEXT NOT NULL DEFAULT 'paid'",
    );
    await tryAlter('ALTER TABLE debts ADD COLUMN sale_id TEXT');
    await tryAlter('ALTER TABLE debts ADD COLUMN purchase_id TEXT');
    await tryAlter('ALTER TABLE debts ADD COLUMN invoice_number TEXT');
    await tryAlter(
      'ALTER TABLE debt_payments ADD COLUMN payment_account_id TEXT',
    );
    await tryAlter('ALTER TABLE products ADD COLUMN image_url TEXT');
    await tryAlter('ALTER TABLE products ADD COLUMN thumbnail_url TEXT');
    await tryAlter('ALTER TABLE products ADD COLUMN category_icon TEXT');
    await tryAlter(
      'ALTER TABLE products ADD COLUMN has_image INTEGER NOT NULL DEFAULT 0',
    );
    await tryAlter('ALTER TABLE store_settings ADD COLUMN invoice_footer TEXT');
    await tryAlter('ALTER TABLE store_settings ADD COLUMN email TEXT');
    await tryAlter('ALTER TABLE store_settings ADD COLUMN tax_number TEXT');
    await tryAlter('ALTER TABLE store_settings ADD COLUMN logo_url TEXT');
    await tryAlter('ALTER TABLE store_settings ADD COLUMN logo_local_path TEXT');
    await tryAlter(
      "ALTER TABLE store_settings ADD COLUMN locale_code TEXT NOT NULL DEFAULT 'en'",
    );
    await tryAlter(
      'ALTER TABLE store_settings ADD COLUMN invoice_show_sku INTEGER NOT NULL DEFAULT 0',
    );
    await tryAlter(
      'ALTER TABLE store_settings ADD COLUMN invoice_show_discount INTEGER NOT NULL DEFAULT 0',
    );
    await tryAlter(
      'ALTER TABLE store_settings ADD COLUMN invoice_show_tax INTEGER NOT NULL DEFAULT 0',
    );
    await tryAlter(
      'ALTER TABLE store_settings ADD COLUMN invoice_compact_mode INTEGER NOT NULL DEFAULT 1',
    );
    await tryAlter(
      "ALTER TABLE store_settings ADD COLUMN country TEXT NOT NULL DEFAULT 'Somalia'",
    );
    await tryAlter(
      "ALTER TABLE store_settings ADD COLUMN currency_symbol TEXT NOT NULL DEFAULT '\$'",
    );

    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_metadata (
        store_id TEXT NOT NULL,
        entity TEXT NOT NULL,
        last_pulled_at TEXT NOT NULL,
        PRIMARY KEY (store_id, entity)
      )
    ''');

    // POS search: support fast name ordering/filtering without scanning whole table.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_store_name_nocase '
      'ON products (store_id, name COLLATE NOCASE);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_store_updated_id '
      'ON products (store_id, updated_at DESC, id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_products_store_scan '
      'ON products (store_id, scan_count DESC);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_store_status_created '
      'ON sales (store_id, status, created_at DESC);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_store_created_id '
      'ON sales (store_id, created_at DESC, id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sales_store_payment_status '
      'ON sales (store_id, payment_status);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_expenses_store_date '
      'ON expenses (store_id, expense_date DESC);',
    );
  }

  Future<bool> _journalLinesHasColumn(String name) async {
    final rows = await customSelect(
      "SELECT 1 AS ok FROM pragma_table_info('journal_lines') WHERE name = ?",
      variables: [Variable<String>(name)],
      readsFrom: {},
    ).get();
    return rows.isNotEmpty;
  }

  Future<String?> _journalLinesColumnType(String name) async {
    final row = await customSelect(
      "SELECT type FROM pragma_table_info('journal_lines') WHERE name = ?",
      variables: [Variable<String>(name)],
      readsFrom: {},
    ).getSingleOrNull();
    return row?.read<String>('type');
  }

  Future<void> _ensureJournalLinesIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_journal_lines_tenant_store '
      'ON journal_lines (tenant_id, store_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_journal_lines_journal_entry '
      'ON journal_lines (tenant_id, store_id, journal_entry_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_journal_lines_account '
      'ON journal_lines (tenant_id, store_id, account_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_journal_lines_entry '
      'ON journal_lines (journal_entry_id)',
    );
  }

  /// Idempotent repair for journal_lines multi-tenant + Drift-compatible INTEGER updated_at.
  Future<void> _repairJournalLinesSchema() async {
    final tableExists = await customSelect(
      "SELECT 1 AS ok FROM sqlite_master WHERE type = 'table' AND name = 'journal_lines'",
      readsFrom: {},
    ).get();
    if (tableExists.isEmpty) return;

    final updatedType = await _journalLinesColumnType('updated_at');
    if (updatedType != null && updatedType.toUpperCase() != 'INTEGER') {
      await _rebuildJournalLinesTable();
      return;
    }

    Future<void> tryAlter(String sql) async {
      try {
        await customStatement(sql);
      } catch (_) {}
    }

    if (!await _journalLinesHasColumn('tenant_id')) {
      await tryAlter('ALTER TABLE journal_lines ADD COLUMN tenant_id TEXT');
    }
    if (!await _journalLinesHasColumn('store_id')) {
      await tryAlter('ALTER TABLE journal_lines ADD COLUMN store_id TEXT');
    }
    if (!await _journalLinesHasColumn('updated_at')) {
      await tryAlter(
        "ALTER TABLE journal_lines ADD COLUMN updated_at INTEGER NOT NULL "
        "DEFAULT (CAST(strftime('%s','now') AS INTEGER))",
      );
    }

    await customStatement('''
      UPDATE journal_lines
      SET tenant_id = (
            SELECT tenant_id FROM journal_entries
            WHERE journal_entries.id = journal_lines.journal_entry_id
          ),
          store_id = (
            SELECT store_id FROM journal_entries
            WHERE journal_entries.id = journal_lines.journal_entry_id
          )
      WHERE tenant_id IS NULL OR tenant_id = ''
         OR store_id IS NULL OR store_id = ''
    ''');

    await customStatement('''
      UPDATE journal_lines
      SET updated_at = COALESCE(
            (
              SELECT created_at FROM journal_entries
              WHERE journal_entries.id = journal_lines.journal_entry_id
            ),
            CAST(strftime('%s','now') AS INTEGER)
          )
      WHERE updated_at IS NULL
    ''');

    await _ensureJournalLinesIndexes();
  }

  Future<void> _rebuildJournalLinesTable() async {
    await customStatement('DROP TABLE IF EXISTS _journal_lines_rebuild');
    await customStatement('''
      CREATE TABLE _journal_lines_rebuild (
        id TEXT NOT NULL PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        store_id TEXT NOT NULL,
        journal_entry_id TEXT NOT NULL,
        account_id TEXT NOT NULL,
        debit_cents INTEGER NOT NULL DEFAULT 0,
        credit_cents INTEGER NOT NULL DEFAULT 0,
        line_description TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      INSERT INTO _journal_lines_rebuild (
        id, tenant_id, store_id, journal_entry_id, account_id,
        debit_cents, credit_cents, line_description, updated_at
      )
      SELECT
        jl.id,
        COALESCE(
          NULLIF(jl.tenant_id, ''),
          (SELECT je.tenant_id FROM journal_entries je
           WHERE je.id = jl.journal_entry_id),
          ''
        ),
        COALESCE(
          NULLIF(jl.store_id, ''),
          (SELECT je.store_id FROM journal_entries je
           WHERE je.id = jl.journal_entry_id),
          ''
        ),
        jl.journal_entry_id,
        jl.account_id,
        jl.debit_cents,
        jl.credit_cents,
        jl.line_description,
        COALESCE(
          (SELECT je.created_at FROM journal_entries je
           WHERE je.id = jl.journal_entry_id),
          CAST(strftime('%s','now') AS INTEGER)
        )
      FROM journal_lines jl
    ''');
    await customStatement('DROP TABLE journal_lines');
    await customStatement(
      'ALTER TABLE _journal_lines_rebuild RENAME TO journal_lines',
    );
    await _ensureJournalLinesIndexes();
  }

  static String normalizeProductName(String name) =>
      name.trim().toLowerCase();

  /// Moves legacy `icon:xyz` in image_path into category_icon.
  Future<void> _migrateLegacyProductIcons() async {
    final rows = await customSelect(
      "SELECT id, image_path FROM products WHERE image_path LIKE 'icon:%'",
      readsFrom: {products},
    ).get();
    for (final row in rows) {
      final id = row.read<String>('id');
      final path = row.read<String?>('image_path');
      if (path == null || !path.startsWith('icon:')) continue;
      final iconId = path.substring('icon:'.length).trim();
      if (iconId.isEmpty) continue;
      await (update(products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
          categoryIcon: Value(iconId),
          imagePath: const Value(null),
        ),
      );
    }
  }

  Future<void> _seedDefaults() async {
    const tenantId = 'dev-tenant';
    const storeId = 'dev-store';
    final existing = await (select(storeSettings)
          ..where((s) => s.storeId.equals(storeId)))
        .getSingleOrNull();
    if (existing != null) return;

    await into(storeSettings).insert(
      StoreSettingsCompanion.insert(
        storeId: storeId,
        tenantId: tenantId,
        storeName: 'My Store',
      ),
    );

    final catCount = await (selectOnly(categories)
          ..addColumns([categories.id.count()]))
        .getSingle();
    if ((catCount.read(categories.id.count()) ?? 0) == 0) {
      for (final name in ['General', 'Grocery', 'Electronics', 'Pharmacy']) {
        await into(categories).insert(
          CategoriesCompanion.insert(
            id: _uuid.v4(),
            tenantId: tenantId,
            storeId: storeId,
            name: name,
          ),
        );
      }
    }
  }

  Future<Supplier?> findSupplierByNameOrPhone({
    required String storeId,
    required String name,
    String? phone,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final byName = await (select(suppliers)
          ..where((s) => s.storeId.equals(storeId) & s.name.equals(trimmed)))
        .getSingleOrNull();
    if (byName != null) return byName;
    final p = phone?.trim();
    if (p == null || p.isEmpty) return null;
    return (select(suppliers)
          ..where((s) => s.storeId.equals(storeId) & s.phone.equals(p)))
        .getSingleOrNull();
  }

  Future<String> getOrCreateSupplier({
    required String tenantId,
    required String storeId,
    required String name,
    String? phone,
    String? address,
  }) async {
    final trimmed = name.trim();
    final existing = await findSupplierByNameOrPhone(
      storeId: storeId,
      name: trimmed,
      phone: phone,
    );
    if (existing != null) return existing.id;

    final id = _uuid.v4();
    await into(suppliers).insert(
      SuppliersCompanion.insert(
        id: id,
        tenantId: tenantId,
        storeId: storeId,
        name: trimmed,
        phone: Value(phone?.trim().isEmpty ?? true ? null : phone!.trim()),
        address: Value(address?.trim().isEmpty ?? true ? null : address!.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final row = await (select(suppliers)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (row != null) {
      await enqueueSync(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'suppliers',
        entityId: id,
        operation: 'upsert',
        payload: SyncPayload.supplier(row),
      );
    }
    return id;
  }

  Future<void> enqueueSync({
    required String tenantId,
    required String storeId,
    required String entity,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final existing = await (select(syncQueue)
          ..where(
            (q) =>
                q.tenantId.equals(tenantId) &
                q.storeId.equals(storeId) &
                q.entity.equals(entity) &
                q.entityId.equals(entityId),
          ))
        .getSingleOrNull();

    final encoded = jsonEncode(payload);
    if (existing != null) {
      await (update(syncQueue)..where((q) => q.id.equals(existing.id))).write(
        SyncQueueCompanion(
          operation: Value(operation),
          payloadJson: Value(encoded),
          retryCount: const Value(0),
          lastError: const Value.absent(),
          createdAt: Value(DateTime.now()),
        ),
      );
      return;
    }

    await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        tenantId: tenantId,
        storeId: storeId,
        entity: entity,
        entityId: entityId,
        operation: operation,
        payloadJson: encoded,
      ),
    );
  }

  Future<Supplier?> getSupplierById(String id) {
    return (select(suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<List<PurchaseItem>> listPurchaseItemsForPurchase({
    required String storeId,
    required String purchaseId,
  }) {
    return (select(purchaseItems)
          ..where(
            (i) => i.storeId.equals(storeId) & i.purchaseId.equals(purchaseId),
          ))
        .get();
  }

  Future<void> createPurchase({
    required PurchasesCompanion purchase,
    required List<PurchaseItemsCompanion> items,
  }) async {
    await ensureSchemaReady();
    await transaction(() async {
      await into(purchases).insert(purchase);
      await batch((b) => b.insertAll(purchaseItems, items));

      // apply stock + movements
      for (final item in items) {
        final productId = item.productId.value;
        final productRow = await (select(products)
              ..where((p) =>
                  p.id.equals(productId) & p.storeId.equals(purchase.storeId.value)))
            .getSingleOrNull();
        if (productRow == null) continue;

        final newQty = productRow.quantity + item.quantity.value;
        await (update(products)
              ..where((p) =>
                  p.id.equals(productId) & p.storeId.equals(purchase.storeId.value)))
            .write(
          ProductsCompanion(
            quantity: Value(newQty),
            purchasePriceCents: Value(item.purchasePriceCents.value),
            sellingPriceCents: item.newSellingPriceCents.present
                ? Value(item.newSellingPriceCents.value!)
                : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await into(inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            id: _uuid.v4(),
            tenantId: purchase.tenantId.value,
            storeId: purchase.storeId.value,
            productId: productId,
            reasonCode: 'purchase',
            deltaQuantity: item.quantity.value,
            referenceType: const Value('purchase'),
            referenceId: Value(purchase.id.value),
          ),
        );
      }

      // supplier debt if partially paid
      final remaining = purchase.totalCents.value - purchase.paidCents.value;
      if (remaining > 0) {
        final inv = purchase.invoiceNumber.present
            ? purchase.invoiceNumber.value
            : null;
        await into(debts).insert(
          DebtsCompanion.insert(
            id: _uuid.v4(),
            tenantId: purchase.tenantId.value,
            storeId: purchase.storeId.value,
            debtType: 'supplier',
            supplierId: Value(purchase.supplierId.value),
            originalCents: remaining,
            paidCents: Value(purchase.paidCents.value),
            remainingCents: remaining,
            status: purchase.paidCents.value > 0 ? 'partially_paid' : 'active',
            purchaseId: Value(purchase.id.value),
            invoiceNumber: Value(inv ?? purchase.id.value.substring(0, 8)),
            notes: const Value('Auto-created from purchase.'),
          ),
        );
      }

    });

    final savedPurchase = await getPurchaseById(
      storeId: purchase.storeId.value,
      purchaseId: purchase.id.value,
    );
    final savedItems = await listPurchaseItemsForPurchase(
      storeId: purchase.storeId.value,
      purchaseId: purchase.id.value,
    );
    if (savedPurchase != null) {
      await enqueueSync(
        tenantId: purchase.tenantId.value,
        storeId: purchase.storeId.value,
        entity: 'purchases',
        entityId: purchase.id.value,
        operation: 'upsert',
        payload: SyncPayload.purchase(savedPurchase, savedItems),
      );
      for (final item in savedItems) {
        final product = await (select(products)
              ..where((p) => p.id.equals(item.productId)))
            .getSingleOrNull();
        if (product != null) {
          await enqueueSync(
            tenantId: purchase.tenantId.value,
            storeId: purchase.storeId.value,
            entity: 'products',
            entityId: product.id,
            operation: 'upsert',
            payload: SyncPayload.product(product),
          );
        }
      }
    }
  }

  Future<Purchase?> getPurchaseById({
    required String storeId,
    required String purchaseId,
  }) {
    return (select(purchases)
          ..where((p) => p.storeId.equals(storeId) & p.id.equals(purchaseId)))
        .getSingleOrNull();
  }

  Stream<List<Debt>> watchOpenDebts({
    required String storeId,
    required String debtType,
  }) {
    return (select(debts)
          ..where((d) =>
              d.storeId.equals(storeId) &
              d.debtType.equals(debtType) &
              d.remainingCents.isBiggerThanValue(0))
          ..orderBy([(d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<Debt>> watchOpenSupplierDebts({required String storeId}) =>
      watchOpenDebts(storeId: storeId, debtType: 'supplier');

  Stream<List<Debt>> watchOpenCustomerDebts({required String storeId}) =>
      watchOpenDebts(storeId: storeId, debtType: 'customer');

  Stream<List<Customer>> watchCustomers({
    required String tenantId,
    required String storeId,
  }) {
    return (select(customers)
          ..where(
            (c) => _activeScope(
              tenantCol: c.tenantId,
              storeCol: c.storeId,
              tenantId: tenantId,
              storeId: storeId,
            ),
          )
          ..orderBy([
            (c) => OrderingTerm(expression: c.name),
          ]))
        .watch();
  }

  Stream<List<Supplier>> watchSuppliers({required String storeId}) {
    return (select(suppliers)
          ..where((s) => s.storeId.equals(storeId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.name),
          ]))
        .watch();
  }

  Stream<List<Category>> watchCategories({required String storeId}) {
    return (select(categories)
          ..where((c) => c.storeId.equals(storeId))
          ..orderBy([
            (c) => OrderingTerm(expression: c.name),
          ]))
        .watch();
  }

  Stream<List<Brand>> watchBrands({required String storeId}) {
    return (select(brands)
          ..where((b) => b.storeId.equals(storeId))
          ..orderBy([
            (b) => OrderingTerm(expression: b.name),
          ]))
        .watch();
  }

  Stream<StoreSetting?> watchStoreSettings({required String storeId}) {
    return (select(storeSettings)..where((s) => s.storeId.equals(storeId)))
        .watchSingleOrNull();
  }

  Future<StoreSetting?> getStoreSettings({required String storeId}) {
    return (select(storeSettings)..where((s) => s.storeId.equals(storeId)))
        .getSingleOrNull();
  }

  /// Merges [patch] onto the existing row so partial updates never wipe other fields.
  Future<void> upsertStoreSettings(StoreSettingsCompanion patch) async {
    if (!patch.storeId.present) {
      throw ArgumentError('storeId is required for upsertStoreSettings');
    }
    final storeId = patch.storeId.value;
    final existing = await getStoreSettings(storeId: storeId);

    if (existing == null) {
      await into(storeSettings).insert(patch, mode: InsertMode.insert);
      return;
    }

    final merged = existing.copyWithCompanion(patch);
    await into(storeSettings).insert(
      merged.toCompanion(false),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<AppSession?> getActiveSession() {
    return (select(appSessions)..where((s) => s.id.equals('active')))
        .getSingleOrNull();
  }

  Future<void> saveActiveSession(AppSessionsCompanion session) {
    return into(appSessions).insert(
      session,
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> clearActiveSession() {
    return (delete(appSessions)..where((s) => s.id.equals('active'))).go();
  }

  Future<Sale?> getSaleById({
    required String storeId,
    required String saleId,
  }) {
    return (select(sales)
          ..where((s) => s.storeId.equals(storeId) & s.id.equals(saleId)))
        .getSingleOrNull();
  }

  Future<List<SaleItem>> listSaleItems({
    required String storeId,
    required String saleId,
  }) {
    return (select(saleItems)
          ..where((i) => i.storeId.equals(storeId) & i.saleId.equals(saleId)))
        .get();
  }

  Future<void> voidSale({
    required String tenantId,
    required String storeId,
    required String saleId,
    required String reason,
    String? userId,
  }) async {
    final sale = await getSaleById(storeId: storeId, saleId: saleId);
    if (sale == null || sale.status == 'voided') return;

    final items = await listSaleItems(storeId: storeId, saleId: saleId);

    await transaction(() async {
      await (update(sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          status: const Value('voided'),
          voidedAt: Value(DateTime.now()),
          voidReason: Value(reason),
        ),
      );

      for (final item in items) {
        final productId = item.productId;
        if (productId == null) continue;

        final productRow = await (select(products)
              ..where((p) => p.id.equals(productId) & p.storeId.equals(storeId)))
            .getSingleOrNull();
        if (productRow == null) continue;

        final restoreQty = item.quantity - item.refundedQuantity;
        if (restoreQty <= 0) continue;

        await (update(products)..where((p) => p.id.equals(productId))).write(
          ProductsCompanion(
            quantity: Value(productRow.quantity + restoreQty),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await into(inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            id: _uuid.v4(),
            tenantId: tenantId,
            storeId: storeId,
            productId: productId,
            reasonCode: 'sale_void',
            deltaQuantity: restoreQty,
            referenceType: const Value('sale'),
            referenceId: Value(saleId),
          ),
        );
      }

      await recordAuditLog(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'sale',
        entityId: saleId,
        action: 'void',
        field: 'status',
        oldValue: 'completed',
        newValue: reason,
        userId: userId,
      );
    });

    final updated = await getSaleById(storeId: storeId, saleId: saleId);
    final updatedItems = await listSaleItems(storeId: storeId, saleId: saleId);
    if (updated != null) {
      await enqueueSync(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'sales',
        entityId: saleId,
        operation: 'void',
        payload: SyncPayload.sale(updated, updatedItems),
      );
    }
  }

  /// Refund specific line quantities; restores stock and updates totals.
  Future<int> partialRefundSale({
    required String tenantId,
    required String storeId,
    required String saleId,
    required Map<String, int> lineRefunds,
    required String reason,
    String? userId,
  }) async {
    final sale = await getSaleById(storeId: storeId, saleId: saleId);
    if (sale == null || sale.status == 'voided') return 0;

    final items = await listSaleItems(storeId: storeId, saleId: saleId);
    final refunds = <SaleItem, int>{};
    var refundCents = 0;

    for (final item in items) {
      final addQty = lineRefunds[item.id] ?? 0;
      if (addQty <= 0) continue;
      final remaining = item.quantity - item.refundedQuantity;
      if (addQty > remaining) continue;
      refunds[item] = addQty;
      refundCents += addQty * item.unitPriceCents;
    }
    if (refundCents <= 0) return 0;

    await transaction(() async {
      for (final entry in refunds.entries) {
        final item = entry.key;
        final addQty = entry.value;
        final newRefunded = item.refundedQuantity + addQty;
        await (update(saleItems)..where((i) => i.id.equals(item.id))).write(
          SaleItemsCompanion(refundedQuantity: Value(newRefunded)),
        );

        final productId = item.productId;
        if (productId == null) continue;

        final productRow = await (select(products)
              ..where((p) => p.id.equals(productId) & p.storeId.equals(storeId)))
            .getSingleOrNull();
        if (productRow == null) continue;

        await (update(products)..where((p) => p.id.equals(productId))).write(
          ProductsCompanion(
            quantity: Value(productRow.quantity + addQty),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await into(inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            id: _uuid.v4(),
            tenantId: tenantId,
            storeId: storeId,
            productId: productId,
            reasonCode: 'sale_refund',
            deltaQuantity: addQty,
            referenceType: const Value('sale'),
            referenceId: Value(saleId),
            notes: Value(reason),
          ),
        );
      }

      final newRefundedTotal = sale.refundedTotalCents + refundCents;
      await (update(sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          refundedTotalCents: Value(newRefundedTotal),
          status: const Value('partial_refund'),
        ),
      );

      await recordAuditLog(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'sale',
        entityId: saleId,
        action: 'partial_refund',
        field: 'refunded_total_cents',
        oldValue: '${sale.refundedTotalCents}',
        newValue: '$newRefundedTotal ($reason)',
        userId: userId,
      );
    });

    final updated = await getSaleById(storeId: storeId, saleId: saleId);
    final updatedItems = await listSaleItems(storeId: storeId, saleId: saleId);
    if (updated != null) {
      await enqueueSync(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'sales',
        entityId: saleId,
        operation: 'refund',
        payload: SyncPayload.sale(updated, updatedItems),
      );
    }

    return refundCents;
  }

  Stream<List<HeldSale>> watchHeldSales({
    required String tenantId,
    required String storeId,
  }) {
    return (select(heldSales)
          ..where(
            (h) => _activeScope(
              tenantCol: h.tenantId,
              storeCol: h.storeId,
              tenantId: tenantId,
              storeId: storeId,
            ),
          )
          ..orderBy([
            (h) => OrderingTerm(
              expression: h.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<void> saveHeldSale(HeldSalesCompanion row) {
    return into(heldSales).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteHeldSale(String id) {
    return (delete(heldSales)..where((h) => h.id.equals(id))).go();
  }

  Future<HeldSale?> getHeldSale(String id) {
    return (select(heldSales)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<String> upsertCategory(CategoriesCompanion row) async {
    await into(categories).insert(row, mode: InsertMode.insertOrReplace);
    final saved = await (select(categories)..where((c) => c.id.equals(row.id.value)))
        .getSingleOrNull();
    if (saved != null) {
      await enqueueSync(
        tenantId: saved.tenantId,
        storeId: saved.storeId,
        entity: 'categories',
        entityId: saved.id,
        operation: 'upsert',
        payload: SyncPayload.category(saved),
      );
    }
    return row.id.value;
  }

  Future<void> deleteCategory(String id) {
    return transaction(() async {
      final existing =
          await (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
      await (delete(categories)..where((c) => c.id.equals(id))).go();
      if (existing != null) {
        await enqueueSync(
          tenantId: existing.tenantId,
          storeId: existing.storeId,
          entity: 'categories',
          entityId: existing.id,
          operation: 'delete',
          payload: const {},
        );
      }
    });
  }

  Future<String> upsertBrand(BrandsCompanion row) async {
    await into(brands).insert(row, mode: InsertMode.insertOrReplace);
    final saved =
        await (select(brands)..where((b) => b.id.equals(row.id.value))).getSingleOrNull();
    if (saved != null) {
      await enqueueSync(
        tenantId: saved.tenantId,
        storeId: saved.storeId,
        entity: 'brands',
        entityId: saved.id,
        operation: 'upsert',
        payload: SyncPayload.brand(saved),
      );
    }
    return row.id.value;
  }

  Future<void> deleteBrand(String id) {
    return transaction(() async {
      final existing =
          await (select(brands)..where((b) => b.id.equals(id))).getSingleOrNull();
      await (delete(brands)..where((b) => b.id.equals(id))).go();
      if (existing != null) {
        await enqueueSync(
          tenantId: existing.tenantId,
          storeId: existing.storeId,
          entity: 'brands',
          entityId: existing.id,
          operation: 'delete',
          payload: const {},
        );
      }
    });
  }

  Stream<List<AuditLog>> watchAuditLogs({
    required String storeId,
    int limit = 100,
  }) {
    return (select(auditLogs)
          ..where((a) => a.storeId.equals(storeId))
          ..orderBy([
            (a) => OrderingTerm(
              expression: a.createdAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .watch();
  }

  Future<String> addCustomer(CustomersCompanion customer) async {
    await into(customers).insert(customer);
    final row = await (select(customers)
          ..where((c) => c.id.equals(customer.id.value)))
        .getSingleOrNull();
    if (row != null) {
      await enqueueSync(
        tenantId: customer.tenantId.value,
        storeId: customer.storeId.value,
        entity: 'customers',
        entityId: customer.id.value,
        operation: 'upsert',
        payload: SyncPayload.customer(row),
      );
    }
    return customer.id.value;
  }

  Future<String> addSupplier(SuppliersCompanion supplier) async {
    await into(suppliers).insert(supplier);
    final row = await (select(suppliers)
          ..where((s) => s.id.equals(supplier.id.value)))
        .getSingleOrNull();
    if (row != null) {
      await enqueueSync(
        tenantId: supplier.tenantId.value,
        storeId: supplier.storeId.value,
        entity: 'suppliers',
        entityId: supplier.id.value,
        operation: 'upsert',
        payload: SyncPayload.supplier(row),
      );
    }
    return supplier.id.value;
  }

  /// Removes queue rows from a previous tenant/store (e.g. dev-store before registration).
  Future<int> purgeSyncQueueForScope({
    required String tenantId,
    required String storeId,
  }) {
    return (delete(syncQueue)
          ..where(
            (q) =>
                q.tenantId.equals(tenantId).not() |
                q.storeId.equals(storeId).not(),
          ))
        .go();
  }

  /// Drops legacy bootstrap accounting rows that should never appear in the user queue.
  Future<int> purgeBootstrapAccountingQueueRows({
    required String tenantId,
    required String storeId,
  }) {
    return (delete(syncQueue)
          ..where(
            (q) =>
                q.tenantId.equals(tenantId) &
                q.storeId.equals(storeId) &
                q.entity.isIn(['chart_of_accounts', 'payment_accounts']),
          ))
        .go();
  }

  /// On login / store switch: keep only the active tenant+store queue.
  Future<void> cleanupForeignTenantQueueRows({
    required String tenantId,
    required String storeId,
  }) async {
    await purgeSyncQueueForScope(tenantId: tenantId, storeId: storeId);
    await purgeBootstrapAccountingQueueRows(
      tenantId: tenantId,
      storeId: storeId,
    );
  }

  /// Wipes the entire local sync queue (logout).
  Future<int> purgeAllSyncQueue() => delete(syncQueue).go();

  Expression<bool> _activeScope({
    required Expression<String> tenantCol,
    required Expression<String> storeCol,
    required String tenantId,
    required String storeId,
  }) =>
      tenantCol.equals(tenantId) & storeCol.equals(storeId);

  Expression<bool> _foreignScope({
    required Expression<String> tenantCol,
    required Expression<String> storeCol,
    required String tenantId,
    required String storeId,
  }) =>
      tenantCol.equals(tenantId).not() | storeCol.equals(storeId).not();

  /// On login / register / restore: drop rows from other tenants/stores.
  Future<void> cleanupForeignTenantData({
    required String tenantId,
    required String storeId,
  }) async {
    if (tenantId.isEmpty || storeId.isEmpty) return;

    await cleanupForeignTenantQueueRows(
      tenantId: tenantId,
      storeId: storeId,
    );

    await transaction(() async {
      final foreign = _foreignScope;
      await (delete(saleItems)
            ..where(
              (i) => foreign(
                tenantCol: i.tenantId,
                storeCol: i.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(purchaseItems)
            ..where(
              (i) => foreign(
                tenantCol: i.tenantId,
                storeCol: i.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(journalLines)
            ..where(
              (l) => foreign(
                tenantCol: l.tenantId,
                storeCol: l.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(sales)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(products)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(customers)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(suppliers)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(purchases)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(debts)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(debtPayments)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(debtShareLinks)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(expenses)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(categories)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(brands)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(inventoryMovements)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(heldSales)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(appNotifications)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeStaff)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(auditLogs)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(chartOfAccounts)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(paymentAccounts)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(journalEntries)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsQueue)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsLogs)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsReminders)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsTemplates)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeSmsWallets)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeSmsSettings)
            ..where(
              (r) => foreign(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeSettings)
            ..where(
              (s) => foreign(
                tenantCol: s.tenantId,
                storeCol: s.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await customStatement(
        'DELETE FROM sync_metadata WHERE store_id != ?',
        [storeId],
      );
    });

    if (storeId != 'dev-store') {
      await purgeLocalDataForScope(
        tenantId: 'dev-tenant',
        storeId: 'dev-store',
      );
    }
  }

  /// Wipes all cached rows for a store on logout — prevents cross-tenant leakage.
  Future<void> purgeLocalDataForScope({
    required String tenantId,
    required String storeId,
  }) async {
    final scope = _activeScope;
    await transaction(() async {
      await (delete(saleItems)
            ..where(
              (i) => scope(
                tenantCol: i.tenantId,
                storeCol: i.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(purchaseItems)
            ..where(
              (i) => scope(
                tenantCol: i.tenantId,
                storeCol: i.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(journalLines)
            ..where(
              (l) => scope(
                tenantCol: l.tenantId,
                storeCol: l.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(sales)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(products)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(customers)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(suppliers)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(purchases)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(debts)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(debtPayments)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(debtShareLinks)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(expenses)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(categories)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(brands)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(inventoryMovements)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(heldSales)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(appNotifications)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeStaff)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(auditLogs)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(chartOfAccounts)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(paymentAccounts)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(journalEntries)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsQueue)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsLogs)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsReminders)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(smsTemplates)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeSmsWallets)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeSmsSettings)
            ..where(
              (r) => scope(
                tenantCol: r.tenantId,
                storeCol: r.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(syncQueue)
            ..where(
              (q) => scope(
                tenantCol: q.tenantId,
                storeCol: q.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await (delete(storeSettings)
            ..where(
              (s) => scope(
                tenantCol: s.tenantId,
                storeCol: s.storeId,
                tenantId: tenantId,
                storeId: storeId,
              ),
            ))
          .go();
      await customStatement(
        'DELETE FROM sync_metadata WHERE store_id = ?',
        [storeId],
      );
    });
  }

  Future<int> countDebtsDueToday({required String storeId}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final count = debts.id.count();
    final row = await (selectOnly(debts)
          ..addColumns([count])
          ..where(
            debts.storeId.equals(storeId) &
                debts.remainingCents.isBiggerThanValue(0) &
                debts.dueDate.isBiggerOrEqualValue(start) &
                debts.dueDate.isSmallerThanValue(end),
          ))
        .getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countDebtsUpcoming({
    required String storeId,
    int withinDays = 7,
  }) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final end = start.add(Duration(days: withinDays));
    final count = debts.id.count();
    final row = await (selectOnly(debts)
          ..addColumns([count])
          ..where(
            debts.storeId.equals(storeId) &
                debts.remainingCents.isBiggerThanValue(0) &
                debts.dueDate.isBiggerOrEqualValue(start) &
                debts.dueDate.isSmallerThanValue(end),
          ))
        .getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> dropSyncQueueItem(int id) {
    return (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  /// Single DELETE — one Drift watch emission instead of N individual drops.
  Future<int> dropSyncQueueItems(Iterable<int> ids) {
    final list = ids.toList();
    if (list.isEmpty) return Future.value(0);
    return (delete(syncQueue)..where((q) => q.id.isIn(list))).go();
  }

  Future<void> adjustInventory({
    required String tenantId,
    required String storeId,
    required String productId,
    required int deltaQuantity,
    required String reasonCode,
    String? notes,
  }) async {
    await transaction(() async {
      final now = DateTime.now();
      final updated = await customUpdate(
        'UPDATE products SET quantity = quantity + ?, updated_at = ? '
        'WHERE id = ? AND store_id = ? AND quantity + ? >= 0',
        variables: [
          Variable(deltaQuantity),
          Variable(now),
          Variable(productId),
          Variable(storeId),
          Variable(deltaQuantity),
        ],
        updates: {products},
      );
      if (updated == 0) return;

      final productRow = await (select(products)
            ..where((p) => p.id.equals(productId) & p.storeId.equals(storeId)))
          .getSingle();
      final newQty = productRow.quantity;

      await into(inventoryMovements).insert(
        InventoryMovementsCompanion.insert(
          id: _uuid.v4(),
          tenantId: tenantId,
          storeId: storeId,
          productId: productId,
          reasonCode: reasonCode,
          deltaQuantity: deltaQuantity,
          referenceType: const Value('adjustment'),
          notes: Value(notes),
        ),
      );

      if (productRow.minStockAlert != null &&
          newQty < productRow.minStockAlert!) {
        await into(appNotifications).insert(
          AppNotificationsCompanion.insert(
            tenantId: tenantId,
            storeId: storeId,
            type: 'low_stock',
            title: 'Low stock: ${productRow.name}',
            body: 'Quantity $newQty is below alert ${productRow.minStockAlert}.',
          ),
        );
      }
    });
  }

  Stream<List<Purchase>> watchPurchases({required String storeId}) {
    return (select(purchases)
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([
            (p) => OrderingTerm(expression: p.purchaseDate, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<AppNotification>> watchNotifications({required String storeId}) {
    return (select(appNotifications)
          ..where((n) => n.storeId.equals(storeId))
          ..orderBy([
            (n) => OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(100))
        .watch();
  }

  Future<void> markNotificationRead(int id) async {
    await (update(appNotifications)..where((n) => n.id.equals(id))).write(
      const AppNotificationsCompanion(isRead: Value(true)),
    );
  }

  Future<void> insertAppNotification({
    required String tenantId,
    required String storeId,
    required String type,
    required String title,
    required String body,
  }) async {
    await into(appNotifications).insert(
      AppNotificationsCompanion.insert(
        tenantId: tenantId,
        storeId: storeId,
        type: type,
        title: title,
        body: body,
      ),
    );
  }

  Future<List<MapEntry<String, int>>> topSellingProducts({
    required String storeId,
    required DateTime from,
    required DateTime to,
    int limit = 5,
  }) async {
    final joinQ = select(sales).join([
      innerJoin(saleItems, saleItems.saleId.equalsExp(sales.id)),
    ])
      ..where(sales.storeId.equals(storeId))
      ..where(sales.createdAt.isBiggerOrEqualValue(from))
      ..where(sales.createdAt.isSmallerOrEqualValue(to));

    final rows = await joinQ.get();
    final totals = <String, int>{};
    for (final r in rows) {
      final item = r.readTable(saleItems);
      final key = item.name;
      totals[key] = (totals[key] ?? 0) + item.quantity;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  Future<String?> createCustomerDebtForSale({
    required String tenantId,
    required String storeId,
    required String customerId,
    required String saleId,
    required int totalCents,
    required int paidCents,
    String? invoiceNumber,
    DateTime? dueDate,
  }) async {
    final remaining = totalCents - paidCents;
    if (remaining <= 0 || customerId.isEmpty) return null;

    final debtId = _uuid.v4();
    final status = paidCents > 0 ? 'partially_paid' : 'active';
    await into(debts).insert(
      DebtsCompanion.insert(
        id: debtId,
        tenantId: tenantId,
        storeId: storeId,
        debtType: 'customer',
        customerId: Value(customerId),
        originalCents: totalCents,
        paidCents: Value(paidCents),
        remainingCents: remaining,
        status: status,
        saleId: Value(saleId),
        invoiceNumber: Value(invoiceNumber ?? saleId.substring(0, 8)),
        dueDate: Value(dueDate),
        notes: const Value('POS sale on credit / partial payment.'),
      ),
    );
    return debtId;
  }

  Future<void> updateSalePaymentFields({
    required String saleId,
    required int paidCents,
    required String paymentStatus,
  }) async {
    await (update(sales)..where((s) => s.id.equals(saleId))).write(
      SalesCompanion(
        paidCents: Value(paidCents),
        paymentStatus: Value(paymentStatus),
      ),
    );
  }

  Future<Debt?> getDebtBySaleId({
    required String storeId,
    required String saleId,
  }) {
    return (select(debts)
          ..where(
            (d) =>
                d.storeId.equals(storeId) &
                d.saleId.equals(saleId) &
                d.debtType.equals('customer'),
          ))
        .getSingleOrNull();
  }

  Future<List<Debt>> listCustomerDebts({
    required String storeId,
    required String customerId,
  }) {
    return (select(debts)
          ..where(
            (d) =>
                d.storeId.equals(storeId) &
                d.customerId.equals(customerId) &
                d.debtType.equals('customer'),
          )
          ..orderBy([
            (d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Stream<List<Debt>> watchDebtsForCustomer({
    required String storeId,
    required String customerId,
  }) {
    return (select(debts)
          ..where(
            (d) =>
                d.storeId.equals(storeId) &
                d.customerId.equals(customerId) &
                d.debtType.equals('customer'),
          )
          ..orderBy([
            (d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Debt>> watchDebtsForSupplier({
    required String storeId,
    required String supplierId,
  }) {
    return (select(debts)
          ..where(
            (d) =>
                d.storeId.equals(storeId) &
                d.supplierId.equals(supplierId) &
                d.debtType.equals('supplier'),
          )
          ..orderBy([
            (d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<DebtPayment>> watchPaymentsForDebt({required String debtId}) {
    return (select(debtPayments)
          ..where((p) => p.debtId.equals(debtId))
          ..orderBy([
            (p) => OrderingTerm(expression: p.paidAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<DebtPayment>> watchPaymentsForStore({required String storeId}) {
    return (select(debtPayments)
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([
            (p) => OrderingTerm(expression: p.paidAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<DebtPayment>> listPaymentsForCustomer({
    required String storeId,
    required String customerId,
  }) async {
    final customerDebts = await (select(debts)
          ..where(
            (d) =>
                d.storeId.equals(storeId) &
                d.customerId.equals(customerId) &
                d.debtType.equals('customer'),
          ))
        .get();
    if (customerDebts.isEmpty) return [];
    final ids = customerDebts.map((d) => d.id).toList();
    return (select(debtPayments)
          ..where((p) => p.debtId.isIn(ids))
          ..orderBy([
            (p) => OrderingTerm(expression: p.paidAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<int> sumOpenCustomerReceivables({required String storeId}) async {
    final rows = await (selectOnly(debts)
          ..addColumns([debts.remainingCents.sum()])
          ..where(
            debts.storeId.equals(storeId) &
                debts.debtType.equals('customer') &
                debts.remainingCents.isBiggerThanValue(0),
          ))
        .getSingle();
    return rows.read(debts.remainingCents.sum()) ?? 0;
  }

  Future<int> sumOpenSupplierPayables({required String storeId}) async {
    final rows = await (selectOnly(debts)
          ..addColumns([debts.remainingCents.sum()])
          ..where(
            debts.storeId.equals(storeId) &
                debts.debtType.equals('supplier') &
                debts.remainingCents.isBiggerThanValue(0),
          ))
        .getSingle();
    return rows.read(debts.remainingCents.sum()) ?? 0;
  }

  Future<int> countOverdueDebts({required String storeId}) async {
    final now = DateTime.now();
    final count = debts.id.count();
    final row = await (selectOnly(debts)
          ..addColumns([count])
          ..where(
            debts.storeId.equals(storeId) &
                debts.remainingCents.isBiggerThanValue(0) &
                debts.dueDate.isSmallerThanValue(now),
          ))
        .getSingle();
    return row.read(count) ?? 0;
  }

  Future<Customer?> getCustomerById({
    required String storeId,
    required String customerId,
  }) {
    return (select(customers)
          ..where(
            (c) => c.id.equals(customerId) & c.storeId.equals(storeId),
          ))
        .getSingleOrNull();
  }

  Future<String> ensureDebtShareLink({
    required String tenantId,
    required String storeId,
    required String customerId,
    String? debtId,
  }) async {
    final existing = await (select(debtShareLinks)
          ..where(
            (l) =>
                l.storeId.equals(storeId) &
                l.customerId.equals(customerId) &
                (debtId == null
                    ? l.debtId.isNull()
                    : l.debtId.equals(debtId)),
          )
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.token;

    final token = _shareToken();
    await into(debtShareLinks).insert(
      DebtShareLinksCompanion.insert(
        id: _uuid.v4(),
        tenantId: tenantId,
        storeId: storeId,
        token: token,
        customerId: customerId,
        debtId: Value(debtId),
      ),
    );
    return token;
  }

  String _shareToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = DateTime.now().microsecondsSinceEpoch;
    final buf = StringBuffer();
    var n = r;
    for (var i = 0; i < 8; i++) {
      buf.write(chars[n % chars.length]);
      n ~/= chars.length;
    }
    return buf.toString();
  }

  Future<DebtShareLink?> getShareLinkByToken(String token) {
    return (select(debtShareLinks)..where((l) => l.token.equals(token)))
        .getSingleOrNull();
  }

  Future<void> recordDebtPayment({
    required String debtId,
    required String tenantId,
    required String storeId,
    required int amountCents,
    String? method,
    String? notes,
    String? paymentAccountId,
    String? userId,
  }) async {
    if (amountCents <= 0) return;

    await transaction(() async {
      final debtRow =
          await (select(debts)..where((d) => d.id.equals(debtId))).getSingle();

      final newPaid = debtRow.paidCents + amountCents;
      final newRemaining = (debtRow.remainingCents - amountCents);
      final remaining = newRemaining < 0 ? 0 : newRemaining;
      final status = remaining == 0
          ? 'paid'
          : (newPaid > 0 ? 'partially_paid' : 'active');

      await (update(debts)..where((d) => d.id.equals(debtId))).write(
        DebtsCompanion(
          paidCents: Value(newPaid),
          remainingCents: Value(remaining),
          status: Value(status),
        ),
      );

      await into(debtPayments).insert(
        DebtPaymentsCompanion.insert(
          id: _uuid.v4(),
          tenantId: tenantId,
          storeId: storeId,
          debtId: debtId,
          amountCents: amountCents,
          paidAt: DateTime.now(),
          method: Value(method),
          paymentAccountId: Value(paymentAccountId),
          notes: Value(notes),
          userId: Value(userId),
        ),
      );

      if (debtRow.saleId != null && debtRow.saleId!.isNotEmpty) {
        final saleRow = await (select(sales)
              ..where((s) => s.id.equals(debtRow.saleId!)))
            .getSingleOrNull();
        if (saleRow != null) {
          final salePaid = saleRow.paidCents + amountCents;
          final saleRemaining = saleRow.totalCents - salePaid;
          final saleStatus = saleRemaining <= 0
              ? 'paid'
              : (salePaid > 0 ? 'partially_paid' : 'unpaid');
          await (update(sales)..where((s) => s.id.equals(saleRow.id))).write(
            SalesCompanion(
              paidCents: Value(salePaid.clamp(0, saleRow.totalCents)),
              paymentStatus: Value(saleStatus),
            ),
          );
        }
      }

      await into(syncQueue).insert(
        SyncQueueCompanion.insert(
          tenantId: tenantId,
          storeId: storeId,
          entity: 'debt_payments',
          entityId: debtId,
          operation: 'append',
          payloadJson: '{}',
        ),
      );
    });
  }

  Future<void> upsertProduct(ProductsCompanion product) async {
    await into(products).insert(
      product,
      mode: InsertMode.insertOrReplace,
    );
    final row = await (select(products)
          ..where((p) => p.id.equals(product.id.value)))
        .getSingleOrNull();
    if (row != null) {
      await enqueueSync(
        tenantId: row.tenantId,
        storeId: row.storeId,
        entity: 'products',
        entityId: row.id,
        operation: 'upsert',
        payload: SyncPayload.product(row),
      );
    }
  }

  Future<Product?> getProductById({
    required String storeId,
    required String productId,
  }) {
    return (select(products)
          ..where((p) => p.storeId.equals(storeId) & p.id.equals(productId)))
        .getSingleOrNull();
  }

  Future<List<InventoryMovement>> listInventoryMovementsForProduct({
    required String storeId,
    required String productId,
    int limit = 100,
  }) {
    return (select(inventoryMovements)
          ..where(
            (m) => m.storeId.equals(storeId) & m.productId.equals(productId),
          )
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Purchase lines for a product, newest first.
  Future<
      List<
          ({
            Purchase purchase,
            PurchaseItem item,
            String? supplierName,
          })>> listProductPurchaseHistory({
    required String storeId,
    required String productId,
    int limit = 50,
  }) async {
    final query = select(purchaseItems).join([
      innerJoin(
        purchases,
        purchases.id.equalsExp(purchaseItems.purchaseId),
      ),
      leftOuterJoin(
        suppliers,
        suppliers.id.equalsExp(purchases.supplierId),
      ),
    ])
      ..where(
        purchaseItems.storeId.equals(storeId) &
            purchaseItems.productId.equals(productId),
      )
      ..orderBy([OrderingTerm.desc(purchases.purchaseDate)])
      ..limit(limit);

    final rows = await query.get();
    return [
      for (final row in rows)
        (
          purchase: row.readTable(purchases),
          item: row.readTable(purchaseItems),
          supplierName: row.readTableOrNull(suppliers)?.name,
        ),
    ];
  }

  Future<Product?> findProductByBarcode({
    required String storeId,
    required String barcode,
  }) {
    final code = barcode.trim();
    if (code.isEmpty) return Future.value(null);
    return (select(products)
          ..where(
            (p) =>
                p.storeId.equals(storeId) &
                (p.barcode.equals(code) | p.sku.equals(code)),
          ))
        .getSingleOrNull();
  }

  Future<bool> isBarcodeTaken({
    required String storeId,
    required String barcode,
    String? excludeProductId,
  }) async {
    final code = barcode.trim();
    if (code.isEmpty) return false;
    final q = select(products)
      ..where((p) => p.storeId.equals(storeId) & p.barcode.equals(code));
    if (excludeProductId != null) {
      q.where((p) => p.id.equals(excludeProductId).not());
    }
    final row = await q.getSingleOrNull();
    return row != null;
  }

  Future<void> recordScanHit({
    required String productId,
    required String storeId,
  }) async {
    final row = await (select(products)
          ..where((p) => p.id.equals(productId) & p.storeId.equals(storeId)))
        .getSingleOrNull();
    if (row == null) return;
    await (update(products)..where((p) => p.id.equals(productId))).write(
      ProductsCompanion(
        scanCount: Value(row.scanCount + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<StoreStaffData>> listStoreStaffRows({required String storeId}) {
    return (select(storeStaff)
          ..where((s) => s.storeId.equals(storeId))
          ..orderBy([(s) => OrderingTerm(expression: s.fullName)]))
        .get();
  }

  Future<StoreStaffData?> getStoreStaffRow({required String id}) {
    return (select(storeStaff)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertStoreStaff({
    required String id,
    required String tenantId,
    required String storeId,
    required String email,
    required String fullName,
    String? phone,
    required String roleId,
    String? password,
    bool isActive = true,
  }) async {
    final hash = password != null ? _simpleHash(password) : null;
    await into(storeStaff).insertOnConflictUpdate(
      StoreStaffCompanion.insert(
        id: id,
        tenantId: tenantId,
        storeId: storeId,
        email: email,
        fullName: fullName,
        phone: Value(phone),
        roleId: roleId,
        passwordHash: Value(hash),
        isActive: Value(isActive),
        status: const Value('active'),
      ),
    );
  }

  Future<void> updateStoreStaff({
    required String id,
    String? fullName,
    String? phone,
    String? roleId,
    bool? isActive,
  }) async {
    await (update(storeStaff)..where((s) => s.id.equals(id))).write(
      StoreStaffCompanion(
        fullName: fullName != null ? Value(fullName) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        roleId: roleId != null ? Value(roleId) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        status: isActive == false
            ? const Value('suspended')
            : const Value.absent(),
      ),
    );
  }

  Future<void> setStoreStaffPermissions(
    String id,
    Map<String, bool> permissions,
  ) async {
    final encoded = permissions.entries
        .map((e) => '${e.key}:${e.value ? 1 : 0}')
        .join(',');
    await (update(storeStaff)..where((s) => s.id.equals(id))).write(
      StoreStaffCompanion(customPermissionsJson: Value(encoded)),
    );
  }

  Future<void> setStoreStaffFullPermissions(String id, Set<String> grants) async {
    final encoded = 'full:${grants.join(',')}';
    await (update(storeStaff)..where((s) => s.id.equals(id))).write(
      StoreStaffCompanion(customPermissionsJson: Value(encoded)),
    );
  }

  String _simpleHash(String input) =>
      input.codeUnits.fold<int>(0, (a, b) => a + b).toString();

  Future<void> recordAuditLog({
    required String tenantId,
    required String storeId,
    required String entity,
    required String entityId,
    required String action,
    String? field,
    String? oldValue,
    String? newValue,
    String? userId,
  }) {
    return into(auditLogs).insert(
      AuditLogsCompanion.insert(
        tenantId: tenantId,
        storeId: storeId,
        userId: Value(userId),
        entity: entity,
        entityId: entityId,
        action: action,
        field: Value(field),
        oldValue: Value(oldValue),
        newValue: Value(newValue),
      ),
    );
  }

  Future<List<Product>> listProducts({required String storeId, int limit = 50}) {
    return (select(products)
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([(p) => OrderingTerm(expression: p.updatedAt, mode: OrderingMode.desc)])
          ..limit(limit))
        .get();
  }

  /// POS catalog search — bounded, index-friendly, no table stream.
  Future<List<Product>> searchProductsForPos({
    required String storeId,
    String query = '',
    int limit = 60,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return (select(products)
            ..where((p) => p.storeId.equals(storeId))
            ..orderBy([
              (p) => OrderingTerm(
                expression: p.scanCount,
                mode: OrderingMode.desc,
              ),
              (p) => OrderingTerm(expression: p.name),
            ])
            ..limit(limit))
          .get();
    }

    final barcodeNeedle = q.length < 3 ? '$q%' : '%$q%';
    return (select(products)
          ..where((p) => p.storeId.equals(storeId))
          ..where(
            (p) =>
                p.barcode.like(barcodeNeedle) |
                p.sku.like(barcodeNeedle) |
                p.name.like('%$q%'),
          )
          ..orderBy([(p) => OrderingTerm(expression: p.name)])
          ..limit(limit))
        .get();
  }

  /// Keyset-paginated product catalog (products page).
  Future<ProductSearchPage> fetchProductPage({
    required String storeId,
    String query = '',
    String? brandId,
    ProductListFilter filter = ProductListFilter.all,
    ProductPageCursor? cursor,
    int limit = 48,
  }) async {
    final q = query.trim().toLowerCase();
    final base = select(products)..where((p) => p.storeId.equals(storeId));

    switch (filter) {
      case ProductListFilter.lowStock:
        base
          ..where((p) => p.minStockAlert.isNotNull())
          ..where((p) => p.quantity.isSmallerThan(p.minStockAlert))
          ..where((p) => p.quantity.isBiggerThanValue(0));
      case ProductListFilter.outOfStock:
        base.where((p) => p.quantity.isSmallerOrEqualValue(0));
      case ProductListFilter.all:
        break;
    }

    if (brandId != null) {
      base.where((p) => p.brandId.equals(brandId));
    }
    if (q.isNotEmpty) {
      final barcodeNeedle = q.length < 3 ? '$q%' : '%$q%';
      base.where(
        (p) =>
            p.barcode.like(barcodeNeedle) |
            p.sku.like(barcodeNeedle) |
            p.name.like('%$q%'),
      );
    }
    if (cursor != null) {
      base.where(
        (p) =>
            p.updatedAt.isSmallerThanValue(cursor.updatedAt) |
            (p.updatedAt.equals(cursor.updatedAt) &
                p.id.isSmallerThanValue(cursor.id)),
      );
    }
    base
      ..orderBy([
        (p) => OrderingTerm(expression: p.updatedAt, mode: OrderingMode.desc),
        (p) => OrderingTerm(expression: p.id, mode: OrderingMode.desc),
      ])
      ..limit(limit + 1);

    final rows = await base.get();
    final hasMore = rows.length > limit;
    final page = hasMore ? rows.sublist(0, limit) : rows;
    ProductPageCursor? next;
    if (hasMore && page.isNotEmpty) {
      final last = page.last;
      next = ProductPageCursor(updatedAt: last.updatedAt, id: last.id);
    }
    return ProductSearchPage(items: page, nextCursor: next);
  }

  /// Barcode lookup — single indexed row, target <300ms.
  Future<Product?> findProductByBarcodeFast({
    required String storeId,
    required String barcode,
  }) {
    return findProductByBarcode(storeId: storeId, barcode: barcode);
  }

  Future<void> createSaleWithItems({
    required SalesCompanion sale,
    required List<SaleItemsCompanion> items,
  }) async {
    await transaction(() async {
      await into(sales).insert(sale);
      await batch((b) {
        b.insertAll(saleItems, items);
      });

      final now = DateTime.now();
      for (final item in items) {
        final productId = item.productId.present ? item.productId.value : null;
        if (productId == null) continue;

        final delta = item.quantity.value;
        var updated = await customUpdate(
          'UPDATE products SET quantity = quantity - ?, updated_at = ? '
          'WHERE id = ? AND store_id = ? AND quantity >= ?',
          variables: [
            Variable(delta),
            Variable(now),
            Variable(productId),
            Variable(sale.storeId.value),
            Variable(delta),
          ],
          updates: {products},
        );
        if (updated == 0) {
          final product = await (select(products)
                ..where(
                  (p) =>
                      p.id.equals(productId) &
                      p.storeId.equals(sale.storeId.value),
                ))
              .getSingleOrNull();
          throw InsufficientStockException(
            productId: productId,
            requested: delta,
            available: product?.quantity,
          );
        }

        // movement log
        await into(inventoryMovements).insert(
          InventoryMovementsCompanion.insert(
            id: _uuid.v4(),
            tenantId: sale.tenantId.value,
            storeId: sale.storeId.value,
            productId: productId,
            reasonCode: 'sale',
            deltaQuantity: -item.quantity.value,
            referenceType: const Value('sale'),
            referenceId: Value(sale.id.value),
          ),
        );
      }

    });

    final savedSale = await getSaleById(
      storeId: sale.storeId.value,
      saleId: sale.id.value,
    );
    final savedItems = await listSaleItems(
      storeId: sale.storeId.value,
      saleId: sale.id.value,
    );
    if (savedSale != null) {
      await enqueueSync(
        tenantId: sale.tenantId.value,
        storeId: sale.storeId.value,
        entity: 'sales',
        entityId: sale.id.value,
        operation: 'upsert',
        payload: SyncPayload.sale(savedSale, savedItems),
      );
    }
  }

  Stream<List<Expense>> watchExpenses({
    required String storeId,
    DateTime? from,
    DateTime? to,
  }) {
    final q = select(expenses)..where((e) => e.storeId.equals(storeId));
    if (from != null) q.where((e) => e.expenseDate.isBiggerOrEqualValue(from));
    if (to != null) q.where((e) => e.expenseDate.isSmallerOrEqualValue(to));
    q.orderBy([(e) => OrderingTerm(expression: e.expenseDate, mode: OrderingMode.desc)]);
    return q.watch();
  }

  // ---------------------------------------------------------------------------
  // Cloud sync helpers (pull — no enqueue)
  // ---------------------------------------------------------------------------

  Future<DateTime?> getLastPulledAt({
    required String storeId,
    required String entity,
  }) async {
    final rows = await customSelect(
      'SELECT last_pulled_at FROM sync_metadata WHERE store_id = ? AND entity = ?',
      variables: [Variable(storeId), Variable(entity)],
      readsFrom: {},
    ).get();
    if (rows.isEmpty) return null;
    return SafeDateTime.tryParse(rows.first.read<String>('last_pulled_at'));
  }

  Future<void> setLastPulledAt({
    required String storeId,
    required String entity,
    required DateTime at,
  }) async {
    await customStatement(
      'INSERT OR REPLACE INTO sync_metadata (store_id, entity, last_pulled_at) VALUES (?, ?, ?)',
      [storeId, entity, at.toUtc().toIso8601String()],
    );
  }

  Future<void> resetFailedSyncRetries({required String storeId}) async {
    await (update(syncQueue)
          ..where(
            (q) => q.storeId.equals(storeId) & q.retryCount.isBiggerThanValue(0),
          ))
        .write(
      const SyncQueueCompanion(
        retryCount: Value(0),
        lastError: Value(null),
      ),
    );
  }

  Future<void> clearSyncHydrationCache({required String storeId}) async {
    await customStatement(
      'DELETE FROM sync_metadata WHERE store_id = ?',
      [storeId],
    );
  }

  Future<void> rebuildLocalIndexes() async {
    await customStatement('REINDEX');
    await customStatement('ANALYZE');
  }

  Future<bool> hasPendingSyncForEntity({
    required String storeId,
    required String entity,
    required String entityId,
  }) async {
    final row = await (select(syncQueue)
          ..where(
            (q) =>
                q.storeId.equals(storeId) &
                q.entity.equals(entity) &
                q.entityId.equals(entityId),
          ))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> upsertProductFromCloud(ProductsCompanion product) async {
    await into(products).insert(product, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertCustomerFromCloud(CustomersCompanion customer) async {
    await into(customers).insert(customer, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertSupplierFromCloud(SuppliersCompanion supplier) async {
    await into(suppliers).insert(supplier, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertStoreSettingsFromCloud(
    StoreSettingsCompanion patch,
  ) async {
    await upsertStoreSettings(patch);
  }

  Future<bool> _hasStockDeductionForSale(String saleId) async {
    final count = await (selectOnly(inventoryMovements)
          ..addColumns([inventoryMovements.id.count()])
          ..where(
            inventoryMovements.referenceId.equals(saleId) &
                inventoryMovements.referenceType.equals('sale'),
          ))
        .getSingle();
    return (count.read(inventoryMovements.id.count()) ?? 0) > 0;
  }

  /// Imports a cloud sale. When [applyStockDeduction] is true, deducts local
  /// stock once per sale_id (deduped via inventory_movements).
  Future<bool> upsertSaleFromCloud({
    required SalesCompanion sale,
    required List<SaleItemsCompanion> items,
    bool applyStockDeduction = false,
  }) async {
    final saleId = sale.id.value;
    final storeId = sale.storeId.value;
    final tenantId = sale.tenantId.value;
    final status = sale.status.present ? sale.status.value : 'completed';
    final stockAlreadyApplied = await _hasStockDeductionForSale(saleId);
    var stockApplied = false;

    await transaction(() async {
      await into(sales).insert(sale, mode: InsertMode.insertOrReplace);
      await (delete(saleItems)..where((i) => i.saleId.equals(saleId))).go();
      for (final item in items) {
        await into(saleItems).insert(item, mode: InsertMode.insertOrReplace);
      }

      if (applyStockDeduction &&
          !stockAlreadyApplied &&
          status != 'voided' &&
          status != 'void') {
        final now = DateTime.now();
        for (final item in items) {
          final productId =
              item.productId.present ? item.productId.value : null;
          if (productId == null) continue;
          final delta = item.quantity.value;
          if (delta <= 0) continue;

          final updated = await customUpdate(
            'UPDATE products SET quantity = quantity - ?, updated_at = ? '
            'WHERE id = ? AND store_id = ? AND quantity >= ?',
            variables: [
              Variable(delta),
              Variable(now),
              Variable(productId),
              Variable(storeId),
              Variable(delta),
            ],
            updates: {products},
          );
          if (updated > 0) {
            await into(inventoryMovements).insert(
              InventoryMovementsCompanion.insert(
                id: _uuid.v4(),
                tenantId: tenantId,
                storeId: storeId,
                productId: productId,
                reasonCode: 'sale',
                deltaQuantity: -delta,
                referenceType: const Value('sale'),
                referenceId: Value(saleId),
              ),
            );
            stockApplied = true;
          }
        }
      }
    });

    return stockApplied;
  }

  Future<void> upsertPurchaseFromCloud({
    required PurchasesCompanion purchase,
    required List<PurchaseItemsCompanion> items,
  }) async {
    await transaction(() async {
      await into(purchases).insert(purchase, mode: InsertMode.insertOrReplace);
      final purchaseId = purchase.id.value;
      await (delete(purchaseItems)
            ..where((i) => i.purchaseId.equals(purchaseId)))
          .go();
      for (final item in items) {
        await into(purchaseItems).insert(item, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Stream<int> watchPendingSyncCount({
    required String tenantId,
    required String storeId,
  }) {
    return (select(syncQueue)
          ..where(
            (q) =>
                q.tenantId.equals(tenantId) & q.storeId.equals(storeId),
          ))
        .watch()
        .map((rows) => rows.length);
  }

  Stream<List<SyncQueueData>> watchSyncQueue({
    required String tenantId,
    required String storeId,
  }) {
    return (select(syncQueue)
          ..where(
            (q) =>
                q.tenantId.equals(tenantId) & q.storeId.equals(storeId),
          )
          ..orderBy([
            (q) => OrderingTerm(expression: q.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<Expense?> getExpenseById(String id) {
    return (select(expenses)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<void> addExpense(ExpensesCompanion expense) async {
    await into(expenses).insert(expense);
    await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        tenantId: expense.tenantId.value,
        storeId: expense.storeId.value,
        entity: 'expenses',
        entityId: expense.id.value,
        operation: 'upsert',
        payloadJson: '{}',
      ),
    );
  }

  List<Variable<Object>> _saleRangeVariables({
    required String tenantId,
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) =>
      [
        Variable<String>(tenantId),
        Variable<String>(storeId),
        Variable<DateTime>(from),
        Variable<DateTime>(to),
      ];

  Future<int> sumSalesTotalCents({
    required String tenantId,
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final row = await customSelect(
      '''
      SELECT COALESCE(SUM(total_cents - refunded_total_cents), 0) AS total
      FROM sales
      WHERE tenant_id = ? AND store_id = ? AND status != 'voided'
        AND created_at >= ? AND created_at < ?
      ''',
      variables: _saleRangeVariables(
        tenantId: tenantId,
        storeId: storeId,
        from: from,
        to: to,
      ),
      readsFrom: {sales},
    ).getSingle();
    return row.read<int>('total');
  }

  Future<int> sumExpensesCents({
    required String tenantId,
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await (selectOnly(expenses)
          ..addColumns([expenses.amountCents.sum()])
          ..where(
            expenses.tenantId.equals(tenantId) & expenses.storeId.equals(storeId),
          )
          ..where(expenses.expenseDate.isBiggerOrEqualValue(from))
          ..where(expenses.expenseDate.isSmallerOrEqualValue(to)))
        .getSingle();
    return res.read(expenses.amountCents.sum()) ?? 0;
  }

  Future<int> sumCogsCents({
    required String tenantId,
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final row = await customSelect(
      '''
      SELECT COALESCE(SUM(si.unit_cost_cents * si.quantity), 0) AS total
      FROM sale_items si
      INNER JOIN sales s ON s.id = si.sale_id
      WHERE s.tenant_id = ? AND s.store_id = ? AND s.status = 'completed'
        AND s.created_at >= ? AND s.created_at < ?
      ''',
      variables: _saleRangeVariables(
        tenantId: tenantId,
        storeId: storeId,
        from: from,
        to: to,
      ),
      readsFrom: {sales, saleItems},
    ).getSingle();
    return row.read<int>('total');
  }

  /// Batched dashboard metrics (parallel SQL aggregates).
  Future<DashboardMetricsSnapshot> fetchDashboardMetrics({
    required String tenantId,
    required String storeId,
  }) async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);
    final trendStart = startOfToday.subtract(const Duration(days: 6));

    final results = await Future.wait<Object>([
      sumSalesTotalCents(
        tenantId: tenantId,
        storeId: storeId,
        from: startOfToday,
        to: startOfTomorrow,
      ),
      sumSalesTotalCents(
        tenantId: tenantId,
        storeId: storeId,
        from: startOfMonth,
        to: startOfNextMonth,
      ),
      sumExpensesCents(
        tenantId: tenantId,
        storeId: storeId,
        from: startOfToday,
        to: startOfTomorrow,
      ),
      sumExpensesCents(
        tenantId: tenantId,
        storeId: storeId,
        from: startOfMonth,
        to: startOfNextMonth,
      ),
      sumCogsCents(
        tenantId: tenantId,
        storeId: storeId,
        from: startOfMonth,
        to: startOfNextMonth,
      ),
      sumSalesByDay(
        tenantId: tenantId,
        storeId: storeId,
        from: trendStart,
        to: startOfTomorrow,
      ),
    ]);

    final todaySales = results[0] as int;
    final monthSales = results[1] as int;
    final todayExpenses = results[2] as int;
    final monthExpenses = results[3] as int;
    final monthCogs = results[4] as int;
    final trendByDay = results[5] as Map<DateTime, int>;

    final trendPoints = <DailySalesMetric>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(
        startOfToday.year,
        startOfToday.month,
        startOfToday.day - i,
      );
      trendPoints.add(
        DailySalesMetric(
          day: day,
          totalCents: trendByDay[day] ?? 0,
        ),
      );
    }

    return DashboardMetricsSnapshot(
      todaySalesCents: todaySales,
      monthSalesCents: monthSales,
      todayExpensesCents: todayExpenses,
      monthExpensesCents: monthExpenses,
      monthCogsCents: monthCogs,
      monthProfitCents: monthSales - monthCogs - monthExpenses,
      salesTrend: trendPoints,
    );
  }

  /// One query for 7-day chart instead of N round-trips.
  Future<Map<DateTime, int>> sumSalesByDay({
    required String tenantId,
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await customSelect(
      '''
      SELECT date(created_at, 'unixepoch', 'localtime') AS day,
             COALESCE(SUM(total_cents - refunded_total_cents), 0) AS total
      FROM sales
      WHERE tenant_id = ? AND store_id = ? AND status != 'voided'
        AND created_at >= ? AND created_at < ?
      GROUP BY date(created_at, 'unixepoch', 'localtime')
      ''',
      variables: _saleRangeVariables(
        tenantId: tenantId,
        storeId: storeId,
        from: from,
        to: to,
      ),
      readsFrom: {sales},
    ).get();

    final out = <DateTime, int>{};
    for (final row in rows) {
      final dayStr = row.read<String>('day');
      final parsed = SafeDateTime.tryParse(dayStr);
      if (parsed == null) continue;
      final day = DateTime(parsed.year, parsed.month, parsed.day);
      out[day] = row.read<int>('total');
    }
    return out;
  }

  Future<List<Product>> listLowStockProducts({
    required String tenantId,
    required String storeId,
    int limit = 10,
  }) {
    return (select(products)
          ..where(
            (p) => _activeScope(
              tenantCol: p.tenantId,
              storeCol: p.storeId,
              tenantId: tenantId,
              storeId: storeId,
            ),
          )
          ..where((p) => p.minStockAlert.isNotNull())
          ..where((p) => p.quantity.isSmallerThan(p.minStockAlert))
          ..orderBy([(p) => OrderingTerm(expression: p.quantity)])
          ..limit(limit))
        .get();
  }

  Future<int> countProducts({
    required String tenantId,
    required String storeId,
  }) async {
    final res = await (selectOnly(products)
          ..addColumns([products.id.count()])
          ..where(
            products.tenantId.equals(tenantId) & products.storeId.equals(storeId),
          ))
        .getSingle();
    return res.read(products.id.count()) ?? 0;
  }

  Future<int> countOutOfStockProducts({required String storeId}) async {
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS c FROM products
      WHERE store_id = ? AND quantity <= 0
      ''',
      variables: [Variable(storeId)],
      readsFrom: {products},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<ProductInventoryCounts> productInventoryCounts({
    required String tenantId,
    required String storeId,
  }) async {
    final results = await Future.wait<int>([
      countProducts(tenantId: tenantId, storeId: storeId),
      countLowStockProducts(storeId: storeId),
      countOutOfStockProducts(storeId: storeId),
    ]);
    return ProductInventoryCounts(
      total: results[0],
      lowStock: results[1],
      outOfStock: results[2],
    );
  }

  Future<int> countLowStockProducts({required String storeId}) async {
    final row = await customSelect(
      '''
      SELECT COUNT(*) AS c FROM products
      WHERE store_id = ? AND min_stock_alert IS NOT NULL
        AND quantity < min_stock_alert
      ''',
      variables: [Variable(storeId)],
      readsFrom: {products},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<int> sumInventoryValueAtCostCents({required String storeId}) async {
    final rows = await (select(products)..where((p) => p.storeId.equals(storeId)))
        .get();
    var total = 0;
    for (final p in rows) {
      total += p.quantity * p.purchasePriceCents;
    }
    return total;
  }

  Future<List<Sale>> listRecentSales({
    required String tenantId,
    required String storeId,
    int limit = 10,
  }) {
    return (select(sales)
          ..where(
            (s) => _activeScope(
              tenantCol: s.tenantId,
              storeCol: s.storeId,
              tenantId: tenantId,
              storeId: storeId,
            ),
          )
          ..where((s) => s.status.equals('completed'))
          ..orderBy([
            (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Stream<List<Sale>> watchSales({
    required String storeId,
    DateTime? from,
    DateTime? to,
  }) {
    final q = select(sales)..where((s) => s.storeId.equals(storeId));
    if (from != null) {
      q.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      q.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    q.orderBy([
      (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
    ]);
    return q.watch();
  }

  Future<List<Sale>> listSales({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) {
    return (select(sales)
          ..where((s) => s.storeId.equals(storeId))
          ..where((s) => s.createdAt.isBiggerOrEqualValue(from))
          ..where((s) => s.createdAt.isSmallerOrEqualValue(to))
          ..orderBy([
            (s) => OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Keyset-paginated sales with customer join (sales history table).
  Future<SaleSearchPage> fetchSalesPage({
    required String storeId,
    required DateTime from,
    required DateTime to,
    String query = '',
    SalesPaymentFilter paymentFilter = SalesPaymentFilter.all,
    SalePageCursor? cursor,
    int limit = 50,
  }) async {
    final q = query.trim().toLowerCase();

    Set<String>? barcodeSaleIds;
    if (q.isNotEmpty) {
      final barcodeNeedle = q.length < 3 ? '$q%' : '%$q%';
      final itemRows = await (select(saleItems)
            ..where((i) => i.storeId.equals(storeId))
            ..where((i) => i.barcode.like(barcodeNeedle))
            ..limit(80))
          .get();
      barcodeSaleIds = itemRows.map((i) => i.saleId).toSet();
    }

    final joined = select(sales).join([
      leftOuterJoin(customers, customers.id.equalsExp(sales.customerId)),
    ])
      ..where(sales.storeId.equals(storeId))
      ..where(sales.createdAt.isBiggerOrEqualValue(from))
      ..where(sales.createdAt.isSmallerOrEqualValue(to));

    switch (paymentFilter) {
      case SalesPaymentFilter.paid:
        joined.where(
          sales.paymentStatus.equals('paid') & sales.status.equals('voided').not(),
        );
      case SalesPaymentFilter.partial:
        joined.where(sales.paymentStatus.equals('partially_paid'));
      case SalesPaymentFilter.unpaid:
        joined.where(sales.paymentStatus.equals('unpaid'));
      case SalesPaymentFilter.refunded:
        joined.where(
          sales.refundedTotalCents.isBiggerThanValue(0) |
              sales.status.equals('partial_refund'),
        );
      case SalesPaymentFilter.voided:
        joined.where(sales.status.equals('voided'));
      case SalesPaymentFilter.all:
        break;
    }

    if (q.isNotEmpty) {
      final idNeedle = '%$q%';
      if (barcodeSaleIds != null && barcodeSaleIds.isNotEmpty) {
        joined.where(
          sales.id.like(idNeedle) |
              customers.name.like('%$q%') |
              sales.id.isIn(barcodeSaleIds.toList()),
        );
      } else {
        joined.where(
          sales.id.like(idNeedle) | customers.name.like('%$q%'),
        );
      }
    }

    if (cursor != null) {
      joined.where(
        sales.createdAt.isSmallerThanValue(cursor.createdAt) |
            (sales.createdAt.equals(cursor.createdAt) &
                sales.id.isSmallerThanValue(cursor.id)),
      );
    }

    joined
      ..orderBy([
        OrderingTerm(expression: sales.createdAt, mode: OrderingMode.desc),
        OrderingTerm(expression: sales.id, mode: OrderingMode.desc),
      ])
      ..limit(limit + 1);

    final rows = await joined.get();
    final hasMore = rows.length > limit;
    final slice = hasMore ? rows.sublist(0, limit) : rows;
    final items = slice
        .map(
          (r) => SaleListEntry(
            sale: r.readTable(sales),
            customerName: r.readTableOrNull(customers)?.name,
          ),
        )
        .toList(growable: false);

    SalePageCursor? next;
    if (hasMore && items.isNotEmpty) {
      final last = items.last.sale;
      next = SalePageCursor(createdAt: last.createdAt, id: last.id);
    }
    return SaleSearchPage(items: items, nextCursor: next);
  }

  Future<SalesHistorySummary> fetchSalesHistorySummary({
    required String tenantId,
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final revenue = await sumSalesTotalCents(
      tenantId: tenantId,
      storeId: storeId,
      from: from,
      to: to,
    );
    final countRow = await customSelect(
      '''
      SELECT COUNT(*) AS c FROM sales
      WHERE tenant_id = ? AND store_id = ? AND status != 'voided'
        AND created_at >= ? AND created_at < ?
      ''',
      variables: _saleRangeVariables(
        tenantId: tenantId,
        storeId: storeId,
        from: from,
        to: to,
      ),
      readsFrom: {sales},
    ).getSingle();
    final unpaidRow = await customSelect(
      '''
      SELECT COUNT(*) AS c FROM sales
      WHERE tenant_id = ? AND store_id = ? AND status != 'voided'
        AND payment_status IN ('unpaid', 'partially_paid')
        AND created_at >= ? AND created_at < ?
      ''',
      variables: _saleRangeVariables(
        tenantId: tenantId,
        storeId: storeId,
        from: from,
        to: to,
      ),
      readsFrom: {sales},
    ).getSingle();
    final refundRow = await customSelect(
      '''
      SELECT COALESCE(SUM(refunded_total_cents), 0) AS total
      FROM sales
      WHERE tenant_id = ? AND store_id = ? AND created_at >= ? AND created_at < ?
      ''',
      variables: _saleRangeVariables(
        tenantId: tenantId,
        storeId: storeId,
        from: from,
        to: to,
      ),
      readsFrom: {sales},
    ).getSingle();

    return SalesHistorySummary(
      transactionCount: countRow.read<int>('c'),
      netRevenueCents: revenue,
      unpaidCount: unpaidRow.read<int>('c'),
      refundedCents: refundRow.read<int>('total'),
    );
  }

  Future<List<SaleItem>> listSaleItemsForSales({
    required String storeId,
    required List<String> saleIds,
  }) {
    if (saleIds.isEmpty) return Future.value(const []);
    return (select(saleItems)
          ..where((i) => i.storeId.equals(storeId) & i.saleId.isIn(saleIds)))
        .get();
  }

  // ——— Accounting ———

  Future<void> ensureAccountingSeeded({
    required String tenantId,
    required String storeId,
  }) async {
    final existing = await (select(chartOfAccounts)
          ..where((a) => a.storeId.equals(storeId))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;

    final codeToId = <String, String>{};
    for (final row in defaultChartAccounts) {
      // Deterministic IDs so multiple devices seed identically before sync/pull.
      final id = _uuid.v5(_uuidNamespaceUrl, '$storeId:chart:${row.code}');
      codeToId[row.code] = id;
      await into(chartOfAccounts).insert(
        ChartOfAccountsCompanion.insert(
          id: id,
          tenantId: tenantId,
          storeId: storeId,
          code: row.code,
          name: row.name,
          type: row.type,
          isSystem: const Value(true),
        ),
      );
    }

    for (final pa in defaultPaymentAccounts) {
      final chartId = codeToId[pa.chartCode];
      if (chartId == null) continue;
      await into(paymentAccounts).insert(
        PaymentAccountsCompanion.insert(
          id: _uuid.v5(_uuidNamespaceUrl, '$storeId:payacct:${pa.name}'),
          tenantId: tenantId,
          storeId: storeId,
          name: pa.name,
          accountType: pa.accountType,
          chartAccountId: chartId,
          isDefault: Value(pa.isDefault),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Cloud pull upserts (no enqueue)
  // ---------------------------------------------------------------------------

  Future<void> upsertCategoryFromCloud(CategoriesCompanion row) {
    return into(categories).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertBrandFromCloud(BrandsCompanion row) {
    return into(brands).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertExpenseFromCloud(ExpensesCompanion row) {
    return into(expenses).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertDebtFromCloud(DebtsCompanion row) {
    return into(debts).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertDebtPaymentFromCloud(DebtPaymentsCompanion row) {
    return into(debtPayments).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertChartOfAccountFromCloud(ChartOfAccountsCompanion row) {
    return into(chartOfAccounts).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertPaymentAccountFromCloud(PaymentAccountsCompanion row) {
    return into(paymentAccounts).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertJournalEntryFromCloud(JournalEntriesCompanion row) {
    return into(journalEntries).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<void> upsertJournalLineFromCloud(JournalLinesCompanion row) {
    return into(journalLines).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<ChartOfAccount?> getAccountByCode({
    required String tenantId,
    required String storeId,
    required String code,
  }) {
    return (select(chartOfAccounts)
          ..where(
            (a) =>
                a.tenantId.equals(tenantId) &
                a.storeId.equals(storeId) &
                a.code.equals(code),
          ))
        .getSingleOrNull();
  }

  Future<ChartOfAccount?> getAccountById(String id) {
    return (select(chartOfAccounts)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  Future<JournalEntry?> findJournalBySource({
    required String storeId,
    required String sourceModule,
    required String sourceId,
  }) {
    return (select(journalEntries)
          ..where(
            (e) =>
                e.storeId.equals(storeId) &
                e.sourceModule.equals(sourceModule) &
                e.sourceId.equals(sourceId),
          ))
        .getSingleOrNull();
  }

  Future<String?> chartCodeForPaymentAccount(String paymentAccountId) async {
    final pa = await (select(paymentAccounts)
          ..where((p) => p.id.equals(paymentAccountId)))
        .getSingleOrNull();
    if (pa == null) return null;
    final acct = await getAccountById(pa.chartAccountId);
    return acct?.code;
  }

  Future<String?> getDefaultPaymentAccountId({
    required String tenantId,
    required String storeId,
  }) async {
    final row = await (select(paymentAccounts)
          ..where(
            (p) =>
                p.tenantId.equals(tenantId) &
                p.storeId.equals(storeId) &
                p.isDefault.equals(true) &
                p.isActive.equals(true),
          ))
        .getSingleOrNull();
    return row?.id;
  }

  Future<String?> resolvePaymentAccountForMethod({
    required String tenantId,
    required String storeId,
    required String method,
  }) async {
    final m = method.toLowerCase();
    final accounts = await (select(paymentAccounts)
          ..where(
            (p) =>
                p.tenantId.equals(tenantId) &
                p.storeId.equals(storeId) &
                p.isActive.equals(true),
          ))
        .get();
    if (accounts.isEmpty) return null;

    String? pickByName(String needle) {
      for (final a in accounts) {
        if (a.name.toLowerCase().contains(needle)) return a.id;
      }
      return null;
    }

    if (m == 'cash') {
      return pickByName('cash') ?? accounts.first.id;
    }
    if (m.contains('evc')) return pickByName('evc');
    if (m.contains('zaad')) return pickByName('zaad');
    if (m.contains('sahal')) return pickByName('sahal');
    if (m.contains('bank')) return pickByName('bank');
    if (m.contains('momo') || m.contains('mobile')) {
      return pickByName('evc') ??
          pickByName('zaad') ??
          pickByName('sahal');
    }
    return getDefaultPaymentAccountId(tenantId: tenantId, storeId: storeId);
  }

  Stream<List<ChartOfAccount>> watchChartOfAccounts({
    required String storeId,
    bool includeInactive = false,
  }) {
    final q = select(chartOfAccounts)..where((a) => a.storeId.equals(storeId));
    if (!includeInactive) {
      q.where((a) => a.isActive.equals(true));
    }
    q.orderBy([(a) => OrderingTerm(expression: a.code)]);
    return q.watch();
  }

  Future<List<ChartOfAccount>> listChartOfAccounts({
    required String storeId,
    bool includeInactive = false,
  }) {
    final q = select(chartOfAccounts)..where((a) => a.storeId.equals(storeId));
    if (!includeInactive) {
      q.where((a) => a.isActive.equals(true));
    }
    q.orderBy([(a) => OrderingTerm(expression: a.code)]);
    return q.get();
  }

  Future<bool> isChartAccountCodeTaken({
    required String tenantId,
    required String storeId,
    required String code,
  }) async {
    final row = await getAccountByCode(
      tenantId: tenantId,
      storeId: storeId,
      code: code.trim(),
    );
    return row != null;
  }

  Future<void> createChartAccount({
    required String tenantId,
    required String storeId,
    required String code,
    required String name,
    required String type,
    String? parentId,
    int openingBalanceCents = 0,
  }) async {
    final cleanCode = code.trim();
    final cleanName = name.trim();
    if (cleanCode.isEmpty || cleanName.isEmpty) {
      throw ArgumentError('Code and name are required.');
    }
    final taken = await isChartAccountCodeTaken(
      tenantId: tenantId,
      storeId: storeId,
      code: cleanCode,
    );
    if (taken) {
      throw StateError('Account code already exists.');
    }
    await into(chartOfAccounts).insert(
      ChartOfAccountsCompanion.insert(
        id: _uuid.v4(),
        tenantId: tenantId,
        storeId: storeId,
        code: cleanCode,
        name: cleanName,
        type: type,
        parentId: Value(parentId),
        openingBalanceCents: Value(openingBalanceCents),
        isSystem: const Value(false),
        isActive: const Value(true),
      ),
    );
    final created = await getAccountByCode(
      tenantId: tenantId,
      storeId: storeId,
      code: cleanCode,
    );
    if (created != null) {
      await enqueueSync(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'chart_of_accounts',
        entityId: created.id,
        operation: 'upsert',
        payload: SyncPayload.chartOfAccount(created),
      );
    }
  }

  Future<int> countJournalLinesForAccount(String accountId) async {
    final res = await (selectOnly(journalLines)
          ..addColumns([journalLines.id.count()])
          ..where(journalLines.accountId.equals(accountId)))
        .getSingle();
    return res.read(journalLines.id.count()) ?? 0;
  }

  Future<int> getAccountBalanceCents(String accountId) async {
    final acct = await getAccountById(accountId);
    if (acct == null) return 0;
    final activity = await sumAccountActivity(accountId: accountId);
    return signedBalanceCents(
      accountType: acct.type,
      openingBalanceCents: acct.openingBalanceCents,
      debitSum: activity.debit,
      creditSum: activity.credit,
    );
  }

  Future<List<AccountMonthActivityPoint>> accountMonthlyActivity({
    required String accountId,
    int months = 6,
  }) async {
    final now = DateTime.now();
    final points = <AccountMonthActivityPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final start = DateTime(now.year, now.month - i, 1);
      final end = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
      final activity = await sumAccountActivity(
        accountId: accountId,
        from: start,
        to: end,
      );
      points.add(
        AccountMonthActivityPoint(
          label: '${start.year}-${start.month.toString().padLeft(2, '0')}',
          debitCents: activity.debit,
          creditCents: activity.credit,
        ),
      );
    }
    return points;
  }

  Future<void> setChartAccountActive({
    required String accountId,
    required bool isActive,
  }) async {
    final acct = await getAccountById(accountId);
    if (acct == null) return;
    if (!isActive) {
      final balance = await getAccountBalanceCents(accountId);
      if (balance != 0) {
        throw StateError(
          'Account has a balance and cannot be deleted.',
        );
      }
      final used = await countJournalLinesForAccount(accountId);
      if (used > 0) {
        throw StateError(
          'Account is used in journal entries and cannot be deleted.',
        );
      }
    }
    await (update(chartOfAccounts)..where((a) => a.id.equals(accountId))).write(
      ChartOfAccountsCompanion(isActive: Value(isActive)),
    );
    final updated = await getAccountById(accountId);
    if (updated != null) {
      await enqueueSync(
        tenantId: updated.tenantId,
        storeId: updated.storeId,
        entity: 'chart_of_accounts',
        entityId: updated.id,
        operation: 'upsert',
        payload: SyncPayload.chartOfAccount(updated),
      );
    }
  }

  Stream<List<PaymentAccount>> watchPaymentAccounts({
    required String storeId,
  }) {
    return (select(paymentAccounts)
          ..where((p) => p.storeId.equals(storeId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .watch();
  }

  Future<List<PaymentAccount>> listPaymentAccounts({
    required String storeId,
  }) {
    return (select(paymentAccounts)
          ..where((p) => p.storeId.equals(storeId) & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .get();
  }

  Future<PaymentAccount?> getPaymentAccountById(String id) {
    return (select(paymentAccounts)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Future<JournalEntry?> getJournalEntryById(String id) {
    return (select(journalEntries)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> _nextWalletAssetCode({
    required String tenantId,
    required String storeId,
  }) async {
    final assets = await listChartOfAccounts(
      storeId: storeId,
      includeInactive: true,
    );
    var maxCode = 1049;
    for (final a in assets) {
      if (a.type != AccountType.asset) continue;
      final n = int.tryParse(a.code);
      if (n != null && n >= 1000 && n < 1100 && n > maxCode) {
        maxCode = n;
      }
    }
    return '${maxCode + 10}';
  }

  Future<String> _ensureChartAccountForPaymentWallet({
    required String tenantId,
    required String storeId,
    required String name,
    required String accountType,
    String? existingChartAccountId,
  }) async {
    if (existingChartAccountId != null) {
      final chart = await getAccountById(existingChartAccountId);
      if (chart != null) {
        if (!chart.isSystem && chart.name != name.trim()) {
          await (update(chartOfAccounts)
                ..where((a) => a.id.equals(chart.id)))
              .write(ChartOfAccountsCompanion(name: Value(name.trim())));
          final updated = await getAccountById(chart.id);
          if (updated != null) {
            await enqueueSync(
              tenantId: tenantId,
              storeId: storeId,
              entity: 'chart_of_accounts',
              entityId: updated.id,
              operation: 'upsert',
              payload: SyncPayload.chartOfAccount(updated),
            );
          }
        }
        return existingChartAccountId;
      }
    }

    final trimmed = name.trim();
    final assets = await listChartOfAccounts(storeId: storeId);
    for (final a in assets) {
      if (a.type == AccountType.asset &&
          a.name.toLowerCase() == trimmed.toLowerCase()) {
        return a.id;
      }
    }

    final defaultCode = switch (accountType) {
      'bank' => AcctCode.bank,
      'mobile' => null,
      _ => AcctCode.cash,
    };
    if (defaultCode != null) {
      final byCode = await getAccountByCode(
        tenantId: tenantId,
        storeId: storeId,
        code: defaultCode,
      );
      if (byCode != null && byCode.name.toLowerCase() == trimmed.toLowerCase()) {
        return byCode.id;
      }
    }

    final code = await _nextWalletAssetCode(
      tenantId: tenantId,
      storeId: storeId,
    );
    await createChartAccount(
      tenantId: tenantId,
      storeId: storeId,
      code: code,
      name: trimmed,
      type: AccountType.asset,
    );
    final created = await getAccountByCode(
      tenantId: tenantId,
      storeId: storeId,
      code: code,
    );
    if (created == null) {
      throw StateError('Could not create chart account for wallet.');
    }
    return created.id;
  }

  Future<void> savePaymentAccount({
    String? id,
    required String tenantId,
    required String storeId,
    required String name,
    required String accountType,
    bool isDefault = false,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Wallet name is required.');
    }
    if (!{'cash', 'bank', 'mobile'}.contains(accountType)) {
      throw ArgumentError('Invalid wallet type.');
    }

    PaymentAccount? existing;
    if (id != null) {
      existing = await getPaymentAccountById(id);
      if (existing == null) {
        throw StateError('Payment account not found.');
      }
    }

    final chartAccountId = await _ensureChartAccountForPaymentWallet(
      tenantId: tenantId,
      storeId: storeId,
      name: trimmed,
      accountType: accountType,
      existingChartAccountId: existing?.chartAccountId,
    );

    final accountId = id ?? _uuid.v4();

    if (isDefault) {
      await (update(paymentAccounts)..where((p) => p.storeId.equals(storeId)))
          .write(const PaymentAccountsCompanion(isDefault: Value(false)));
    }

    await into(paymentAccounts).insert(
      PaymentAccountsCompanion.insert(
        id: accountId,
        tenantId: tenantId,
        storeId: storeId,
        name: trimmed,
        accountType: accountType,
        chartAccountId: chartAccountId,
        isDefault: Value(isDefault),
        isActive: const Value(true),
      ),
      mode: InsertMode.insertOrReplace,
    );

    final saved = await getPaymentAccountById(accountId);
    if (saved != null) {
      await enqueueSync(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'payment_accounts',
        entityId: saved.id,
        operation: 'upsert',
        payload: SyncPayload.paymentAccount(saved),
      );
    }
  }

  Future<void> deactivatePaymentAccount({
    required String id,
    required String tenantId,
    required String storeId,
  }) async {
    final existing = await getPaymentAccountById(id);
    if (existing == null) return;
    await (update(paymentAccounts)..where((p) => p.id.equals(id))).write(
      const PaymentAccountsCompanion(isActive: Value(false)),
    );
    final updated = await getPaymentAccountById(id);
    if (updated != null) {
      await enqueueSync(
        tenantId: tenantId,
        storeId: storeId,
        entity: 'payment_accounts',
        entityId: updated.id,
        operation: 'upsert',
        payload: SyncPayload.paymentAccount(updated),
      );
    }
  }

  Future<List<JournalEntry>> listJournalEntries({
    required String storeId,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) {
    final q = select(journalEntries)..where((e) => e.storeId.equals(storeId));
    if (from != null) q.where((e) => e.entryDate.isBiggerOrEqualValue(from));
    if (to != null) q.where((e) => e.entryDate.isSmallerOrEqualValue(to));
    q
      ..orderBy([
        (e) => OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return q.get();
  }

  Future<List<JournalLine>> listLinesForJournal(String journalEntryId) {
    return (select(journalLines)
          ..where((l) => l.journalEntryId.equals(journalEntryId)))
        .get();
  }

  Future<({int debit, int credit})> sumAccountActivity({
    required String accountId,
    DateTime? from,
    DateTime? to,
  }) async {
    final joinQ = select(journalLines).join([
      innerJoin(
        journalEntries,
        journalEntries.id.equalsExp(journalLines.journalEntryId),
      ),
    ])
      ..where(journalLines.accountId.equals(accountId));

    if (from != null) {
      joinQ.where(journalEntries.entryDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      joinQ.where(journalEntries.entryDate.isSmallerOrEqualValue(to));
    }

    final rows = await joinQ.get();
    var debit = 0;
    var credit = 0;
    for (final r in rows) {
      final line = r.readTable(journalLines);
      debit += line.debitCents;
      credit += line.creditCents;
    }
    return (debit: debit, credit: credit);
  }

  int signedBalanceCents({
    required String accountType,
    required int openingBalanceCents,
    required int debitSum,
    required int creditSum,
  }) {
    if (AccountType.isDebitNormal(accountType)) {
      return openingBalanceCents + debitSum - creditSum;
    }
    return openingBalanceCents + creditSum - debitSum;
  }

  Future<List<AccountBalanceRow>> accountBalances({
    required String storeId,
    DateTime? from,
    DateTime? to,
  }) async {
    final accounts = await (select(chartOfAccounts)
          ..where((a) => a.storeId.equals(storeId) & a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm(expression: a.code)]))
        .get();

    final rows = <AccountBalanceRow>[];
    for (final a in accounts) {
      final activity = await sumAccountActivity(
        accountId: a.id,
        from: from,
        to: to,
      );
      final balance = signedBalanceCents(
        accountType: a.type,
        openingBalanceCents: a.openingBalanceCents,
        debitSum: activity.debit,
        creditSum: activity.credit,
      );
      rows.add(
        AccountBalanceRow(
          account: a,
          debitCents: activity.debit,
          creditCents: activity.credit,
          balanceCents: balance,
        ),
      );
    }
    return rows;
  }

  Future<List<LedgerLineRow>> ledgerForAccount({
    required String accountId,
    DateTime? from,
    DateTime? to,
  }) async {
    final account = await getAccountById(accountId);
    if (account == null) return [];

    final joinQ = select(journalLines).join([
      innerJoin(
        journalEntries,
        journalEntries.id.equalsExp(journalLines.journalEntryId),
      ),
    ])
      ..where(journalLines.accountId.equals(accountId));

    if (from != null) {
      joinQ.where(journalEntries.entryDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      joinQ.where(journalEntries.entryDate.isSmallerOrEqualValue(to));
    }

    joinQ.orderBy([
      OrderingTerm(expression: journalEntries.entryDate),
    ]);

    final rows = await joinQ.get();
    var running = account.openingBalanceCents;
    final out = <LedgerLineRow>[];
    for (final r in rows) {
      final entry = r.readTable(journalEntries);
      final line = r.readTable(journalLines);
      if (AccountType.isDebitNormal(account.type)) {
        running += line.debitCents - line.creditCents;
      } else {
        running += line.creditCents - line.debitCents;
      }
      out.add(
        LedgerLineRow(
          entryDate: entry.entryDate,
          description: entry.description,
          sourceModule: entry.sourceModule,
          debitCents: line.debitCents,
          creditCents: line.creditCents,
          runningBalanceCents: running,
        ),
      );
    }
    return out;
  }

  Future<AccountingDashboardKpis> accountingDashboardKpis({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    final balances = await accountBalances(storeId: storeId, from: from, to: to);
    var revenue = 0;
    var expenses = 0;
    var cash = 0;
    var ar = 0;
    var ap = 0;

    for (final b in balances) {
      switch (b.account.code) {
        case AcctCode.salesRevenue:
          revenue += b.balanceCents;
        case AcctCode.cash:
        case AcctCode.bank:
        case AcctCode.evcPlus:
        case AcctCode.zaad:
        case AcctCode.sahal:
          cash += b.balanceCents;
        case AcctCode.accountsReceivable:
          ar += b.balanceCents;
        case AcctCode.accountsPayable:
          ap += b.balanceCents;
        default:
          if (b.account.type == AccountType.expense) {
            expenses += b.balanceCents;
          }
      }
    }

    return AccountingDashboardKpis(
      revenueCents: revenue,
      expenseCents: expenses,
      netProfitCents: revenue - expenses,
      cashCents: cash,
      receivableCents: ar,
      payableCents: ap,
    );
  }

  Future<List<MonthlyAmountPoint>> monthlyRevenueExpense({
    required String storeId,
    required int months,
  }) async {
    final now = DateTime.now();
    final points = <MonthlyAmountPoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final start = DateTime(now.year, now.month - i, 1);
      final end = (start.month == 12)
          ? DateTime(start.year + 1, 1, 1)
          : DateTime(start.year, start.month + 1, 1);
      final balances = await accountBalances(
        storeId: storeId,
        from: start,
        to: end,
      );
      var revenue = 0;
      var expense = 0;
      for (final b in balances) {
        if (b.account.type == AccountType.revenue) {
          revenue += b.balanceCents;
        } else if (b.account.type == AccountType.expense) {
          expense += b.balanceCents;
        }
      }
      points.add(
        MonthlyAmountPoint(
          label: '${start.month}/${start.year}',
          revenueCents: revenue,
          expenseCents: expense,
        ),
      );
    }
    return points;
  }

  // ── SMS platform ─────────────────────────────────────────────────────────

  Future<void> _seedSmsPackages() async {
    final count = await (selectOnly(smsPackages)
          ..addColumns([smsPackages.id.count()]))
        .getSingle();
    if ((count.read(smsPackages.id.count()) ?? 0) > 0) return;

    const packages = [
      (id: 'starter', name: 'Starter', count: 500, price: 5000),
      (id: 'business', name: 'Business', count: 5000, price: 35000),
      (id: 'enterprise', name: 'Enterprise', count: 50000, price: 250000),
    ];
    for (final pkg in packages) {
      await into(smsPackages).insert(
        SmsPackagesCompanion.insert(
          id: pkg.id,
          name: pkg.name,
          smsCount: pkg.count,
          priceCents: pkg.price,
        ),
      );
    }
  }

  Future<StoreSmsWallet> ensureStoreSmsWallet({
    required String tenantId,
    required String storeId,
  }) async {
    final existing = await (select(storeSmsWallets)
          ..where((w) => w.storeId.equals(storeId)))
        .getSingleOrNull();
    if (existing != null) return existing;

    await into(storeSmsWallets).insert(
      StoreSmsWalletsCompanion.insert(
        storeId: storeId,
        tenantId: tenantId,
        balanceRemaining: const Value(0),
        totalPurchased: const Value(0),
      ),
    );
    await _seedDefaultSmsTemplates(tenantId: tenantId, storeId: storeId);
    return (select(storeSmsWallets)
          ..where((w) => w.storeId.equals(storeId)))
        .getSingle();
  }

  Future<void> _seedDefaultSmsTemplates({
    required String tenantId,
    required String storeId,
  }) async {
    final existing = await (select(smsTemplates)
          ..where((t) => t.storeId.equals(storeId)))
        .get();
    if (existing.isNotEmpty) return;

    await into(smsTemplates).insert(
      SmsTemplatesCompanion.insert(
        id: _uuid.v4(),
        tenantId: tenantId,
        storeId: storeId,
        name: 'Debt reminder',
        templateType: 'debt_reminder',
        localeCode: const Value('so'),
        body:
            'Asc {{customer_name}},\nWaxaad leedahay deyn dhan {{amount}} oo ku eg {{due_date}}.\nFadlan la xiriir {{store_name}}.\n{{payment_link}}',
        isDefault: const Value(true),
      ),
    );
  }

  Future<StoreSmsSetting> ensureStoreSmsSettings({
    required String tenantId,
    required String storeId,
  }) async {
    final existing = await (select(storeSmsSettings)
          ..where((s) => s.storeId.equals(storeId)))
        .getSingleOrNull();
    if (existing != null) return existing;

    await into(storeSmsSettings).insert(
      StoreSmsSettingsCompanion.insert(
        storeId: storeId,
        tenantId: tenantId,
      ),
    );
    return (select(storeSmsSettings)
          ..where((s) => s.storeId.equals(storeId)))
        .getSingle();
  }

  Stream<StoreSmsWallet?> watchStoreSmsWallet({required String storeId}) {
    return (select(storeSmsWallets)..where((w) => w.storeId.equals(storeId)))
        .watchSingleOrNull();
  }

  /// Mirror cloud `store_sms_wallets` into local cache (source of truth = cloud).
  Future<void> upsertSmsWalletFromCloud({
    required String storeId,
    required String tenantId,
    required int balanceRemaining,
    required int balancePurchased,
    required int balanceUsed,
  }) async {
    final existed = await (select(storeSmsWallets)
          ..where((w) => w.storeId.equals(storeId)))
        .getSingleOrNull();

    await into(storeSmsWallets).insertOnConflictUpdate(
      StoreSmsWalletsCompanion.insert(
        storeId: storeId,
        tenantId: tenantId,
        balanceRemaining: Value(balanceRemaining),
        totalPurchased: Value(balancePurchased),
        totalSent: Value(balanceUsed),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (existed == null) {
      await _seedDefaultSmsTemplates(tenantId: tenantId, storeId: storeId);
    }
  }

  Stream<StoreSmsSetting?> watchStoreSmsSettings({required String storeId}) {
    return (select(storeSmsSettings)..where((s) => s.storeId.equals(storeId)))
        .watchSingleOrNull();
  }

  Stream<List<SmsLog>> watchSmsLogs({
    required String storeId,
    int limit = 100,
  }) {
    return (select(smsLogs)
          ..where((l) => l.storeId.equals(storeId))
          ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
          ..limit(limit))
        .watch();
  }

  Stream<int> watchPendingSmsCount({required String storeId}) {
    return (select(smsQueue)
          ..where(
            (q) =>
                q.storeId.equals(storeId) &
                q.status.isIn(['queued', 'sending']),
          ))
        .watch()
        .map((rows) => rows.length);
  }

  Stream<List<SmsPackage>> watchSmsPackages() {
    return (select(smsPackages)
          ..where((p) => p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.smsCount)]))
        .watch();
  }

  Future<List<SmsQueueData>> listDueSmsQueue({
    required String storeId,
    int limit = 10,
  }) {
    final now = DateTime.now();
    return (select(smsQueue)
          ..where(
            (q) =>
                q.storeId.equals(storeId) &
                q.status.equals('queued') &
                q.scheduledAt.isSmallerOrEqualValue(now),
          )
          ..orderBy([(q) => OrderingTerm.asc(q.scheduledAt)])
          ..limit(limit))
        .get();
  }

  Future<void> deductSmsBalance({required String storeId}) async {
    final wallet = await (select(storeSmsWallets)
          ..where((w) => w.storeId.equals(storeId)))
        .getSingleOrNull();
    if (wallet == null) return;
    await (update(storeSmsWallets)..where((w) => w.storeId.equals(storeId)))
        .write(
      StoreSmsWalletsCompanion(
        balanceRemaining: Value((wallet.balanceRemaining - 1).clamp(0, 1 << 30)),
        totalSent: Value(wallet.totalSent + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> incrementSmsSentToday({
    required String storeId,
    required String tenantId,
  }) async {
    final settings = await ensureStoreSmsSettings(
      tenantId: tenantId,
      storeId: storeId,
    );
    final today = DateTime.now();
    final last = settings.sentTodayDate;
    final count = last != null &&
            last.year == today.year &&
            last.month == today.month &&
            last.day == today.day
        ? settings.sentTodayCount + 1
        : 1;
    await (update(storeSmsSettings)..where((s) => s.storeId.equals(storeId)))
        .write(
      StoreSmsSettingsCompanion(
        sentTodayCount: Value(count),
        sentTodayDate: Value(today),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<SmsReminder>> watchSmsReminders({
    required String storeId,
    int limit = 100,
  }) {
    return (select(smsReminders)
          ..where((r) => r.storeId.equals(storeId))
          ..orderBy([(r) => OrderingTerm.desc(r.scheduledFor)])
          ..limit(limit))
        .watch();
  }

  Stream<List<SmsTemplate>> watchSmsTemplates({required String storeId}) {
    return (select(smsTemplates)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.localeCode)]))
        .watch();
  }

  Future<void> updateStoreSmsSettings({
    required String storeId,
    bool? remindersEnabled,
    bool? remindOnDueDate,
    bool? remindOneDayBefore,
    bool? remindThreeDaysBefore,
    bool? remindOnOverdue,
    int? dailySendCap,
  }) async {
    await (update(storeSmsSettings)..where((s) => s.storeId.equals(storeId)))
        .write(
      StoreSmsSettingsCompanion(
        remindersEnabled: remindersEnabled == null
            ? const Value.absent()
            : Value(remindersEnabled),
        remindOnDueDate: remindOnDueDate == null
            ? const Value.absent()
            : Value(remindOnDueDate),
        remindOneDayBefore: remindOneDayBefore == null
            ? const Value.absent()
            : Value(remindOneDayBefore),
        remindThreeDaysBefore: remindThreeDaysBefore == null
            ? const Value.absent()
            : Value(remindThreeDaysBefore),
        remindOnOverdue:
            remindOnOverdue == null ? const Value.absent() : Value(remindOnOverdue),
        dailySendCap:
            dailySendCap == null ? const Value.absent() : Value(dailySendCap),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertSmsTemplate({
    required String id,
    required String tenantId,
    required String storeId,
    required String name,
    required String templateType,
    required String localeCode,
    required String body,
    bool isDefault = true,
  }) async {
    final existing = await (select(smsTemplates)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      await into(smsTemplates).insert(
        SmsTemplatesCompanion.insert(
          id: id,
          tenantId: tenantId,
          storeId: storeId,
          name: name,
          templateType: templateType,
          localeCode: Value(localeCode),
          body: body,
          isDefault: Value(isDefault),
        ),
      );
      return;
    }
    await (update(smsTemplates)..where((t) => t.id.equals(id))).write(
      SmsTemplatesCompanion(
        name: Value(name),
        body: Value(body),
        localeCode: Value(localeCode),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<SmsTemplate?> getDefaultSmsTemplate({
    required String storeId,
    required String templateType,
    String localeCode = 'en',
  }) {
    return (select(smsTemplates)
          ..where(
            (t) =>
                t.storeId.equals(storeId) &
                t.templateType.equals(templateType) &
                t.isDefault.equals(true) &
                t.localeCode.equals(localeCode),
          ))
        .getSingleOrNull();
  }

  Future<bool> hasSmsReminder({
    required String debtId,
    required String reminderType,
    required DateTime onDay,
  }) async {
    final start = DateTime(onDay.year, onDay.month, onDay.day);
    final end = start.add(const Duration(days: 1));
    final row = await (select(smsReminders)
          ..where(
            (r) =>
                r.debtId.equals(debtId) &
                r.reminderType.equals(reminderType) &
                r.scheduledFor.isBiggerOrEqualValue(start) &
                r.scheduledFor.isSmallerThanValue(end),
          ))
        .getSingleOrNull();
    return row != null;
  }

  Future<List<Debt>> listActiveCustomerDebtsWithDueDate({
    required String storeId,
  }) {
    return (select(debts)
          ..where(
            (d) =>
                d.storeId.equals(storeId) &
                d.debtType.equals('customer') &
                d.dueDate.isNotNull() &
                d.remainingCents.isBiggerThanValue(0) &
                d.status.isNotIn(['paid']),
          ))
        .get();
  }

  Future<void> purchaseSmsPackage({
    required String tenantId,
    required String storeId,
    required String packageId,
  }) async {
    final pkg = await (select(smsPackages)
          ..where((p) => p.id.equals(packageId)))
        .getSingleOrNull();
    if (pkg == null) return;

    await ensureStoreSmsWallet(tenantId: tenantId, storeId: storeId);
    final wallet = await (select(storeSmsWallets)
          ..where((w) => w.storeId.equals(storeId)))
        .getSingle();

    await (update(storeSmsWallets)..where((w) => w.storeId.equals(storeId)))
        .write(
      StoreSmsWalletsCompanion(
        balanceRemaining: Value(wallet.balanceRemaining + pkg.smsCount),
        totalPurchased: Value(wallet.totalPurchased + pkg.smsCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<PlatformSmsStats> platformSmsStats() async {
    final sentCount = smsLogs.id.count();
    final sent = await (selectOnly(smsLogs)
          ..addColumns([sentCount])
          ..where(smsLogs.status.equals('sent')))
        .getSingle();
    final failedCount = smsLogs.id.count();
    final failed = await (selectOnly(smsLogs)
          ..addColumns([failedCount])
          ..where(smsLogs.status.equals('failed')))
        .getSingle();
    final pendingCount = smsQueue.id.count();
    final pending = await (selectOnly(smsQueue)
          ..addColumns([pendingCount])
          ..where(smsQueue.status.equals('queued')))
        .getSingle();
    final balance = await customSelect(
      'SELECT COALESCE(SUM(balance_remaining), 0) AS total FROM store_sms_wallets',
      readsFrom: {storeSmsWallets},
    ).getSingle();

    return PlatformSmsStats(
      totalSent: sent.read(sentCount) ?? 0,
      totalFailed: failed.read(failedCount) ?? 0,
      pendingQueue: pending.read(pendingCount) ?? 0,
      totalBalanceRemaining: balance.read<int>('total'),
    );
  }
}

class PlatformSmsStats {
  const PlatformSmsStats({
    required this.totalSent,
    required this.totalFailed,
    required this.pendingQueue,
    required this.totalBalanceRemaining,
  });

  final int totalSent;
  final int totalFailed;
  final int pendingQueue;
  final int totalBalanceRemaining;
}

class AccountBalanceRow {
  const AccountBalanceRow({
    required this.account,
    required this.debitCents,
    required this.creditCents,
    required this.balanceCents,
  });

  final ChartOfAccount account;
  final int debitCents;
  final int creditCents;
  final int balanceCents;
}

class LedgerLineRow {
  const LedgerLineRow({
    required this.entryDate,
    required this.description,
    required this.sourceModule,
    required this.debitCents,
    required this.creditCents,
    required this.runningBalanceCents,
  });

  final DateTime entryDate;
  final String description;
  final String sourceModule;
  final int debitCents;
  final int creditCents;
  final int runningBalanceCents;
}

class AccountingDashboardKpis {
  const AccountingDashboardKpis({
    required this.revenueCents,
    required this.expenseCents,
    required this.netProfitCents,
    required this.cashCents,
    required this.receivableCents,
    required this.payableCents,
  });

  final int revenueCents;
  final int expenseCents;
  final int netProfitCents;
  final int cashCents;
  final int receivableCents;
  final int payableCents;
}

class MonthlyAmountPoint {
  const MonthlyAmountPoint({
    required this.label,
    required this.revenueCents,
    required this.expenseCents,
  });

  final String label;
  final int revenueCents;
  final int expenseCents;
}

class AccountMonthActivityPoint {
  const AccountMonthActivityPoint({
    required this.label,
    required this.debitCents,
    required this.creditCents,
  });

  final String label;
  final int debitCents;
  final int creditCents;
}


