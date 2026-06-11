import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/components/app_input.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../ui/components/app_skeleton.dart';
import '../../../core/design/design_system.dart';
import '../../../ui/layout/app_shell.dart';
import '../../../ui/widgets/brand_hero_banner.dart';
import '../../debts/data/debt_share_actions.dart';
import '../../debts/presentation/widgets/debt_ui.dart';

const _uuid = Uuid();

final customersProvider = StreamProvider.autoDispose<List<Customer>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchCustomers(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
  );
});

final customerReceivablesMapProvider =
    StreamProvider.autoDispose<Map<String, int>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchOpenCustomerDebts(storeId: StoreContext.storeId).map((debts) {
    final map = <String, int>{};
    for (final d in debts) {
      final id = d.customerId;
      if (id == null) continue;
      map[id] = (map[id] ?? 0) + d.remainingCents;
    }
    return map;
  });
});

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final receivables = ref.watch(customerReceivablesMapProvider);
    final currency =
        ref.watch(storeSettingsProvider).value?.currencyCode ?? 'USD';
    final theme = Theme.of(context);

    final totalReceivable = receivables.asData?.value.values
            .fold<int>(0, (a, b) => a + b) ??
        0;
    final l10n = context.l10n;

    return AppShell(
      route: '/customers',
      actions: [
        FilledButton.icon(
          onPressed: () => _showAddDialog(context, ref),
          icon: const Icon(Icons.person_add, size: 18),
          label: Text(l10n.addCustomer),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: BrandHeroBanner(
              padding: const EdgeInsets.all(20),
              child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.customerDirectory,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        l10n.customerReceivablesSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.totalReceivable,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      formatMoney(totalReceivable, currency: currency),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: context.brand.teal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchCustomersHint,
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
            child: customers.when(
              data: (rows) {
                final balanceMap = receivables.asData?.value ?? {};
                var filtered = rows;
                if (_query.isNotEmpty) {
                  filtered = rows.where((c) {
                    return c.name.toLowerCase().contains(_query) ||
                        (c.phone?.contains(_query) ?? false) ||
                        (c.email?.toLowerCase().contains(_query) ?? false);
                  }).toList();
                }
                if (filtered.isEmpty) {
                  return AppEmptyState(
                    title: rows.isEmpty ? l10n.noCustomers : l10n.commonNoMatches,
                    subtitle: rows.isEmpty
                        ? l10n.noCustomersSubtitle
                        : l10n.commonTryDifferentSearch,
                    icon: Icons.people_outline,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final balance = balanceMap[c.id] ?? 0;
                    return _CustomerCard(
                      customer: c,
                      balanceCents: balance,
                      currency: currency,
                      onView: () => context.push('/debts/customer/${c.id}'),
                      onShare: () => shareCustomerDebt(
                        ref: ref,
                        customerId: c.id,
                        customerName: c.name,
                        balanceCents: balance,
                      ),
                      onSms: () => sendCustomerDebtSms(
                        context: context,
                        ref: ref,
                        customerId: c.id,
                        customerName: c.name,
                        phone: c.phone,
                        balanceCents: balance,
                      ),
                    );
                  },
                );
              },
              loading: () => const ListPageSkeleton(),
              error: (e, _) => Center(child: Text(userFriendlyError(e))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add customer'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                controller: name,
                label: 'Full name *',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 12),
              AppInput(
                controller: phone,
                label: 'Phone',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ],
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
    final customerName = name.text.trim();
    final phoneVal = phone.text.trim();
    name.dispose();
    phone.dispose();
    if (ok != true || customerName.isEmpty) return;

    await ref.read(appDatabaseProvider).addCustomer(
          CustomersCompanion.insert(
            id: _uuid.v4(),
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
            name: customerName,
            phone: Value(phoneVal.isEmpty ? null : phoneVal),
          ),
        );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.balanceCents,
    required this.currency,
    required this.onView,
    required this.onShare,
    required this.onSms,
  });

  final Customer customer;
  final int balanceCents;
  final String currency;
  final VoidCallback onView;
  final VoidCallback onShare;
  final VoidCallback onSms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDebt = balanceCents > 0;

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
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (customer.phone != null) Text(customer.phone!),
                        if (customer.email != null) Text(customer.email!),
                        if (customer.blacklisted)
                          const Chip(
                            label: Text('Blocked'),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        hasDebt
                            ? formatMoney(balanceCents, currency: currency)
                            : 'Clear',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: hasDebt
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
                        hasDebt ? 'Receivable' : 'No debt',
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
