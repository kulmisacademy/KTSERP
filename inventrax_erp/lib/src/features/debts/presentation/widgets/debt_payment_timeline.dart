import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/store_context.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/db_provider.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../data/debts_providers.dart';
import 'debt_ui.dart';

class DebtPaymentTimeline extends ConsumerWidget {
  const DebtPaymentTimeline({
    super.key,
    required this.customerId,
    this.debtId,
  });

  final String customerId;
  final String? debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(storeSettingsProvider).value?.currencyCode ?? 'USD';
    var payments = ref.watch(customerDebtPaymentsProvider(customerId));
    if (debtId != null) {
      payments = payments.where((p) => p.debtId == debtId).toList();
    }

    if (payments.isEmpty) {
      return Text(
        'No payments recorded yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    final accountNames = ref.watch(_paymentAccountNamesProvider).value ?? {};
    final dateFmt = DateFormat('MMM d, yyyy • HH:mm');

    return Column(
      children: [
        for (var i = 0; i < payments.length; i++) ...[
          _TimelineTile(
            payment: payments[i],
            currency: currency,
            accountName: accountNames[payments[i].paymentAccountId],
            dateLabel: dateFmt.format(payments[i].paidAt),
            isFirst: i == 0,
            isLast: i == payments.length - 1,
          ),
        ],
      ],
    );
  }
}

final _paymentAccountNamesProvider =
    FutureProvider.autoDispose<Map<String?, String>>((ref) async {
  final rows = await ref
      .read(appDatabaseProvider)
      .listPaymentAccounts(storeId: StoreContext.storeId);
  return {for (final a in rows) a.id: a.name};
});

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.payment,
    required this.currency,
    required this.accountName,
    required this.dateLabel,
    required this.isFirst,
    required this.isLast,
  });

  final DebtPayment payment;
  final String currency;
  final String? accountName;
  final String dateLabel;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = debtStatusColor('paid', Theme.of(context).brightness);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(width: 2, color: color.withValues(alpha: 0.25)),
                  ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: color.withValues(alpha: 0.25)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatMoney(payment.amountCents, currency: currency),
                              style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                            ),
                          ),
                          if (isFirst)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Latest',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (accountName != null) accountName!,
                          if (payment.method != null) payment.method!,
                        ].join(' • '),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        dateLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (payment.notes != null && payment.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            payment.notes!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
