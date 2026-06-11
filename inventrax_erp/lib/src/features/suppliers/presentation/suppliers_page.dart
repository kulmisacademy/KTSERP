import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/components/app_input.dart';
import '../../../ui/layout/app_shell.dart';
import '../../debts/data/debt_share_actions.dart';
import '../../debts/presentation/widgets/debt_ui.dart';

final suppliersProvider = StreamProvider.autoDispose<List<Supplier>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchSuppliers(storeId: StoreContext.storeId);
});

final supplierPayablesMapProvider =
    StreamProvider.autoDispose<Map<String, int>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchOpenSupplierDebts(storeId: StoreContext.storeId).map((debts) {
    final map = <String, int>{};
    for (final d in debts) {
      final id = d.supplierId;
      if (id == null) continue;
      map[id] = (map[id] ?? 0) + d.remainingCents;
    }
    return map;
  });
});

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(suppliersProvider);
    final payables = ref.watch(supplierPayablesMapProvider);
    final currency =
        ref.watch(storeSettingsProvider).value?.currencyCode ?? 'USD';
    final theme = Theme.of(context);

    final totalPayable =
        payables.asData?.value.values.fold<int>(0, (a, b) => a + b) ?? 0;

    final l10n = context.l10n;
    return AppShell(
      route: '/suppliers',
      actions: [
        FilledButton.icon(
          onPressed: () => _showAddDialog(context, ref),
          icon: const Icon(Icons.add_business, size: 18),
          label: Text(l10n.addSupplier),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.tertiary,
                  theme.colorScheme.tertiary.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.supplierDirectory,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onTertiary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        l10n.supplierPayablesSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onTertiary
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.totalPayable,
                      style: TextStyle(
                        color: theme.colorScheme.onTertiary
                            .withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      formatMoney(totalPayable, currency: currency),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onTertiary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search name or phone…',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: suppliers.when(
              data: (rows) {
                final payableMap = payables.asData?.value ?? {};
                var filtered = rows;
                if (_query.isNotEmpty) {
                  filtered = rows.where((s) {
                    return s.name.toLowerCase().contains(_query) ||
                        (s.phone?.contains(_query) ?? false);
                  }).toList();
                }
                if (filtered.isEmpty) {
                  return AppEmptyState(
                    title: rows.isEmpty ? l10n.noSuppliers : l10n.commonNoMatches,
                    subtitle: rows.isEmpty
                        ? l10n.noSuppliersSubtitle
                        : l10n.commonTryDifferentSearch,
                    icon: Icons.local_shipping_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    final balance = payableMap[s.id] ?? 0;
                    return _SupplierCard(
                      supplier: s,
                      balanceCents: balance,
                      currency: currency,
                      onView: () => context.push('/debts/supplier/${s.id}'),
                      onShare: () => shareSupplierPayable(
                        ref: ref,
                        supplierName: s.name,
                        balanceCents: balance,
                      ),
                      onSms: () => sendSupplierPayableSms(
                        context: context,
                        ref: ref,
                        supplierName: s.name,
                        phone: s.phone,
                        balanceCents: balance,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add supplier'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInput(
                  controller: name,
                  label: 'Supplier name *',
                  prefixIcon: Icons.local_shipping_outlined,
                ),
                const SizedBox(height: 12),
                AppInput(
                  controller: phone,
                  label: 'Phone',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppInput(
                  controller: address,
                  label: 'Address (optional)',
                  prefixIcon: Icons.place_outlined,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final supplierName = name.text.trim();
    final phoneVal = phone.text.trim();
    final addressVal = address.text.trim();
    name.dispose();
    phone.dispose();
    address.dispose();

    if (ok != true || supplierName.isEmpty) return;

    final db = ref.read(appDatabaseProvider);
    final existing = await db.findSupplierByNameOrPhone(
      storeId: StoreContext.storeId,
      name: supplierName,
      phone: phoneVal.isEmpty ? null : phoneVal,
    );
    if (existing != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Using existing supplier: ${existing.name}')),
      );
      return;
    }

    await db.getOrCreateSupplier(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      name: supplierName,
      phone: phoneVal.isEmpty ? null : phoneVal,
      address: addressVal.isEmpty ? null : addressVal,
    );
  }
}

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({
    required this.supplier,
    required this.balanceCents,
    required this.currency,
    required this.onView,
    required this.onShare,
    required this.onSms,
  });

  final Supplier supplier;
  final int balanceCents;
  final String currency;
  final VoidCallback onView;
  final VoidCallback onShare;
  final VoidCallback onSms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPayable = balanceCents > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    child: Icon(
                      Icons.local_shipping,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (supplier.phone != null)
                          Text(supplier.phone!),
                        if (supplier.address != null)
                          Text(
                            supplier.address!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        hasPayable
                            ? formatMoney(balanceCents, currency: currency)
                            : 'Paid up',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: hasPayable
                              ? debtStatusColor(
                                  'active',
                                  Theme.of(context).brightness,
                                )
                              : debtStatusColor(
                                  'paid',
                                  Theme.of(context).brightness,
                                ),
                        ),
                      ),
                      Text(
                        hasPayable ? 'Payable' : 'No balance',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View debts'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSms,
                    icon: const Icon(Icons.sms_outlined, size: 18),
                    label: const Text('SMS'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
