import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';

class PlatformSearchPage extends ConsumerStatefulWidget {
  const PlatformSearchPage({super.key});

  @override
  ConsumerState<PlatformSearchPage> createState() => _PlatformSearchPageState();
}

class _PlatformSearchPageState extends ConsumerState<PlatformSearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _controller.text.trim();
    final results = q.length >= 2 ? ref.watch(platformSearchProvider(q)) : null;

    return ListView(
      padding: AppSpacing.page,
      children: [
        Text(
          l10n.platformGlobalSearchTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        AppSpacing.gapMd(),
        TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.platformSearchHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        AppSpacing.gapLg(),
        if (q.length < 2)
          Text(
            l10n.platformSearchMinChars,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          results?.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(l10n.platformErrorDetail(e.toString())),
            data: (data) {
              if (data == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.platformSearchStoresSection(data.stores.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppSpacing.gapSm(),
                  if (data.stores.isEmpty)
                    Text(l10n.platformSearchNoStores)
                  else
                    ...data.stores.map((s) => _StoreHit(store: s)),
                  AppSpacing.gapLg(),
                  Text(
                    l10n.platformSearchPlansSection(data.plans.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppSpacing.gapSm(),
                  if (data.plans.isEmpty)
                    Text(l10n.platformSearchNoPlans)
                  else
                    ...data.plans.map((p) => _PlanHit(plan: p)),
                ],
              );
            },
          ) ??
              const SizedBox.shrink(),
      ],
    );
  }
}

class _StoreHit extends StatelessWidget {
  const _StoreHit({required this.store});

  final PlatformStoreRow store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(store.storeName),
        subtitle: Text('${store.ownerEmail ?? '—'} • ${store.planName ?? '—'}'),
        trailing: Text(formatMoney(store.revenueCents, currency: store.currencyCode ?? 'USD')),
        onTap: () => context.go('/platform/stores/${store.storeId}'),
      ),
    );
  }
}

class _PlanHit extends StatelessWidget {
  const _PlanHit({required this.plan});

  final Map<String, dynamic> plan;

  @override
  Widget build(BuildContext context) {
    final cents = plan['monthly_price_cents'] as int? ?? 0;
    return Card(
      child: ListTile(
        title: Text(plan['name'] as String? ?? ''),
        subtitle: Text(plan['id'] as String? ?? ''),
        trailing: Text(formatMoney(cents, currency: 'USD')),
        onTap: () => context.go('/platform/plans'),
      ),
    );
  }
}
