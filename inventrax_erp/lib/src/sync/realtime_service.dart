import 'dart:convert';
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/store/active_store_scope.dart';
import '../core/store_context.dart';
import '../core/utils/date_time_parse.dart';
import '../core/supabase_config.dart';
import '../data/local/app_database.dart';
import '../data/local/db_provider.dart';
import '../features/pos/presentation/pos_products_provider.dart';
import '../observability/monitoring_bootstrap.dart';
import '../observability/observability_hub.dart';
import 'supabase_bootstrap.dart';

/// Lightweight realtime subscriptions:
/// - products: react to stock/price updates
/// - sales: react to new sales from other devices
/// - debt_payments: react to payments
///
/// Strategy: minimal payload handling → fetch only the changed row(s) and upsert
/// locally (unless the row has a pending local sync).
class RealtimeService extends Notifier<void> {
  RealtimeChannel? _channel;
  StreamSubscription<AuthState>? _authSub;
  DateTime? _lastReconnectAttempt;
  String? _boundStoreId;
  Timer? _productInvalidateDebounce;
  static const _reconnectThrottle = Duration(seconds: 15);
  static const _invalidateDebounce = Duration(milliseconds: 400);

  @override
  void build() {
    final db = ref.watch(appDatabaseProvider);
    final scope = ref.watch(activeStoreScopeProvider);

    ref.onDispose(() async {
      _productInvalidateDebounce?.cancel();
      await _stop();
    });

    if (!SupabaseConfig.isConfigured || supabaseClient == null) return;
    if (!StoreContext.isLoggedIn) return;
    if (scope.storeId.isEmpty || scope.storeId == StoreContext.defaultStoreId) {
      return;
    }

    if (_boundStoreId != scope.storeId) {
      unawaited(_rebind(db, scope.tenantId, scope.storeId));
    }
  }

  Future<void> _rebind(AppDatabase db, String tenantId, String storeId) async {
    await _stop();
    _boundStoreId = storeId;
    _start(db, tenantId: tenantId, storeId: storeId);
  }

  void _start(
    AppDatabase db, {
    required String tenantId,
    required String storeId,
  }) {
    final client = supabaseClient;
    if (client == null) return;

    // Recreate channel on auth changes (token refresh/sign-out).
    _authSub ??= client.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedOut) {
        await _stop();
      }
    });

    _channel = client.channel('rt:$storeId');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'store_id',
            value: storeId,
          ),
          callback: (payload) => _onProductChanged(db, tenantId, storeId, payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'sales',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'store_id',
            value: storeId,
          ),
          callback: (payload) => _onSaleInserted(db, tenantId, storeId, payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'debt_payments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'store_id',
            value: storeId,
          ),
          callback: (payload) =>
              _onDebtPaymentInserted(db, tenantId, storeId, payload),
        );

    _channel!.subscribe((status, err) {
      final hub = ObservabilityHub.instance;
      if (status == RealtimeSubscribeStatus.subscribed) {
        hub.setRealtime(
          RealtimeConnectionState.connected,
          detail: 'Subscribed',
        );
      } else if (status == RealtimeSubscribeStatus.channelError) {
        hub.setRealtime(
          RealtimeConnectionState.failed,
          detail: err?.toString() ?? 'Channel error',
        );
        MonitoringService.captureException(
          err ?? 'Realtime channel error',
          hint: 'realtime_disconnect',
        );
        _scheduleReconnect(db);
      } else if (status == RealtimeSubscribeStatus.timedOut) {
        hub.setRealtime(
          RealtimeConnectionState.reconnecting,
          detail: 'Timed out',
        );
        _scheduleReconnect(db);
      } else if (status == RealtimeSubscribeStatus.closed) {
        hub.setRealtime(
          RealtimeConnectionState.disconnected,
          detail: 'Closed',
        );
      }
      if (kDebugMode) debugPrint('Realtime status: $status err=$err');
    });
  }

  Future<void> _stop() async {
    ObservabilityHub.instance.setRealtime(
      RealtimeConnectionState.disconnected,
      detail: 'Stopped',
    );
    final client = supabaseClient;
    final channel = _channel;
    _channel = null;
    _boundStoreId = null;
    if (channel != null && client != null) {
      await client.removeChannel(channel);
    }
    await _authSub?.cancel();
    _authSub = null;
  }

  Future<void> _onProductChanged(
    AppDatabase db,
    String tenantId,
    String storeId,
    PostgresChangePayload payload,
  ) async {
    final id = _idFromPayload(payload);
    if (id == null) return;

    if (await db.hasPendingSyncForEntity(
      storeId: storeId,
      entity: 'products',
      entityId: id,
    )) {
      return;
    }

    final client = supabaseClient;
    if (client == null) return;

    final row = await client
        .from('products')
        .select()
        .eq('id', id)
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId)
        .maybeSingle();
    if (row == null) return;

    await db.upsertProductFromCloud(
      ProductsCompanion(
        id: Value(id),
        tenantId: Value(tenantId),
        storeId: Value(storeId),
        name: Value(row['name'] as String? ?? 'Product'),
        barcode: Value(row['barcode'] as String?),
        sku: Value(row['sku'] as String?),
        quantity: Value((row['quantity'] as num?)?.toInt() ?? 0),
        purchasePriceCents:
            Value((row['purchase_price_cents'] as num?)?.toInt() ?? 0),
        sellingPriceCents:
            Value((row['selling_price_cents'] as num?)?.toInt() ?? 0),
        updatedAt: Value(_parseDate(row['updated_at']) ?? DateTime.now()),
        imageUrl: Value(row['image_url'] as String?),
        thumbnailUrl: Value(row['thumbnail_url'] as String?),
        categoryIcon: Value(row['category_icon'] as String?),
        hasImage: Value(row['has_image'] as bool? ?? false),
      ),
    );
    _schedulePosProductsInvalidate();
  }

  Future<void> _onSaleInserted(
    AppDatabase db,
    String tenantId,
    String storeId,
    PostgresChangePayload payload,
  ) async {
    final saleId = _idFromPayload(payload);
    if (saleId == null) return;

    if (await db.hasPendingSyncForEntity(
      storeId: storeId,
      entity: 'sales',
      entityId: saleId,
    )) {
      return;
    }

    final client = supabaseClient;
    if (client == null) return;

    final sale = await client
        .from('sales')
        .select()
        .eq('id', saleId)
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId)
        .maybeSingle();
    if (sale == null) return;

    final items = await client
        .from('sale_items')
        .select()
        .eq('sale_id', saleId)
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId) as List;

    final stockApplied = await db.upsertSaleFromCloud(
      applyStockDeduction: true,
      sale: SalesCompanion(
        id: Value(saleId),
        tenantId: Value(tenantId),
        storeId: Value(storeId),
        customerId: Value(sale['customer_id'] as String?),
        subtotalCents: Value((sale['subtotal_cents'] as num?)?.toInt() ?? 0),
        discountCents: Value((sale['discount_cents'] as num?)?.toInt() ?? 0),
        taxCents: Value((sale['tax_cents'] as num?)?.toInt() ?? 0),
        totalCents: Value((sale['total_cents'] as num?)?.toInt() ?? 0),
        refundedTotalCents:
            Value((sale['refunded_total_cents'] as num?)?.toInt() ?? 0),
        status: Value(sale['status'] as String? ?? 'completed'),
        paymentJson: Value(jsonEncode(sale['payment_json'] ?? {})),
        paidCents: Value((sale['paid_cents'] as num?)?.toInt() ?? 0),
        paymentStatus: Value(sale['payment_status'] as String? ?? 'paid'),
        createdAt: Value(_parseDate(sale['created_at']) ?? DateTime.now()),
      ),
      items: [
        for (final raw in items)
          SaleItemsCompanion(
            id: Value((raw as Map)['id'] as String),
            tenantId: Value(tenantId),
            storeId: Value(storeId),
            saleId: Value(saleId),
            productId: Value(raw['product_id'] as String?),
            name: Value(raw['name'] as String? ?? 'Item'),
            quantity: Value((raw['quantity'] as num?)?.toInt() ?? 0),
            unitPriceCents: Value((raw['unit_price_cents'] as num?)?.toInt() ?? 0),
            lineTotalCents: Value((raw['line_total_cents'] as num?)?.toInt() ?? 0),
            refundedQuantity:
                Value((raw['refunded_quantity'] as num?)?.toInt() ?? 0),
          ),
      ],
    );

    if (stockApplied) {
      _schedulePosProductsInvalidate();
      if (kDebugMode) {
        debugPrint('[Realtime] Stock deducted for remote sale $saleId');
      }
    }
  }

  void _schedulePosProductsInvalidate() {
    _productInvalidateDebounce?.cancel();
    _productInvalidateDebounce = Timer(_invalidateDebounce, () {
      ref.invalidate(posProductsProvider);
    });
  }

  void _scheduleReconnect(AppDatabase db) {
    final now = DateTime.now();
    if (_lastReconnectAttempt != null &&
        now.difference(_lastReconnectAttempt!) < _reconnectThrottle) {
      return;
    }
    _lastReconnectAttempt = now;
    final tenantId = StoreContext.tenantId;
    final storeId = StoreContext.storeId;
    Future.delayed(_reconnectThrottle, () async {
      if (!StoreContext.isLoggedIn) return;
      if (storeId.isEmpty || storeId == StoreContext.defaultStoreId) return;
      await _rebind(db, tenantId, storeId);
    });
  }

  Future<void> _onDebtPaymentInserted(
    AppDatabase db,
    String tenantId,
    String storeId,
    PostgresChangePayload payload,
  ) async {
    final id = _idFromPayload(payload);
    if (id == null) return;

    if (await db.hasPendingSyncForEntity(
      storeId: storeId,
      entity: 'debt_payments',
      entityId: id,
    )) {
      return;
    }

    final client = supabaseClient;
    if (client == null) return;

    final row = await client
        .from('debt_payments')
        .select()
        .eq('id', id)
        .eq('tenant_id', tenantId)
        .eq('store_id', storeId)
        .maybeSingle();
    if (row == null) return;

    await db.upsertDebtPaymentFromCloud(
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
      ),
    );
  }

  String? _idFromPayload(PostgresChangePayload payload) {
    final data = payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord;
    final id = data['id'];
    return id is String && id.isNotEmpty ? id : null;
  }

  DateTime? _parseDate(Object? value) => SafeDateTime.tryParse(value);
}

final realtimeServiceProvider = NotifierProvider<RealtimeService, void>(
  RealtimeService.new,
);

