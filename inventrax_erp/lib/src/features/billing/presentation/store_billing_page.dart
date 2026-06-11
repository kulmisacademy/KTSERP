import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../application/subscription_lock_provider.dart';
import '../../../ui/layout/app_shell.dart';
import '../../platform/domain/platform_models.dart';
import '../application/billing_providers.dart';
import '../domain/billing_models.dart';
import 'widgets/waafi_checkout_sheet.dart';

class StoreBillingPage extends ConsumerWidget {
  const StoreBillingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billing = ref.watch(storeBillingProvider);
    final plans = ref.watch(activePlansProvider);
    final transactions = ref.watch(storeTransactionsProvider);
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return AppShell(
      route: '/billing',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(storeBillingProvider);
          ref.invalidate(activePlansProvider);
          ref.invalidate(storeTransactionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.billingTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.billingSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            billing.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e', style: TextStyle(color: scheme.error)),
              data: (snap) {
                if (snap == null) {
                  return Text(l10n.billingUnavailableOffline);
                }
                return _CurrentPlanCard(
                  snapshot: snap,
                  onRenew: () => _scrollToPlans(context),
                  onUpgrade: () => _scrollToPlans(context),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Upgrade plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            plans.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (list) => _PlanGrid(
                plans: list.where((p) => p.id != 'free_trial').toList(),
                onSelect: (plan) => _checkoutPlan(context, ref, plan),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.billingPaymentHistory,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            transactions.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (txs) {
                if (txs.isEmpty) {
                  return Text(
                    l10n.billingNoTransactions,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  );
                }
                return Column(
                  children: txs
                      .take(10)
                      .map((t) => _TransactionTile(tx: t))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToPlans(BuildContext context) {
    // Plans section is below the fold — user lands on billing with plans visible.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.billingChoosePlanBelow)),
    );
  }

  Future<void> _checkoutPlan(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
  ) async {
    final amount = formatMoney(plan.monthlyPriceCents, currency: 'USD');
    final result = await WaafiCheckoutSheet.show(
      context,
      title: context.l10n.billingSubscribeTo(plan.name),
      amountLabel: '$amount / month',
      onInitiatePayment: (phone) => ref
          .read(paymentServiceProvider)
          .payForSubscription(
            planId: plan.id,
            payerPhone: phone,
            paymentType: 'upgrade',
          ),
    );
    if (result?.success == true && context.mounted) {
      ref.invalidate(storeBillingProvider);
      ref.invalidate(storeTransactionsProvider);
      ref.invalidate(subscriptionLockProvider);
      final detail = result?.statusSnapshot?.activationDetail ??
          '${plan.name} subscription activated.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail)),
      );
    }
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.snapshot,
    this.onRenew,
    this.onUpgrade,
  });

  final StoreBillingSnapshot snapshot;
  final VoidCallback? onRenew;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final sub = snapshot.subscription;
    final scheme = Theme.of(context).colorScheme;
    final days = sub.daysRemaining ?? 0;
    final expLabel = sub.isTrialing
        ? 'Trial ends in $days days'
        : sub.currentPeriodEnd != null
            ? 'Renews ${sub.currentPeriodEnd!.toLocal().toString().split(' ').first}'
            : 'Active';

    return Card(
      elevation: 0,
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  sub.planName ?? 'Plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    (sub.status ?? 'unknown').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(expLabel, style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            _MiniStat(
              label: context.l10n.billingCycleLabel,
              value: sub.billingCycle ?? 'monthly',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onRenew != null)
                  FilledButton.tonal(
                    onPressed: onRenew,
                    child: Text(context.l10n.billingRenewPlan),
                  ),
                if (onUpgrade != null)
                  OutlinedButton(
                    onPressed: onUpgrade,
                    child: Text(context.l10n.billingUpgrade),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _PlanGrid extends StatelessWidget {
  const _PlanGrid({required this.plans, required this.onSelect});
  final List<SubscriptionPlan> plans;
  final void Function(SubscriptionPlan plan) onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 900 ? 3 : c.maxWidth >= 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: cols == 1 ? 1.4 : 0.85,
          ),
          itemCount: plans.length,
          itemBuilder: (context, i) {
            final p = plans[i];
            final price = formatMoney(p.monthlyPriceCents, currency: 'USD');
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text('/ month', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    if (p.description != null)
                      Text(
                        p.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => onSelect(p),
                      child: const Text('Choose plan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});
  final PaymentTransaction tx;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ok = tx.status == 'completed';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: ok
            ? Colors.green.shade50
            : scheme.surfaceContainerHighest,
        child: Icon(
          ok ? Icons.check_circle_outline : Icons.pending_outlined,
          color: ok ? Colors.green.shade700 : scheme.onSurfaceVariant,
        ),
      ),
      title: Text('${tx.paymentType} • ${tx.status}'),
      subtitle: Text(tx.createdAt?.toLocal().toString().split('.').first ?? ''),
      trailing: Text(
        formatMoney(tx.amountCents, currency: tx.currencyCode),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
