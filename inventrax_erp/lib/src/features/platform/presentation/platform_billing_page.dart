import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../ui/components/app_status_badge.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformBillingPage extends ConsumerStatefulWidget {
  const PlatformBillingPage({super.key});

  @override
  ConsumerState<PlatformBillingPage> createState() => _PlatformBillingPageState();
}

class _PlatformBillingPageState extends ConsumerState<PlatformBillingPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stores = ref.watch(platformStoresProvider(null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlatformPageHeader(
          title: l10n.platformBillingTitle,
          subtitle: l10n.platformBillingSubtitle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            children: [
              _FilterChip(label: l10n.platformFilterAll, value: 'all', group: _filter, onSelect: _setFilter),
              _FilterChip(label: l10n.platformFilterActive, value: 'active', group: _filter, onSelect: _setFilter),
              _FilterChip(label: l10n.platformFilterTrial, value: 'trialing', group: _filter, onSelect: _setFilter),
              _FilterChip(label: l10n.platformFilterExpired, value: 'expired', group: _filter, onSelect: _setFilter),
              _FilterChip(label: l10n.platformFilterSuspended, value: 'suspended', group: _filter, onSelect: _setFilter),
            ],
          ),
        ),
        AppSpacing.gapMd(),
        Expanded(
          child: stores.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
            data: (list) {
              final filtered = _filter == 'all'
                  ? list
                  : list.where((s) => (s.subscriptionStatus ?? '').toLowerCase() == _filter).toList();
              if (filtered.isEmpty) {
                return PlatformEmptyState(
                  icon: Icons.inbox,
                  message: l10n.platformNoStoresMatchFilter,
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(platformStoresProvider(null));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _BillingRow(store: filtered[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _setFilter(String v) => setState(() => _filter = v);
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.group,
    required this.onSelect,
  });

  final String label;
  final String value;
  final String group;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = group == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelect(value),
    );
  }
}

class _BillingRow extends ConsumerWidget {
  const _BillingRow({required this.store});

  final PlatformStoreRow store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = store.subscriptionStatus ?? 'unknown';
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(child: Text(store.storeName.isNotEmpty ? store.storeName[0] : '?')),
        title: Text(store.storeName),
        subtitle: Text('${store.planName ?? '—'} • ${store.ownerEmail ?? '—'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppStatusBadge(label: status, type: _statusType(status)),
            PopupMenuButton<String>(
              onSelected: (action) => _action(context, ref, action),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'view', child: Text(l10n.platformViewStore)),
                PopupMenuItem(value: 'active', child: Text(l10n.platformSetActive)),
                PopupMenuItem(value: 'trial', child: Text(l10n.platformExtendTrial14d)),
                PopupMenuItem(value: 'suspend', child: Text(l10n.platformSuspend)),
              ],
            ),
          ],
        ),
        onTap: () => context.go('/platform/stores/${store.storeId}'),
      ),
    );
  }

  AppStatusType _statusType(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppStatusType.success;
      case 'trialing':
        return AppStatusType.warning;
      case 'suspended':
      case 'expired':
      case 'past_due':
        return AppStatusType.error;
      default:
        return AppStatusType.neutral;
    }
  }

  Future<void> _action(BuildContext context, WidgetRef ref, String action) async {
    final l10n = context.l10n;
    final repo = ref.read(platformRepositoryProvider);
    switch (action) {
      case 'view':
        context.go('/platform/stores/${store.storeId}');
      case 'active':
        await repo.updateSubscription(
          tenantId: store.tenantId,
          planId: store.planId ?? 'starter',
          status: 'active',
        );
      case 'trial':
        await repo.updateSubscription(
          tenantId: store.tenantId,
          planId: store.planId ?? 'free_trial',
          status: 'trialing',
          trialDays: 14,
        );
      case 'suspend':
        await repo.setStoreStatus(store.storeId, 'suspended');
    }
    ref.invalidate(platformStoresProvider(null));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.platformStoreUpdated(store.storeName))),
      );
    }
  }
}
