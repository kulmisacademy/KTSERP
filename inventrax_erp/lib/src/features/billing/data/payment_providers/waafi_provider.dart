import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../../../sync/supabase_bootstrap.dart';
import '../../domain/billing_models.dart';
import '../waafi_error_messages.dart';

/// Waafi Pay mobile push provider — backend only, never exposes secrets.
class WaafiPaymentProvider {
  const WaafiPaymentProvider();

  Future<PaymentResult> purchaseSubscription({
    required String planId,
    required String payerPhone,
    String billingCycle = 'monthly',
    String paymentType = 'subscription',
  }) async {
    return _initiatePush(
      paymentType: paymentType,
      planId: planId,
      payerPhone: payerPhone,
      billingCycle: billingCycle,
    );
  }

  Future<PaymentResult> purchaseSmsPackage({
    required String smsPackageId,
    required String payerPhone,
  }) async {
    return _initiatePush(
      paymentType: 'sms_package',
      smsPackageId: smsPackageId,
      payerPhone: payerPhone,
    );
  }

  /// Initiates mobile push — returns immediately with processing status.
  Future<PaymentResult> _initiatePush({
    required String paymentType,
    required String payerPhone,
    String? planId,
    String? smsPackageId,
    String billingCycle = 'monthly',
  }) async {
    final client = supabaseClient;
    if (client == null) {
      return const PaymentResult(
        outcome: PaymentOutcome.failed,
        error: 'Supabase not configured',
      );
    }

    try {
      final res = await client.functions.invoke(
        'waafi-payment',
        body: {
          'payment_type': paymentType,
          if (planId != null) 'plan_id': planId,
          if (smsPackageId != null) 'sms_package_id': smsPackageId,
          'billing_cycle': billingCycle,
          'payer_phone': payerPhone,
        },
      );

      final data = _map(res.data);

      // 202 = push sent, waiting for PIN on phone
      if (res.status == 202 || data['status'] == 'processing') {
        return PaymentResult(
          outcome: PaymentOutcome.processing,
          transactionId: data['transaction_id']?.toString(),
          message: data['message']?.toString() ??
              'Payment push sent. Check your phone and enter your PIN.',
        );
      }

      if (res.status != 200) {
        return PaymentResult(
          outcome: PaymentOutcome.failed,
          error: parseWaafiErrorFromFunctionBody(data) ??
              data['error']?.toString() ??
              'Payment failed (${res.status})',
          transactionId: data['transaction_id']?.toString(),
        );
      }

      return PaymentResult(
        outcome: PaymentOutcome.completed,
        transactionId: data['transaction_id']?.toString(),
        message: data['message']?.toString() ?? 'Payment successful',
      );
    } on FunctionException catch (e) {
      if (kDebugMode) {
        debugPrint('[WaafiPaymentProvider] ${e.status} ${e.details}');
      }
      final details = e.details is Map
          ? Map<String, dynamic>.from(e.details as Map)
          : <String, dynamic>{};

      // 202 may surface as FunctionException on some SDK versions
      if (e.status == 202 || details['status'] == 'processing') {
        return PaymentResult(
          outcome: PaymentOutcome.processing,
          transactionId: details['transaction_id']?.toString(),
          message: details['message']?.toString() ??
              'Payment push sent. Check your phone and enter your PIN.',
        );
      }

      final friendly = parseWaafiErrorFromFunctionBody(details) ??
          friendlyWaafiError(
            message: details['error']?.toString() ?? e.reasonPhrase,
            responseCode: details['response_code']?.toString(),
          );
      return PaymentResult(
        outcome: PaymentOutcome.failed,
        error: friendly,
        transactionId: details['transaction_id']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[WaafiPaymentProvider] $e');
      return PaymentResult(
        outcome: PaymentOutcome.failed,
        error: friendlyWaafiError(message: e.toString()),
      );
    }
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }
}
