import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformPlansPage extends ConsumerStatefulWidget {
  const PlatformPlansPage({super.key});

  @override
  ConsumerState<PlatformPlansPage> createState() => _PlatformPlansPageState();
}

class _PlatformPlansPageState extends ConsumerState<PlatformPlansPage> {
  Future<void> _openEditor(SubscriptionPlan? existing) async {
    final l10n = context.l10n;
    final idCtrl = TextEditingController(text: existing?.id ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final monthlyCtrl = TextEditingController(
      text: existing != null ? (existing.monthlyPriceCents / 100).toString() : '',
    );
    final productsCtrl = TextEditingController(
      text: existing?.productLimit?.toString() ?? '',
    );
    final usersCtrl = TextEditingController(
      text: existing?.userLimit?.toString() ?? '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l10n.platformCreatePlan : l10n.platformEditPlan),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idCtrl,
                decoration: InputDecoration(labelText: l10n.platformPlanIdSlug),
                enabled: existing == null,
              ),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l10n.platformPlanNameLabel),
              ),
              TextField(
                controller: monthlyCtrl,
                decoration: InputDecoration(labelText: l10n.platformPlanMonthlyPrice),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: productsCtrl,
                decoration: InputDecoration(labelText: l10n.platformPlanProductLimit),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: usersCtrl,
                decoration: InputDecoration(labelText: l10n.platformPlanUserLimit),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
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

    if (ok != true || idCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
      idCtrl.dispose();
      nameCtrl.dispose();
      monthlyCtrl.dispose();
      productsCtrl.dispose();
      usersCtrl.dispose();
      return;
    }

    final monthly = (double.tryParse(monthlyCtrl.text) ?? 0) * 100;
    final plan = SubscriptionPlan(
      id: idCtrl.text.trim(),
      name: nameCtrl.text.trim(),
      monthlyPriceCents: monthly.round(),
      yearlyPriceCents: (monthly * 10).round(),
      productLimit: int.tryParse(productsCtrl.text.trim()),
      userLimit: int.tryParse(usersCtrl.text.trim()),
      storageLimitBytes: existing?.storageLimitBytes,
      branchLimit: existing?.branchLimit,
      features: existing?.features ?? const ['pos', 'products'],
      isActive: true,
      sortOrder: existing?.sortOrder ?? 50,
    );

    await ref.read(platformRepositoryProvider).upsertPlan(plan);
    ref.invalidate(subscriptionPlansProvider);

    idCtrl.dispose();
    nameCtrl.dispose();
    monthlyCtrl.dispose();
    productsCtrl.dispose();
    usersCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plans = ref.watch(subscriptionPlansProvider);

    return plans.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.platformErrorDetail(e.toString()))),
      data: (list) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(subscriptionPlansProvider);
          await ref.read(subscriptionPlansProvider.future);
        },
        child: ListView(
          children: [
            PlatformPageHeader(
              title: l10n.platformPlansTitle,
              subtitle: l10n.platformPlansSubtitle,
              actions: [
                FilledButton.icon(
                  onPressed: () => _openEditor(null),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.platformNewPlan),
                ),
              ],
            ),
            for (final p in list)
              Card(
                elevation: 0,
                margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lgAll,
                  side: BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: AppSpacing.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Text(p.id, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      if (p.description != null) Text(p.description!),
                      AppSpacing.gapSm(),
                      Text(
                        '${formatMoney(p.monthlyPriceCents, currency: 'USD')}/mo • '
                        '${formatMoney(p.yearlyPriceCents, currency: 'USD')}/yr',
                      ),
                      AppSpacing.gapXs(),
                      Text(
                        'Products: ${p.productLimit ?? '∞'} • '
                        'Users: ${p.userLimit ?? '∞'} • '
                        'Storage: ${p.storageLimitBytes != null ? formatBytes(p.storageLimitBytes!) : '∞'}',
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _openEditor(p),
                          child: Text(l10n.platformEdit),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
