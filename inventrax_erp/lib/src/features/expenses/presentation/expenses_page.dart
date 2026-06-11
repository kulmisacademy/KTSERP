import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../accounting/data/accounting_provider.dart';
import '../../dashboard/dashboard_providers.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/layout/app_shell.dart';

const _uuid = Uuid();

final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchExpenses(storeId: StoreContext.storeId);
});

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    final l10n = context.l10n;
    return AppShell(
      route: '/expenses',
      actions: [
        FilledButton.tonalIcon(
          onPressed: () async {
            final created = await showDialog<bool>(
              context: context,
              builder: (context) => const _AddExpenseDialog(),
            );
            if (created == true && context.mounted) {
              invalidateDashboardMetrics(ref);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.expenseSaved)),
              );
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.addExpense),
        ),
        const SizedBox(width: 8),
      ],
      child: expenses.when(
        data: (rows) {
          if (rows.isEmpty) {
            return AppEmptyState(
              title: l10n.noExpenses,
              subtitle: l10n.noExpensesSubtitle,
              icon: Icons.receipt_long_outlined,
            );
          }
          return ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = rows[index];
                return ListTile(
                  title: Text(e.name),
                  subtitle: Text('${e.category} • ${e.expenseDate}'),
                  trailing: Text(
                    (e.amountCents / 100).toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              },
            );
          },
        error: (e, _) => Center(child: Text(userFriendlyError(e, l10n: l10n))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _AddExpenseDialog extends ConsumerStatefulWidget {
  const _AddExpenseDialog();

  @override
  ConsumerState<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<_AddExpenseDialog> {
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _amount = TextEditingController();
  String? _paymentAccountId;

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _amount.dispose();
    super.dispose();
  }

  int _toCents(String s) {
    final v = double.tryParse(s.trim()) ?? 0;
    return (v * 100).round();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _category.text = context.l10n.expenseCategoryMisc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final db = ref.watch(appDatabaseProvider);
    final paymentAccounts = ref.watch(paymentAccountsProvider);
    return AlertDialog(
      title: Text(l10n.addExpense),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.expenseName),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _category,
              decoration: InputDecoration(labelText: l10n.expenseCategory),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.expenseAmount),
            ),
            const SizedBox(height: 8),
            paymentAccounts.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (accounts) {
                _paymentAccountId ??= accounts
                    .where((a) => a.isDefault)
                    .map((a) => a.id)
                    .firstOrNull;
                if (accounts.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<String>(
                  value: _paymentAccountId,
                  decoration: InputDecoration(
                    labelText: l10n.paidFromAccount,
                  ),
                  items: accounts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _paymentAccountId = v),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () async {
            final name = _name.text.trim();
            if (name.isEmpty) return;

            final tenantId = StoreContext.tenantId;
            final storeId = StoreContext.storeId;

            final expenseId = _uuid.v4();
            await db.addExpense(
              ExpensesCompanion.insert(
                id: expenseId,
                tenantId: tenantId,
                storeId: storeId,
                name: name,
                category: _category.text.trim().isEmpty
                    ? l10n.expenseCategoryMisc
                    : _category.text.trim(),
                amountCents: _toCents(_amount.text),
                expenseDate: DateTime.now(),
                paidBy: Value(_paymentAccountId),
              ),
            );

            final expense = await db.getExpenseById(expenseId);
            if (expense != null) {
              try {
                await ref.read(accountingEngineProvider).postExpense(
                      expense: expense,
                      paymentAccountId: _paymentAccountId,
                    );
              } catch (_) {}
            }

            if (context.mounted) Navigator.of(context).pop(true);
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

