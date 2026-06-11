import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../sync/supabase_bootstrap.dart';
import '../domain/billing_models.dart';

/// Polls + realtime-listens for Waafi push payment confirmation.
class PaymentStatusPoller {
  const PaymentStatusPoller();

  static const pollInterval = Duration(seconds: 2);
  static const maxWait = Duration(minutes: 3);

  Future<PaymentStatusSnapshot?> fetchStatus(String transactionId) async {
    final client = supabaseClient;
    if (client == null) return null;
    try {
      final raw = await client.rpc(
        'inventrax_billing_payment_status',
        params: {'p_transaction_id': transactionId},
      );
      if (raw is Map) {
        return PaymentStatusSnapshot.fromJson(
          Map<String, dynamic>.from(raw),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PaymentStatusPoller] $e');
    }
    return null;
  }

  /// Waits until payment reaches a terminal state (success or failure).
  Future<PaymentStatusSnapshot> waitForCompletion(
    String transactionId, {
    void Function(PaymentStatusSnapshot snap)? onUpdate,
  }) async {
    final client = supabaseClient;
    if (client == null) {
      return PaymentStatusSnapshot(
        transactionId: transactionId,
        status: 'failed',
        errorMessage: 'Supabase not configured',
      );
    }

    final completer = Completer<PaymentStatusSnapshot>();
    RealtimeChannel? channel;
    Timer? pollTimer;
    Timer? timeoutTimer;

    void finish(PaymentStatusSnapshot snap) {
      if (completer.isCompleted) return;
      completer.complete(snap);
      pollTimer?.cancel();
      timeoutTimer?.cancel();
      final ch = channel;
      if (ch != null) {
        client.removeChannel(ch);
      }
    }

    Future<void> check() async {
      final snap = await fetchStatus(transactionId);
      if (snap == null) return;
      onUpdate?.call(snap);
      if (snap.isTerminal) {
        // Completed must have server verification flag before finishing.
        if (snap.status == 'completed' && !snap.isVerifiedSuccess) {
          final refreshed = await fetchStatus(transactionId);
          if (refreshed != null && refreshed.isVerifiedSuccess) {
            onUpdate?.call(refreshed);
            finish(refreshed);
          }
          return;
        }
        finish(snap);
      }
    }

    channel = client.channel('pay:$transactionId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'payment_transactions',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: transactionId,
      ),
      callback: (_) => check(),
    );
    channel.subscribe();

    pollTimer = Timer.periodic(pollInterval, (_) => check());
    timeoutTimer = Timer(maxWait, () {
      finish(
        PaymentStatusSnapshot(
          transactionId: transactionId,
          status: 'expired',
          errorMessage:
              'Payment timed out. Check your phone or try again.',
        ),
      );
    });

    await check();
    return completer.future;
  }
}
