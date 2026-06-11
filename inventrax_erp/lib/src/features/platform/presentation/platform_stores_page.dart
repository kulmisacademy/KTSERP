import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_status_badge.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformStoresPage extends ConsumerStatefulWidget {
  const PlatformStoresPage({super.key});

  @override
  ConsumerState<PlatformStoresPage> createState() => _PlatformStoresPageState();
}

class _PlatformStoresPageState extends ConsumerState<PlatformStoresPage> {
  final _search = TextEditingController();
  String? _query;
  String _statusFilter = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _runSearch() => setState(() {
        _query = _search.text.trim().isEmpty ? null : _search.text.trim();
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stores = ref.watch(platformStoresProvider(_query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlatformPageHeader(
          title: 'All stores',
          subtitle: 'Search, filter, and manage every tenant on the platform',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.platformStoresSearchHint,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                  ),
                  onSubmitted: (_) => _runSearch(),
                ),
              ),
              AppSpacing.gapSm(),
              FilledButton.icon(
                onPressed: _runSearch,
                icon: const Icon(Icons.search, size: 18),
                label: Text(l10n.platformSearchButton),
              ),
            ],
          ),
        ),
        AppSpacing.gapSm(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in [
                  ('all', l10n.platformFilterAll),
                  ('active', l10n.platformFilterActive),
                  ('trialing', l10n.platformFilterTrial),
                  ('expired', l10n.platformFilterExpired),
                  ('suspended', l10n.platformFilterSuspended),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(f.$2),
                      selected: _statusFilter == f.$1,
                      onSelected: (_) => setState(() => _statusFilter = f.$1),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AppSpacing.gapMd(),
        Expanded(
          child: stores.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
            data: (list) {
              final filtered = _statusFilter == 'all'
                  ? list
                  : list
                      .where((s) => (s.subscriptionStatus ?? s.storeStatus).toLowerCase() == _statusFilter)
                      .toList();
              if (filtered.isEmpty) {
                return const PlatformEmptyState(icon: Icons.storefront, message: 'No stores found');
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(platformStoresProvider(_query));
                  await ref.read(platformStoresProvider(_query).future);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _StoreCard(
                    store: filtered[i],
                    onTap: () => context.go('/platform/stores/${filtered[i].storeId}'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.onTap});

  final PlatformStoreRow store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final created = store.createdAt != null ? DateFormat.yMMMd().format(store.createdAt!) : '—';
    final status = store.subscriptionStatus ?? store.storeStatus;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: store.logoUrl != null ? NetworkImage(store.logoUrl!) : null,
                child: store.logoUrl == null
                    ? Text(
                        store.storeName.isNotEmpty ? store.storeName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                      )
                    : null,
              ),
              AppSpacing.gapMd(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.storeName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        AppStatusBadge(label: status, type: _statusType(status)),
                      ],
                    ),
                    AppSpacing.gapXxs(),
                    Text(store.ownerEmail ?? '—', style: Theme.of(context).textTheme.bodySmall),
                    AppSpacing.gapSm(),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: 4,
                      children: [
                        _MiniChip(Icons.layers, store.planName ?? 'No plan'),
                        _MiniChip(Icons.public, store.country ?? '—'),
                        _MiniChip(Icons.calendar_today, created),
                        _MiniChip(Icons.inventory_2, '${store.productCount} products'),
                        _MiniChip(Icons.payments, formatMoney(store.revenueCents, currency: store.currencyCode ?? 'USD')),
                        _MiniChip(Icons.cloud, _storageLabel(store.storageBytes, store.storageLimitBytes)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiaryLight),
            ],
          ),
        ),
      ),
    );
  }

  AppStatusType _statusType(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppStatusType.success;
      case 'trialing':
      case 'trial':
        return AppStatusType.warning;
      case 'suspended':
      case 'expired':
      case 'past_due':
        return AppStatusType.error;
      default:
        return AppStatusType.neutral;
    }
  }

  String _storageLabel(int used, int? limit) {
    if (limit == null || limit == 0) return formatBytes(used);
    return '${formatBytes(used)} / ${formatBytes(limit)}';
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedLight,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiaryLight),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
