import 'package:inventrax_erp/l10n/app_localizations.dart';

/// Domain string helpers — maps DB codes to localized labels.
extension ErpL10n on AppLocalizations {
  String paymentStatusLabel(String status) {
    final key = status.toLowerCase();
    return switch (key) {
      'paid' => statusPaid,
      'partial' => statusPartial,
      'unpaid' => statusUnpaid,
      'refunded' => statusRefunded,
      'voided' => statusVoided,
      'void' => statusVoided,
      _ => status,
    };
  }

  String saleStatusLabel(String status, {int refundedTotalCents = 0}) {
    if (status == 'voided') return statusVoided;
    if (refundedTotalCents > 0) return statusRefunded;
    return paymentStatusLabel(status);
  }

  String debtStatusLabel(String status) {
    return switch (status) {
      'paid' => statusPaid,
      'partially_paid' => debtStatusPartiallyPaid,
      'pending' => debtStatusActive,
      'active' || 'unpaid' => debtStatusActive,
      'overdue' => debtStatusOverdue,
      _ => status,
    };
  }
}
