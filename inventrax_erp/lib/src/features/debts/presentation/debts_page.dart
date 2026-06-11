import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/l10n/erp_l10n.dart';
import '../../../core/store/active_store_scope.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/layout/app_shell.dart';
import '../data/debt_share_actions.dart';
import 'widgets/debt_payment_dialog.dart';
import 'widgets/debt_ui.dart';

final supplierDebtsProvider = StreamProvider.autoDispose<List<Debt>>((ref) {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchOpenSupplierDebts(storeId: scope.storeId);
});

final customerDebtsProvider = StreamProvider.autoDispose<List<Debt>>((ref) {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchOpenCustomerDebts(storeId: scope.storeId);
});

final customersForDebtsProvider =
    StreamProvider.autoDispose<List<Customer>>((ref) {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchCustomers(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
  );
});

final suppliersForDebtsProvider =
    StreamProvider.autoDispose<List<Supplier>>((ref) {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchSuppliers(storeId: scope.storeId);
});

final debtDashboardProvider = FutureProvider.autoDispose<({
  int receivables,
  int payables,
  int overdue,
})>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.read(appDatabaseProvider);
  final storeId = scope.storeId;
  return (
    receivables: await db.sumOpenCustomerReceivables(storeId: storeId),
    payables: await db.sumOpenSupplierPayables(storeId: storeId),
    overdue: await db.countOverdueDebts(storeId: storeId),
  );
});

class _DebtPartyGroup {
  _DebtPartyGroup({
    required this.id,
    required this.name,
    required this.phone,
    required this.debts,
  });

  final String id;
  final String name;
  final String? phone;
  final List<Debt> debts;

  int get totalRemaining => debts
      .where((d) => d.remainingCents > 0)
      .fold(0, (s, d) => s + d.remainingCents);
}

List<_DebtPartyGroup> _groupCustomerDebts(
  List<Debt> debts,
  List<Customer> customers,
) {
  final byId = <String, List<Debt>>{};
  for (final d in debts) {
    final id = d.customerId;
    if (id == null || id.isEmpty) continue;
    byId.putIfAbsent(id, () => []).add(d);
  }
  final nameMap = {for (final c in customers) c.id: c};
  return byId.entries.map((e) {
    final c = nameMap[e.key];
    return _DebtPartyGroup(
      id: e.key,
      name: c?.name ?? 'Customer ${e.key.substring(0, 6)}',
      phone: c?.phone,
      debts: e.value,
    );
  }).toList()
    ..sort((a, b) => b.totalRemaining.compareTo(a.totalRemaining));
}

List<_DebtPartyGroup> _groupSupplierDebts(
  List<Debt> debts,
  List<Supplier> suppliers,
) {
  final byId = <String, List<Debt>>{};
  for (final d in debts) {
    final id = d.supplierId;
    if (id == null || id.isEmpty) continue;
    byId.putIfAbsent(id, () => []).add(d);
  }
  final nameMap = {for (final s in suppliers) s.id: s};
  return byId.entries.map((e) {
    final s = nameMap[e.key];
    return _DebtPartyGroup(
      id: e.key,
      name: s?.name ?? 'Supplier ${e.key.substring(0, 6)}',
      phone: s?.phone,
      debts: e.value,
    );
  }).toList()
    ..sort((a, b) => b.totalRemaining.compareTo(a.totalRemaining));
}

class DebtsPage extends ConsumerStatefulWidget {
  const DebtsPage({super.key});

  @override
  ConsumerState<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends ConsumerState<DebtsPage> {
  String _query = '';
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final dashboard = ref.watch(debtDashboardProvider);

    final l10n = context.l10n;
    return AppShell(
      route: '/debts',
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            dashboard.when(
              data: (kpi) => DebtHeroBanner(
                receivables: kpi.receivables,
                payables: kpi.payables,
                overdue: kpi.overdue,
                currency: currency,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l10n.debtsSearchHint,
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: l10n.debtsFilterStatusTooltip,
                    onPressed: () => _pickStatus(context),
                    icon: Badge(
                      isLabelVisible: _statusFilter != null,
                      child: const Icon(Icons.tune),
                    ),
                  ),
                ],
              ),
            ),
            if (_statusFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(l10n.debtStatusLabel(_statusFilter!)),
                    onDeleted: () => setState(() => _statusFilter = null),
                  ),
                ),
              ),
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                tabs: [
                  Tab(
                    icon: const Icon(Icons.people_outline, size: 20),
                    text: l10n.debtsCustomerTab,
                  ),
                  Tab(
                    icon: const Icon(Icons.local_shipping_outlined, size: 20),
                    text: l10n.debtsSupplierTab,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CustomerDebtTab(
                    currency: currency,
                    query: _query,
                    statusFilter: _statusFilter,
                  ),
                  _SupplierDebtTab(
                    currency: currency,
                    query: _query,
                    statusFilter: _statusFilter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStatus(BuildContext context) async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.commonAllStatuses),
              onTap: () => Navigator.pop(ctx, null),
            ),
            for (final s in ['active', 'partially_paid', 'paid', 'overdue'])
              ListTile(
                title: Text(l10n.debtStatusLabel(s)),
                onTap: () => Navigator.pop(ctx, s),
              ),
          ],
        ),
      ),
    );
    setState(() => _statusFilter = choice);
  }
}

class _CustomerDebtTab extends ConsumerWidget {
  const _CustomerDebtTab({
    required this.currency,
    required this.query,
    this.statusFilter,
  });

  final String currency;
  final String query;
  final String? statusFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final debts = ref.watch(customerDebtsProvider);
    final parties = ref.watch(customersForDebtsProvider);

    return debts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
      data: (debtRows) => parties.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
        data: (partyRows) {
          var groups = _groupCustomerDebts(debtRows, partyRows);

          if (statusFilter != null) {
            groups = groups
                .map((g) {
                  final filtered = g.debts
                      .where((d) => d.status == statusFilter)
                      .toList();
                  return _DebtPartyGroup(
                    id: g.id,
                    name: g.name,
                    phone: g.phone,
                    debts: filtered,
                  );
                })
                .where((g) => g.debts.isNotEmpty)
                .toList();
          }

          if (query.isNotEmpty) {
            groups = groups.where((g) {
              final q = query;
              if (g.name.toLowerCase().contains(q)) return true;
              if (g.phone != null && g.phone!.contains(q)) return true;
              return g.debts.any((d) {
                final inv = (d.invoiceNumber ?? d.id).toLowerCase();
                return inv.contains(q) ||
                    d.remainingCents.toString().contains(q);
              });
            }).toList();
          }

          if (groups.isEmpty) {
            return AppEmptyState(
              title: l10n.noCustomerDebts,
              subtitle: l10n.noCustomerDebtsSubtitle,
              icon: Icons.request_quote_outlined,
            );
          }

          return _PartyList(
            groups: groups,
            currency: currency,
            isCustomer: true,
            onPay: (ctx, r, d) => _payDebt(
              ctx,
              r,
              d,
              currency,
              customerDebtsProvider,
            ),
          );
        },
      ),
    );
  }
}

class _SupplierDebtTab extends ConsumerWidget {
  const _SupplierDebtTab({
    required this.currency,
    required this.query,
    this.statusFilter,
  });

  final String currency;
  final String query;
  final String? statusFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final debts = ref.watch(supplierDebtsProvider);
    final parties = ref.watch(suppliersForDebtsProvider);

    return debts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
      data: (debtRows) => parties.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
        data: (partyRows) {
          var groups = _groupSupplierDebts(debtRows, partyRows);

          if (statusFilter != null) {
            groups = groups
                .map((g) {
                  final filtered = g.debts
                      .where((d) => d.status == statusFilter)
                      .toList();
                  return _DebtPartyGroup(
                    id: g.id,
                    name: g.name,
                    phone: g.phone,
                    debts: filtered,
                  );
                })
                .where((g) => g.debts.isNotEmpty)
                .toList();
          }

          if (query.isNotEmpty) {
            groups = groups.where((g) {
              final q = query;
              if (g.name.toLowerCase().contains(q)) return true;
              if (g.phone != null && g.phone!.contains(q)) return true;
              return g.debts.any((d) {
                final inv = (d.invoiceNumber ?? d.id).toLowerCase();
                return inv.contains(q) ||
                    d.remainingCents.toString().contains(q);
              });
            }).toList();
          }

          if (groups.isEmpty) {
            return AppEmptyState(
              title: l10n.noSupplierPayables,
              subtitle: l10n.noSupplierPayablesSubtitle,
              icon: Icons.local_shipping_outlined,
            );
          }

          return _PartyList(
            groups: groups,
            currency: currency,
            isCustomer: false,
            onPay: (ctx, r, d) => _payDebt(
              ctx,
              r,
              d,
              currency,
              supplierDebtsProvider,
            ),
          );
        },
      ),
    );
  }
}

class _PartyList extends ConsumerWidget {
  const _PartyList({
    required this.groups,
    required this.currency,
    required this.isCustomer,
    required this.onPay,
  });

  final List<_DebtPartyGroup> groups;
  final String currency;
  final bool isCustomer;
  final void Function(BuildContext, WidgetRef, Debt) onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final g = groups[index];
        final openDebt =
            g.debts.where((d) => d.remainingCents > 0).firstOrNull;

        return DebtPartyCard(
          name: g.name,
          subtitle:
              isCustomer ? context.l10n.debtCustomerReceivable : context.l10n.debtSupplierPayable,
          totalRemaining: g.totalRemaining,
          invoiceCount: g.debts.length,
          currency: currency,
          isCustomer: isCustomer,
          phone: g.phone,
          onView: () => context.push(
            isCustomer
                ? '/debts/customer/${g.id}'
                : '/debts/supplier/${g.id}',
          ),
          onShare: () async {
            if (isCustomer) {
              await shareCustomerDebt(
                ref: ref,
                customerId: g.id,
                customerName: g.name,
                balanceCents: g.totalRemaining,
              );
            } else {
              await shareSupplierPayable(
                ref: ref,
                supplierName: g.name,
                balanceCents: g.totalRemaining,
              );
            }
          },
          onSms: () async {
            if (isCustomer) {
              await sendCustomerDebtSms(
                context: context,
                ref: ref,
                customerId: g.id,
                customerName: g.name,
                phone: g.phone,
                balanceCents: g.totalRemaining,
                debtId: openDebt?.id,
                dueDate: openDebt?.dueDate,
                invoiceNumber: openDebt?.invoiceNumber,
              );
            } else {
              await sendSupplierPayableSms(
                context: context,
                ref: ref,
                supplierName: g.name,
                phone: g.phone,
                balanceCents: g.totalRemaining,
              );
            }
          },
          onPay:
              openDebt != null ? () => onPay(context, ref, openDebt) : null,
        );
      },
    );
  }
}

Future<void> _payDebt(
  BuildContext context,
  WidgetRef ref,
  Debt d,
  String currency,
  StreamProvider<List<Debt>> debtsProvider,
) async {
  final payment = await showDebtPaymentDialog(
    context,
    ref,
    maxCents: d.remainingCents,
    currency: currency,
    title: context.l10n.recordPayment,
  );
  if (payment == null) return;
  await applyDebtPayment(
    ref: ref,
    context: context,
    debt: d,
    payment: payment,
  );
  ref.invalidate(debtDashboardProvider);
  ref.invalidate(debtsProvider);
}
