import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/store/store_branding.dart';
import '../../../core/l10n/erp_l10n.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/widgets/local_file_image.dart';
import 'widgets/debt_ui.dart';

final publicDebtProvider = FutureProvider.autoDispose
    .family<
        ({
          DebtShareLink link,
          Customer customer,
          List<Debt> debts,
          List<DebtPayment> payments,
          String storeName,
          String? logoLocalPath,
          String? logoUrl,
          String? phone,
          String? address,
        })?,
        String>(
  (ref, token) async {
    final db = ref.read(appDatabaseProvider);
    final link = await db.getShareLinkByToken(token);
    if (link == null) return null;

    final customer = await db.getCustomerById(
      storeId: link.storeId,
      customerId: link.customerId,
    );
    if (customer == null) return null;

    final debts = await db.listCustomerDebts(
      storeId: link.storeId,
      customerId: link.customerId,
    );

    final payments = await db.listPaymentsForCustomer(
      storeId: link.storeId,
      customerId: link.customerId,
    );

    final settings = await db.getStoreSettings(storeId: link.storeId);

    return (
      link: link,
      customer: customer,
      debts: debts,
      payments: payments,
      storeName: StoreBranding.displayName(settings),
      logoLocalPath: settings?.logoLocalPath,
      logoUrl: StoreBranding.logoUrlWithCacheBust(settings),
      phone: settings?.phone,
      address: settings?.address,
    );
  },
);

class PublicDebtPage extends ConsumerWidget {
  const PublicDebtPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(publicDebtProvider(token));
    final theme = Theme.of(context);

    return Scaffold(
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bundle) {
          if (bundle == null) {
            return const Center(child: Text('Debt link not found or expired.'));
          }
          final remaining = bundle.debts
              .where((d) => d.remainingCents > 0)
              .fold<int>(0, (s, d) => s + d.remainingCents);
          const currency = 'USD';

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bundle.logoLocalPath != null || bundle.logoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: _DebtStoreLogo(
                              localPath: bundle.logoLocalPath,
                              remoteUrl: bundle.logoUrl,
                            ),
                          ),
                        ),
                      ),
                    Text(bundle.storeName),
                    if (bundle.phone != null && bundle.phone!.isNotEmpty)
                      Text(
                        bundle.phone!,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                            'Balance: ${formatMoney(remaining, currency: currency)}\n'
                            'https://inventrax.app/debt/$token',
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      bundle.customer.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (bundle.customer.phone != null)
                      Text(bundle.customer.phone!),
                    const SizedBox(height: 20),
                    DebtKpiCard(
                      label: 'Remaining balance',
                      value: formatMoney(remaining, currency: currency),
                      icon: Icons.account_balance_wallet,
                      color: debtStatusColor(
                        remaining > 0 ? 'active' : 'paid',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Invoices',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final d in bundle.debts)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            'Invoice ${d.invoiceNumber ?? d.id.substring(0, 8)}',
                          ),
                          subtitle: Text(
                            '${context.l10n.debtStatusLabel(d.status)} • '
                            '${formatMoney(d.remainingCents, currency: currency)} due',
                          ),
                          trailing: Icon(
                            Icons.circle,
                            size: 12,
                            color: debtStatusColor(
                              d.status,
                              Theme.of(context).brightness,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment history',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (bundle.payments.isEmpty)
                      const Text('No payments yet.')
                    else
                      for (final p in bundle.payments)
                        ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(
                            formatMoney(p.amountCents, currency: currency),
                          ),
                          subtitle: Text('${p.paidAt}'),
                        ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DebtStoreLogo extends StatelessWidget {
  const _DebtStoreLogo({this.localPath, this.remoteUrl});

  final String? localPath;
  final String? remoteUrl;

  @override
  Widget build(BuildContext context) {
    final local = buildLocalFileImage(
      localPath,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    );
    if (local != null) return local;
    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      return Image.network(
        remoteUrl!,
        key: ValueKey(remoteUrl),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.storefront_outlined),
      );
    }
    return const Icon(Icons.storefront_outlined);
  }
}
