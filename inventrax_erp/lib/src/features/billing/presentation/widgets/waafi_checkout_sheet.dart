import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/ux/responsive_dialogs.dart';
import '../../../auth/application/registration_validator.dart';
import '../../application/billing_providers.dart';
import '../../application/subscription_lock_provider.dart';
import '../../domain/billing_models.dart';

/// Waafi mobile push checkout — success only after server-verified payment.
class WaafiCheckoutSheet extends ConsumerStatefulWidget {
  const WaafiCheckoutSheet({
    super.key,
    required this.title,
    required this.amountLabel,
    required this.onInitiatePayment,
  });

  final String title;
  final String amountLabel;
  final Future<PaymentResult> Function(String payerPhone) onInitiatePayment;

  static Future<PaymentResult?> show(
    BuildContext context, {
    required String title,
    required String amountLabel,
    required Future<PaymentResult> Function(String payerPhone) onInitiatePayment,
  }) {
    return showAppBottomSheet<PaymentResult>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      builder: (ctx) => WaafiCheckoutSheet(
        title: title,
        amountLabel: amountLabel,
        onInitiatePayment: onInitiatePayment,
      ),
    );
  }

  @override
  ConsumerState<WaafiCheckoutSheet> createState() => _WaafiCheckoutSheetState();
}

class _WaafiCheckoutSheetState extends ConsumerState<WaafiCheckoutSheet>
    with SingleTickerProviderStateMixin {
  final _phone = TextEditingController();
  PaymentCheckoutPhase _phase = PaymentCheckoutPhase.idle;
  String? _error;
  String? _transactionId;
  String _statusLine = '';
  PaymentStatusSnapshot? _verifiedSnapshot;
  var _payLocked = false;
  late final AnimationController _pulse;

  static const _sheetMinHeight = 340.0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _setPhase(PaymentCheckoutPhase phase, {String? statusLine}) {
    if (!mounted) return;
    setState(() {
      _phase = phase;
      if (statusLine != null) _statusLine = statusLine;
    });
  }

  Future<void> _submit() async {
    if (_payLocked) return;
    final check = RegistrationValidator.validatePhone(_phone.text);
    if (!check.isValid) {
      setState(() => _error = check.message ?? 'Invalid phone');
      return;
    }

    final phone = RegistrationValidator.normalizePhoneE164(_phone.text);
    _payLocked = true;
    final l10n = context.l10n;
    _setPhase(
      PaymentCheckoutPhase.sendingRequest,
      statusLine: l10n.waafiSendingRequestStatus,
    );

    try {
      final initiated = await widget.onInitiatePayment(phone);
      if (!mounted) return;

      if (initiated.outcome == PaymentOutcome.failed) {
        _stopPulse();
        _payLocked = false;
        setState(() {
          _phase = PaymentCheckoutPhase.failed;
          _error = initiated.error ?? l10n.waafiPaymentFailed;
        });
        return;
      }

      final txId = initiated.transactionId;
      if (txId == null || txId.isEmpty) {
        _stopPulse();
        _payLocked = false;
        setState(() {
          _phase = PaymentCheckoutPhase.failed;
          _error = 'No transaction ID returned';
        });
        return;
      }

      _transactionId = txId;
      _pulse.repeat();
      _setPhase(
        PaymentCheckoutPhase.waitingConfirmation,
        statusLine: 'Payment request sent. Check your phone and enter your PIN.',
      );

      final paymentService = ref.read(paymentServiceProvider);
      final result = await paymentService.waitForVerifiedCompletion(
        txId,
        onStatusUpdate: (snap) {
          if (!mounted) return;
          if (snap.status == 'processing') {
            _setPhase(
              PaymentCheckoutPhase.processing,
              statusLine: 'Processing payment confirmation…',
            );
          } else if (snap.status == 'pending' || snap.status == 'processing') {
            _setPhase(
              PaymentCheckoutPhase.waitingConfirmation,
              statusLine: l10n.waafiWaitingConfirmation,
            );
          }
        },
      );

      if (!mounted) return;
      _stopPulse();

      if (result.outcome == PaymentOutcome.completed &&
          result.statusSnapshot?.isVerifiedSuccess == true) {
        setState(() {
          _phase = PaymentCheckoutPhase.success;
          _verifiedSnapshot = result.statusSnapshot;
        });
        ref.invalidate(storeBillingProvider);
        ref.invalidate(subscriptionLockProvider);
        await Future<void>.delayed(const Duration(milliseconds: 1600));
        if (mounted) Navigator.pop(context, result);
      } else {
        _payLocked = false;
        final status = result.statusSnapshot?.status ?? 'failed';
        setState(() {
          _phase = status == 'expired'
              ? PaymentCheckoutPhase.timeout
              : status == 'cancelled'
                  ? PaymentCheckoutPhase.cancelled
                  : PaymentCheckoutPhase.failed;
          _error = result.error ?? 'Payment was not completed. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      _stopPulse();
      _payLocked = false;
      setState(() {
        _phase = PaymentCheckoutPhase.failed;
        _error = e.toString();
      });
    }
  }

  Future<void> _cancel() async {
    final txId = _transactionId;
    if (txId != null) {
      await ref.read(paymentServiceProvider).cancelPendingPayment(txId);
    }
    _stopPulse();
    if (mounted) {
      Navigator.pop(
        context,
        const PaymentResult(
          outcome: PaymentOutcome.failed,
          error: 'Payment cancelled',
        ),
      );
    }
  }

  void _stopPulse() {
    if (_pulse.isAnimating) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  void _retry() {
    _payLocked = false;
    _transactionId = null;
    _verifiedSnapshot = null;
    setState(() {
      _phase = PaymentCheckoutPhase.idle;
      _error = null;
      _statusLine = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _sheetMinHeight),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.topCenter,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            child: _buildPhase(scheme),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase(ColorScheme scheme) {
    return switch (_phase) {
      PaymentCheckoutPhase.idle => _PhonePhase(
          key: const ValueKey('idle'),
          scheme: scheme,
          title: widget.title,
          amountLabel: widget.amountLabel,
          phone: _phone,
          error: _error,
          payLocked: _payLocked,
          onPay: _submit,
        ),
      PaymentCheckoutPhase.sendingRequest ||
      PaymentCheckoutPhase.waitingConfirmation ||
      PaymentCheckoutPhase.processing =>
        _WaitingPhase(
          key: ValueKey('wait-${_phase.name}'),
          scheme: scheme,
          pulse: _pulse,
          phone: _phone.text,
          phase: _phase,
          statusLine: _statusLine,
          onCancel: _cancel,
        ),
      PaymentCheckoutPhase.success => _SuccessPhase(
          key: const ValueKey('success'),
          scheme: scheme,
          snapshot: _verifiedSnapshot,
        ),
      PaymentCheckoutPhase.timeout => _FailedPhase(
          key: const ValueKey('timeout'),
          scheme: scheme,
          title: context.l10n.waafiPaymentTimedOut,
          error: _error ?? context.l10n.waafiNoPinConfirmation,
          onRetry: _retry,
          onClose: () => Navigator.pop(context, null),
        ),
      PaymentCheckoutPhase.cancelled => _FailedPhase(
          key: const ValueKey('cancelled'),
          scheme: scheme,
          title: context.l10n.waafiPaymentCancelled,
          error: _error ?? context.l10n.waafiPaymentCancelledDefault,
          onRetry: _retry,
          onClose: () => Navigator.pop(context, null),
        ),
      PaymentCheckoutPhase.failed => _FailedPhase(
          key: const ValueKey('failed'),
          scheme: scheme,
          title: context.l10n.waafiPaymentNotCompleted,
          error: _error ?? context.l10n.waafiPaymentFailed,
          onRetry: _retry,
          onClose: () => Navigator.pop(context, null),
        ),
    };
  }
}

class _PhonePhase extends StatelessWidget {
  const _PhonePhase({
    super.key,
    required this.scheme,
    required this.title,
    required this.amountLabel,
    required this.phone,
    required this.onPay,
    required this.payLocked,
    this.error,
  });

  final ColorScheme scheme;
  final String title;
  final String amountLabel;
  final TextEditingController phone;
  final VoidCallback onPay;
  final bool payLocked;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Handle(scheme: scheme),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          amountLabel,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.waafiInstructions,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          autofocus: true,
          enabled: !payLocked,
          decoration: InputDecoration(
            labelText: l10n.waafiPhoneLabel,
            hintText: l10n.waafiPhoneHint,
            prefixIcon: const Icon(Icons.phone_android_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error!, style: TextStyle(color: scheme.error, fontSize: 13)),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: payLocked ? null : onPay,
          icon: const Icon(Icons.send_to_mobile_outlined),
          label: Text(l10n.waafiSendPayment),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _WaitingPhase extends StatelessWidget {
  const _WaitingPhase({
    super.key,
    required this.scheme,
    required this.pulse,
    required this.phone,
    required this.phase,
    required this.statusLine,
    required this.onCancel,
  });

  final ColorScheme scheme;
  final AnimationController pulse;
  final String phone;
  final PaymentCheckoutPhase phase;
  final String statusLine;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final headline = switch (phase) {
      PaymentCheckoutPhase.sendingRequest => l10n.waafiSendingRequest,
      PaymentCheckoutPhase.processing => l10n.waafiProcessingPayment,
      _ => l10n.waafiWaitingConfirmation,
    };

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(scheme: scheme),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: pulse,
            builder: (_, child) {
              final scale = phase == PaymentCheckoutPhase.sendingRequest
                  ? 1.0
                  : 1.0 + (pulse.value * 0.07);
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer.withValues(alpha: 0.5),
              ),
              child: Icon(
                phase == PaymentCheckoutPhase.sendingRequest
                    ? Icons.cloud_upload_outlined
                    : Icons.phonelink_ring_outlined,
                size: 44,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          if (phase != PaymentCheckoutPhase.sendingRequest) ...[
            Text(
              l10n.waafiPaymentSentTo(phone),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.waafiEnterPin,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ] else
            Text(
              statusLine,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: scheme.primary,
            ),
          ),
          if (phase != PaymentCheckoutPhase.sendingRequest) ...[
            const SizedBox(height: 20),
            TextButton(onPressed: onCancel, child: Text(l10n.waafiCancelPayment)),
          ],
        ],
      ),
    );
  }
}

class _SuccessPhase extends StatelessWidget {
  const _SuccessPhase({
    super.key,
    required this.scheme,
    required this.snapshot,
  });

  final ColorScheme scheme;
  final PaymentStatusSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = snapshot?.activationDetail;
    final balance = snapshot?.walletBalance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Handle(scheme: scheme),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
          child: Icon(Icons.check_circle_rounded, size: 72, color: scheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.waafiPaymentSuccess,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        if (detail != null)
          Text(
            detail,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        if (balance != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.waafiWalletBalance(balance ?? 0),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _FailedPhase extends StatelessWidget {
  const _FailedPhase({
    super.key,
    required this.scheme,
    required this.title,
    required this.error,
    required this.onRetry,
    required this.onClose,
  });

  final ColorScheme scheme;
  final String title;
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Handle(scheme: scheme),
        const SizedBox(height: 12),
        Icon(Icons.error_outline_rounded, size: 56, color: scheme.error),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: onRetry, child: Text(l10n.waafiTryAgain)),
        const SizedBox(height: 8),
        TextButton(onPressed: onClose, child: Text(l10n.commonClose)),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: scheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
