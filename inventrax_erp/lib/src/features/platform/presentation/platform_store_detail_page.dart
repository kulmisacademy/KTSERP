import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_metric_card.dart';
import '../../../ui/components/app_status_badge.dart';
import '../application/platform_impersonation_service.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';

class PlatformStoreDetailPage extends ConsumerWidget {
  const PlatformStoreDetailPage({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(platformStoreDetailProvider(storeId));
    final plans = ref.watch(subscriptionPlansProvider);

    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.platformErrorDetail(e.toString()))),
      data: (d) {
        if (d == null) return Center(child: Text(l10n.platformStoreNotFound));
        return _StoreDetailBody(
          storeId: storeId,
          detail: d,
          plans: plans.maybeWhen(data: (p) => p, orElse: () => <SubscriptionPlan>[]),
          onRefresh: () => ref.invalidate(platformStoreDetailProvider(storeId)),
          onSubscription: (tenantId, planId, status, trialDays) async {
            await ref.read(platformRepositoryProvider).updateSubscription(
                  tenantId: tenantId,
                  planId: planId,
                  status: status,
                  trialDays: trialDays,
                );
            ref.invalidate(platformStoreDetailProvider(storeId));
          },
          onSuspend: () async {
            await ref.read(platformRepositoryProvider).setStoreStatus(storeId, 'suspended');
            ref.invalidate(platformStoreDetailProvider(storeId));
          },
          onActivate: () async {
            await ref.read(platformRepositoryProvider).setStoreStatus(storeId, 'active');
            ref.invalidate(platformStoreDetailProvider(storeId));
          },
        );
      },
    );
  }
}

class _StoreDetailBody extends ConsumerWidget {
  const _StoreDetailBody({
    required this.storeId,
    required this.detail,
    required this.plans,
    required this.onRefresh,
    required this.onSubscription,
    required this.onSuspend,
    required this.onActivate,
  });

  final String storeId;
  final PlatformStoreDetail detail;
  final List<SubscriptionPlan> plans;
  final VoidCallback onRefresh;
  final Future<void> Function(String tenantId, String planId, String status, int? trialDays)
      onSubscription;
  final Future<void> Function() onSuspend;
  final Future<void> Function() onActivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = detail.store;
    final u = detail.usage ?? {};
    final st = detail.storage ?? {};
    final owner = detail.owner ?? {};
    final name = s['name'] as String? ?? 'Store';
    final tenantId = s['tenant_id'] as String? ?? '';
    final currency = s['currency_code'] as String? ?? 'USD';
    final planId = s['plan_id'] as String? ?? 'free_trial';
    final subStatus = s['subscription_status'] as String? ?? 'trialing';
    final storageUsed = _int(st['total_bytes']);
    final storageLimit = s['storage_limit_bytes'] == null ? null : _int(s['storage_limit_bytes']);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: s['logo_url'] != null ? NetworkImage(s['logo_url'] as String) : null,
                child: s['logo_url'] == null ? Text(name.isNotEmpty ? name[0] : '?') : null,
              ),
              AppSpacing.gapMd(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.headlineSmall),
                    Text(owner['email'] as String? ?? '—'),
                    AppSpacing.gapXs(),
                    AppStatusBadge(label: subStatus, type: AppStatusType.info),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd(),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(platformImpersonationProvider.notifier).impersonateStore(
                    storeId: storeId,
                    tenantId: tenantId,
                    storeName: name,
                  );
              if (context.mounted) context.go('/dashboard');
            },
            icon: const Icon(Icons.login),
            label: Text(l10n.platformOpenStoreImpersonate),
          ),
          AppSpacing.gapLg(),
          Text(l10n.platformBusinessAnalytics, style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.gapMd(),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.sizeOf(context).width >= 800 ? 4 : 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.2,
            children: [
              AppMetricCard(
                title: l10n.platformProductsMetric,
                value: '${_int(u['product_count'])}',
                icon: Icons.inventory_2,
              ),
              AppMetricCard(
                title: l10n.platformSalesMetric,
                value: '${_int(u['sale_count'])}',
                icon: Icons.receipt,
              ),
              AppMetricCard(
                title: l10n.platformPurchasesMetric,
                value: '${_int(u['purchase_count'])}',
                icon: Icons.shopping_cart,
              ),
              AppMetricCard(
                title: l10n.platformRevenueMetric,
                value: formatMoney(_int(u['revenue_cents']), currency: currency),
                icon: Icons.payments,
              ),
              AppMetricCard(
                title: l10n.platformExpensesMetric,
                value: formatMoney(_int(u['expense_cents']), currency: currency),
                icon: Icons.money_off,
              ),
              AppMetricCard(
                title: l10n.platformCustomersMetric,
                value: '${_int(u['customer_count'])}',
                icon: Icons.people,
              ),
              AppMetricCard(
                title: l10n.platformSuppliersMetric,
                value: '${_int(u['supplier_count'])}',
                icon: Icons.local_shipping,
              ),
              AppMetricCard(
                title: l10n.platformUsersMetric,
                value: '${_int(u['user_count'])}',
                icon: Icons.badge,
              ),
              AppMetricCard(
                title: l10n.platformDebtsMetric,
                value: '${_int(u['debt_count'])}',
                icon: Icons.account_balance_wallet,
              ),
              AppMetricCard(
                title: l10n.platformInventoryValue,
                value: formatMoney(_int(u['inventory_value_cents']), currency: currency),
                icon: Icons.warehouse,
              ),
            ],
          ),
          AppSpacing.gapLg(),
          Text(l10n.platformStorageSection, style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.gapSm(),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: Text(
                storageLimit != null
                    ? '${formatBytes(storageUsed)} / ${formatBytes(storageLimit)}'
                    : formatBytes(storageUsed),
              ),
              subtitle: Text(l10n.platformImagesCount(_int(st['image_count']))),
            ),
          ),
          AppSpacing.gapLg(),
          Text(l10n.platformSubscriptionControl, style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.gapSm(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in plans)
                OutlinedButton(
                  onPressed: () => onSubscription(tenantId, p.id, 'active', null),
                  child: Text(l10n.platformSetPlan(p.name)),
                ),
              FilledButton.tonal(
                onPressed: () => onSubscription(tenantId, planId, 'trialing', 14),
                child: Text(l10n.platformExtendTrial14d),
              ),
              OutlinedButton(
                onPressed: onSuspend,
                child: Text(l10n.platformSuspend),
              ),
              FilledButton(
                onPressed: onActivate,
                child: Text(l10n.platformActivate),
              ),
            ],
          ),
          AppSpacing.gapLg(),
          Text(l10n.platformStoreInfo, style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                _InfoRow(l10n.platformOwnerLabel, owner['full_name'] as String?),
                _InfoRow(l10n.platformPhoneLabel, owner['phone'] as String?),
                _InfoRow(l10n.platformAddressLabel, s['address'] as String?),
                _InfoRow(l10n.platformCountryLabel, s['country'] as String?),
                _InfoRow(l10n.platformPlanLabel, s['plan_name'] as String?),
                _InfoRow(
                  l10n.platformCreatedLabel,
                  s['created_at'] != null
                      ? DateFormat.yMMMd().format(DateTime.parse(s['created_at'].toString()))
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(value ?? '—'),
    );
  }
}
