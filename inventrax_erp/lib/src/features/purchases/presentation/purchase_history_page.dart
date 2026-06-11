import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../ui/components/app_skeleton.dart';
import '../../../ui/layout/app_shell.dart';

final purchaseHistoryProvider = StreamProvider.autoDispose<List<Purchase>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchPurchases(storeId: StoreContext.storeId);
});

class PurchaseHistoryPage extends ConsumerWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(purchaseHistoryProvider);
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final dateFmt = DateFormat.yMMMd();

    final l10n = context.l10n;
    return AppShell(
      route: '/purchases',
      child: purchases.when(
        data: (rows) {
          if (rows.isEmpty) {
            return AppEmptyState(
              title: l10n.noPurchases,
              subtitle: l10n.noPurchasesSubtitle,
              icon: Icons.local_shipping_outlined,
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = rows[index];
              final paid = p.paidCents;
              final total = p.totalCents;
              final status = p.paymentStatus;
              final statusLabel = switch (status) {
                'paid' => l10n.statusPaid,
                'partially_paid' => l10n.statusPartial,
                'unpaid' => l10n.statusUnpaid,
                _ => status,
              };
              final statusColor = switch (status) {
                'paid' => Colors.green,
                'partially_paid' => Colors.orange,
                'unpaid' => Colors.red,
                _ => Colors.grey,
              };
              return ListTile(
                onTap: () => context.push('/purchases/${p.id}'),
                title: Text(formatMoney(total, currency: currency)),
                subtitle: Text(
                  '${dateFmt.format(p.purchaseDate)} • '
                  'Paid ${formatMoney(paid, currency: currency)} • $statusLabel',
                ),
                trailing: paid < total
                    ? Chip(
                        label: Text(
                          'Due ${formatMoney(total - paid, currency: currency)}',
                        ),
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                      )
                    : Icon(Icons.check_circle, color: statusColor),
              );
            },
          );
        },
        loading: () => const ListPageSkeleton(),
        error: (e, _) => Center(child: Text(userFriendlyError(e))),
      ),
    );
  }
}
