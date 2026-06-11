import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/store_context.dart';
import '../data/local/app_database.dart';
import 'sync_payload.dart';
import 'supabase_bootstrap.dart';

/// Pushes pending sync_queue rows to Supabase when configured and online.
class SyncPushService {
  SyncPushService(this._db);

  final AppDatabase _db;

  static const _maxRetries = 15;
  static const _unsupportedCloudEntities = <String>{};

  Future<int> pushPending({int batchSize = 25}) async {
    final client = supabaseClient;
    if (client == null) return 0;

    if (client.auth.currentSession == null) {
      if (kDebugMode) {
        debugPrint('Sync push skipped: no Supabase auth session');
      }
      return 0;
    }

    final storeId = StoreContext.storeId;
    final tenantId = StoreContext.tenantId;

    // Drop stale dev-store / wrong-tenant rows in one shot (prevents rebuild storms).
    if (storeId.isNotEmpty &&
        tenantId.isNotEmpty &&
        storeId != StoreContext.defaultStoreId) {
      await _db.cleanupForeignTenantData(
        tenantId: tenantId,
        storeId: storeId,
      );
    }

    final rows = await (_db.select(_db.syncQueue)
          ..where(
            (q) => q.tenantId.equals(tenantId) & q.storeId.equals(storeId),
          )
          ..orderBy([
            (q) => OrderingTerm(expression: q.createdAt),
          ])
          ..limit(batchSize))
        .get();

    final removedIds = <int>[];
    var pushed = 0;

    for (final row in rows) {
      if (row.storeId != storeId || row.tenantId != tenantId) {
        removedIds.add(row.id);
        continue;
      }

      if (_unsupportedCloudEntities.contains(row.entity)) {
        removedIds.add(row.id);
        if (kDebugMode) {
          debugPrint('Sync: dropped unsupported entity ${row.entity}');
        }
        pushed++;
        continue;
      }

      if (row.retryCount >= _maxRetries) {
        removedIds.add(row.id);
        if (kDebugMode) {
          debugPrint(
            'Sync: dropped ${row.entity}/${row.entityId} after $_maxRetries retries',
          );
        }
        continue;
      }

      try {
        final payload = await _resolvePayload(row);
        if (payload.isEmpty && row.operation != 'delete') {
          removedIds.add(row.id);
          if (kDebugMode) {
            debugPrint(
              'Sync: dropped orphan ${row.entity}/${row.entityId} (no local row)',
            );
          }
          pushed++;
          continue;
        }
        await _pushRow(client, row, payload: payload);
        removedIds.add(row.id);
        pushed++;
      } catch (e, st) {
        final msg = e.toString();

        if (_isPermanentPushFailure(msg)) {
          removedIds.add(row.id);
          if (kDebugMode) {
            debugPrint(
              'Sync: dropped ${row.entity}/${row.entityId}: $msg',
            );
          }
          continue;
        }

        await (_db.update(_db.syncQueue)..where((q) => q.id.equals(row.id))).write(
          SyncQueueCompanion(
            retryCount: Value(row.retryCount + 1),
            lastTriedAt: Value(DateTime.now()),
            lastError: Value(msg.length > 500 ? msg.substring(0, 500) : msg),
          ),
        );
        if (kDebugMode) {
          debugPrint('Sync push failed ${row.entity}/${row.entityId}: $e\n$st');
        }
        continue;
      }
    }

    await _db.dropSyncQueueItems(removedIds);
    return pushed;
  }

  bool _isPermanentPushFailure(String message) {
    final m = message.toLowerCase();
    return m.contains('duplicate key') ||
        m.contains('violates foreign key') ||
        m.contains('permission denied') ||
        m.contains('row-level security') ||
        m.contains('could not find the table');
  }

  Future<void> _pushRow(
    SupabaseClient client,
    SyncQueueData row, {
    required Map<String, dynamic> payload,
  }) async {
    switch (row.entity) {
      case 'sales':
        await _pushSale(client, payload, operation: row.operation);
      case 'purchases':
        await _pushPurchase(client, payload);
      case 'products':
      case 'suppliers':
      case 'customers':
      case 'categories':
      case 'brands':
      case 'expenses':
      case 'debts':
      case 'debt_payments':
      case 'chart_of_accounts':
      case 'payment_accounts':
      case 'journal_entries':
      case 'journal_lines':
        if (row.operation == 'delete') {
          await client
              .from(row.entity)
              .delete()
              .eq('id', row.entityId)
              .eq('store_id', StoreContext.storeId);
        } else {
          await client.from(row.entity).upsert(
            payload,
            onConflict: 'id',
          );
        }
      case 'stores':
        final storePayload = Map<String, dynamic>.from(payload);
        storePayload.remove('store_id');
        await client
            .from('stores')
            .update(storePayload)
            .eq('id', row.entityId)
            .eq('tenant_id', StoreContext.tenantId);
      default:
        if (kDebugMode) {
          debugPrint('Sync: unknown entity ${row.entity}, skipping');
        }
    }
  }

  /// Builds a cloud row scoped to the signed-in store (RLS).
  Future<Map<String, dynamic>> _resolvePayload(SyncQueueData row) async {
    final raw = jsonDecode(row.payloadJson);
    var payload = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    if (_payloadNeedsHydration(payload)) {
      payload = await _hydrateFromLocal(row) ?? payload;
    }

    return _scopeForCloud(row, payload);
  }

  bool _payloadNeedsHydration(Map<String, dynamic> payload) {
    if (payload.isEmpty) return true;
    return !payload.containsKey('tenant_id') || !payload.containsKey('store_id');
  }

  Future<Map<String, dynamic>?> _hydrateFromLocal(SyncQueueData row) async {
    switch (row.entity) {
      case 'suppliers':
        final s = await (_db.select(_db.suppliers)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return s != null ? SyncPayload.supplier(s) : null;
      case 'customers':
        final c = await (_db.select(_db.customers)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return c != null ? SyncPayload.customer(c) : null;
      case 'products':
        final p = await _db.getProductById(
          storeId: row.storeId,
          productId: row.entityId,
        );
        return p != null ? SyncPayload.product(p) : null;
      case 'categories':
        final cat = await (_db.select(_db.categories)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return cat != null ? SyncPayload.category(cat) : null;
      case 'brands':
        final brand = await (_db.select(_db.brands)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return brand != null ? SyncPayload.brand(brand) : null;
      case 'expenses':
        final exp = await (_db.select(_db.expenses)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return exp != null ? SyncPayload.expense(exp) : null;
      case 'debts':
        final debt = await (_db.select(_db.debts)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return debt != null ? SyncPayload.debt(debt) : null;
      case 'debt_payments':
        final pay = await (_db.select(_db.debtPayments)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return pay != null ? SyncPayload.debtPayment(pay) : null;
      case 'chart_of_accounts':
        final acct = await (_db.select(_db.chartOfAccounts)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return acct != null ? SyncPayload.chartOfAccount(acct) : null;
      case 'payment_accounts':
        final acct = await (_db.select(_db.paymentAccounts)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return acct != null ? SyncPayload.paymentAccount(acct) : null;
      case 'journal_entries':
        final e = await (_db.select(_db.journalEntries)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return e != null ? SyncPayload.journalEntry(e) : null;
      case 'journal_lines':
        final l = await (_db.select(_db.journalLines)
              ..where((t) => t.id.equals(row.entityId)))
            .getSingleOrNull();
        return l != null ? SyncPayload.journalLine(l) : null;
      default:
        return null;
    }
  }

  /// Aligns tenant/store with the active session so RLS policies pass.
  Map<String, dynamic> _scopeForCloud(
    SyncQueueData row,
    Map<String, dynamic> payload,
  ) {
    final copy = _parentRow(payload);
    copy['id'] = row.entityId;
    copy['tenant_id'] = StoreContext.tenantId;
    copy['store_id'] = StoreContext.storeId;
    return copy;
  }

  Future<void> _pushSale(
    SupabaseClient client,
    Map<String, dynamic> payload, {
    required String operation,
  }) async {
    final items = _extractLineItems(payload);
    final saleRow = Map<String, dynamic>.from(payload);
    _normalizePaymentJson(saleRow);

    await client.from('sales').upsert(saleRow, onConflict: 'id');
    if (items.isEmpty) return;

    final saleId = saleRow['id'] as String;
    final tenantId = saleRow['tenant_id'] as String;
    final storeId = saleRow['store_id'] as String;

    for (final item in items) {
      final line = Map<String, dynamic>.from(item);
      line['sale_id'] = saleId;
      line['tenant_id'] ??= tenantId;
      line['store_id'] ??= storeId;
      await client.from('sale_items').upsert(line, onConflict: 'id');
    }

    if (kDebugMode && operation != 'upsert') {
      debugPrint('Sync sale $operation → ${saleRow['status']}');
    }
  }

  Future<void> _pushPurchase(
    SupabaseClient client,
    Map<String, dynamic> payload,
  ) async {
    final items = _extractLineItems(payload);
    final purchaseRow = Map<String, dynamic>.from(payload);

    await client.from('purchases').upsert(purchaseRow, onConflict: 'id');
    if (items.isEmpty) return;

    final purchaseId = purchaseRow['id'] as String;
    final tenantId = purchaseRow['tenant_id'] as String;
    final storeId = purchaseRow['store_id'] as String;

    for (final item in items) {
      final line = Map<String, dynamic>.from(item);
      line['purchase_id'] = purchaseId;
      line['tenant_id'] ??= tenantId;
      line['store_id'] ??= storeId;
      await client.from('purchase_items').upsert(line, onConflict: 'id');
    }
  }

  List<Map<String, dynamic>> _extractLineItems(Map<String, dynamic> payload) {
    final nested = payload.remove('items');
    if (nested is! List) return [];
    return nested
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _parentRow(Map<String, dynamic> payload) {
    final copy = Map<String, dynamic>.from(payload);
    copy.remove('items');
    return copy;
  }

  void _normalizePaymentJson(Map<String, dynamic> row) {
    final payment = row['payment_json'];
    if (payment is String) {
      try {
        row['payment_json'] = jsonDecode(payment);
      } catch (_) {
        row['payment_json'] = {'raw': payment};
      }
    }
  }

  /// Pushes system chart/payment accounts directly — never via the user-visible queue.
  Future<void> pushBootstrapAccountingIfNeeded() async {
    final client = supabaseClient;
    if (client == null || client.auth.currentSession == null) return;

    final tenantId = StoreContext.tenantId;
    final storeId = StoreContext.storeId;
    if (storeId.isEmpty ||
        tenantId.isEmpty ||
        storeId == StoreContext.defaultStoreId) {
      return;
    }

    final accounts = await (_db.select(_db.chartOfAccounts)
          ..where(
            (a) =>
                a.tenantId.equals(tenantId) &
                a.storeId.equals(storeId) &
                a.isSystem.equals(true),
          ))
        .get();
    for (final acct in accounts) {
      try {
        await client.from('chart_of_accounts').upsert(
          SyncPayload.chartOfAccount(acct),
          onConflict: 'id',
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Bootstrap COA push ${acct.code}: $e');
        }
      }
    }

    final payAccounts = await (_db.select(_db.paymentAccounts)
          ..where(
            (p) => p.tenantId.equals(tenantId) & p.storeId.equals(storeId),
          ))
        .get();
    for (final pa in payAccounts) {
      try {
        await client.from('payment_accounts').upsert(
          SyncPayload.paymentAccount(pa),
          onConflict: 'id',
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Bootstrap payment account ${pa.name}: $e');
        }
      }
    }
  }
}
