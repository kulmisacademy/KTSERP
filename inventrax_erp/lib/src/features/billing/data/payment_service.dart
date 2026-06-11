import '../domain/billing_models.dart';
import 'billing_repository.dart';
import 'payment_providers/waafi_provider.dart';
import 'payment_status_poller.dart';

enum PaymentProviderType { waafi }

/// Unified payment facade — activation is server-verified only.
class PaymentService {
  const PaymentService({
    WaafiPaymentProvider? waafi,
    PaymentStatusPoller? poller,
    BillingRepository? billing,
  })  : _waafi = waafi ?? const WaafiPaymentProvider(),
        _poller = poller ?? const PaymentStatusPoller(),
        _billing = billing ?? const BillingRepository();

  final WaafiPaymentProvider _waafi;
  final PaymentStatusPoller _poller;
  final BillingRepository _billing;

  Future<PaymentResult> payForSubscription({
    required String planId,
    required String payerPhone,
    String billingCycle = 'monthly',
    PaymentProviderType provider = PaymentProviderType.waafi,
    String paymentType = 'subscription',
  }) async {
    switch (provider) {
      case PaymentProviderType.waafi:
        return _waafi.purchaseSubscription(
          planId: planId,
          payerPhone: payerPhone,
          billingCycle: billingCycle,
          paymentType: paymentType,
        );
    }
  }

  /// Waits until backend confirms `status=completed` with `verified=true`.
  Future<PaymentResult> waitForVerifiedCompletion(
    String transactionId, {
    void Function(PaymentStatusSnapshot snap)? onStatusUpdate,
  }) async {
    final snap = await _poller.waitForCompletion(
      transactionId,
      onUpdate: onStatusUpdate,
    );

    if (snap.status == 'completed') {
      final verified = await _billing.fetchPaymentStatus(transactionId);
      if (verified != null && verified.isVerifiedSuccess) {
        return PaymentResult(
          outcome: PaymentOutcome.completed,
          transactionId: transactionId,
          message: verified.activationDetail ?? 'Payment successful',
          statusSnapshot: verified,
        );
      }
      return PaymentResult(
        outcome: PaymentOutcome.failed,
        transactionId: transactionId,
        error: 'Payment received but subscription was not activated. '
            'Please contact support or try again.',
      );
    }

    return PaymentResult(
      outcome: PaymentOutcome.failed,
      transactionId: transactionId,
      error: snap.errorMessage ?? _statusMessage(snap.status),
      statusSnapshot: snap,
    );
  }

  Future<bool> cancelPendingPayment(String transactionId) async {
    return _billing.cancelPayment(transactionId);
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'cancelled':
        return 'Payment was cancelled.';
      case 'expired':
        return 'Payment timed out. No PIN confirmation received.';
      case 'failed':
        return 'Payment was not completed. Please try again.';
      default:
        return 'Payment was not completed.';
    }
  }
}
