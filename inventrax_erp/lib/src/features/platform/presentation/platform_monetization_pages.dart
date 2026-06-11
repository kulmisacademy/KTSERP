import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../billing/application/billing_providers.dart';
import 'widgets/platform_widgets.dart';

class PlatformStoreSubscriptionsPage extends ConsumerWidget {
  const PlatformStoreSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final subs = ref.watch(platformStoreSubscriptionsProvider);
    return ListView(
      children: [
        PlatformPageHeader(
          title: l10n.platformStoreSubscriptionsTitle,
          subtitle: l10n.platformStoreSubscriptionsSubtitle,
        ),
        subs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
          data: (rows) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: rows.map((r) {
                final store = r['stores'] as Map?;
                final plan = r['subscription_plans'] as Map?;
                return Card(
                  child: ListTile(
                    title: Text(store?['name']?.toString() ?? l10n.platformStoreLabel),
                    subtitle: Text(
                      '${plan?['name'] ?? r['plan_name']} • ${r['status']} • ${r['billing_cycle'] ?? 'monthly'}',
                    ),
                    trailing: Text(
                      r['trial_ends_at'] != null ? l10n.platformTrial : l10n.platformPaid,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class PlatformTransactionsPage extends ConsumerWidget {
  const PlatformTransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final txs = ref.watch(platformTransactionsProvider);
    return ListView(
      children: [
        PlatformPageHeader(
          title: l10n.platformTransactionsTitle,
          subtitle: l10n.platformTransactionsSubtitle,
        ),
        txs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
          data: (list) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: list.map((t) {
                return Card(
                  child: ListTile(
                    title: Text('${t.paymentType} • ${t.status}'),
                    subtitle: Text(
                      '${t.provider ?? 'waafi'} • ${t.createdAt?.toLocal()}',
                    ),
                    trailing: Text(
                      formatMoney(t.amountCents, currency: t.currencyCode),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class PlatformPaymentGatewayPage extends ConsumerWidget {
  const PlatformPaymentGatewayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(billingSettingsProvider);
    return ListView(
      children: [
        PlatformPageHeader(
          title: l10n.platformPaymentGatewayTitle,
          subtitle: l10n.platformPaymentGatewaySubtitle,
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: settings.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (s) {
              if (s == null) return Text(l10n.platformNoSettings);
              return Card(
                child: Padding(
                  padding: AppSpacing.cardLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: Text(l10n.platformWaafiEnabled),
                        value: s['waafi_enabled'] as bool? ?? true,
                        onChanged: (v) => _patch(ref, {'waafi_enabled': v}),
                      ),
                      SwitchListTile(
                        title: Text(l10n.platformWaafiSandbox),
                        value: s['waafi_sandbox'] as bool? ?? true,
                        onChanged: (v) => _patch(ref, {'waafi_sandbox': v}),
                      ),
                      const Divider(),
                      Text(
                        l10n.platformGatewaySecretsHelp,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                      AppSpacing.gapMd(),
                      const Text(
                        'Docs: https://docs.waafipay.com/',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _patch(WidgetRef ref, Map<String, dynamic> patch) async {
    await ref.read(billingRepositoryProvider).updateBillingSettings(patch);
    ref.invalidate(billingSettingsProvider);
  }
}

class PlatformTrialSettingsPage extends ConsumerWidget {
  const PlatformTrialSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(billingSettingsProvider);
    return ListView(
      children: [
        PlatformPageHeader(
          title: l10n.platformTrialSettingsTitle,
          subtitle: l10n.platformTrialSettingsSubtitle,
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: settings.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (s) {
              if (s == null) return Text(l10n.platformNoSettings);
              return Card(
                child: Padding(
                  padding: AppSpacing.cardLg,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(l10n.platformDefaultTrialDays),
                        subtitle: Text(
                          l10n.platformDaysCount(s['default_trial_days'] as int? ?? 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTrialDays(context, ref, s),
                        ),
                      ),
                      ListTile(
                        title: Text(l10n.platformGracePeriod),
                        subtitle: Text(
                          l10n.platformDaysCount(s['grace_period_days'] as int? ?? 3),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editGrace(context, ref, s),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _editTrialDays(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> s,
  ) async {
    final ctrl = TextEditingController(
      text: '${s['default_trial_days'] ?? 14}',
    );
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.platformTrialDaysTitle),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.platformDaysLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(billingRepositoryProvider).updateBillingSettings({
        'default_trial_days': int.tryParse(ctrl.text) ?? 14,
      });
      ref.invalidate(billingSettingsProvider);
    }
  }

  Future<void> _editGrace(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> s,
  ) async {
    final ctrl = TextEditingController(
      text: '${s['grace_period_days'] ?? 3}',
    );
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.platformGracePeriodDaysTitle),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.platformDaysLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(billingRepositoryProvider).updateBillingSettings({
        'grace_period_days': int.tryParse(ctrl.text) ?? 3,
      });
      ref.invalidate(billingSettingsProvider);
    }
  }
}

class PlatformBillingAnalyticsPage extends ConsumerWidget {
  const PlatformBillingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final analytics = ref.watch(platformBillingAnalyticsProvider);
    return ListView(
      children: [
        PlatformPageHeader(
          title: l10n.platformRevenueAnalyticsTitle,
          subtitle: l10n.platformRevenueAnalyticsSubtitle,
        ),
        analytics.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
          data: (a) {
            if (a == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(l10n.platformTotalRevenue, formatMoney(a.totalRevenueCents)),
                  _StatCard(
                    l10n.platformSubscriptionRevenue,
                    formatMoney(a.subscriptionRevenueCents),
                  ),
                  _StatCard(l10n.platformMrrContracted, formatMoney(a.mrrCents)),
                  _StatCard(l10n.platformActiveSubs, '${a.activeSubscriptions}'),
                  _StatCard(l10n.platformTrialing, '${a.trialingSubscriptions}'),
                  _StatCard(l10n.platformTrialsExpiring7d, '${a.expiringTrials7d}'),
                  _StatCard(l10n.platformFailedPayments30d, '${a.failedPayments30d}'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: AppSpacing.cardLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              AppSpacing.gapXxs(),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
