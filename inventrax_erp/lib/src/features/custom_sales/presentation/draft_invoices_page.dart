import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/local/app_database.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/layout/app_shell.dart';
import '../application/custom_sales_controller.dart';
import '../application/custom_sales_drafts_provider.dart';
import '../domain/custom_sales_serializer.dart';

class DraftInvoicesPage extends ConsumerWidget {
  const DraftInvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(customSalesDraftsProvider);
    final dateFmt = DateFormat.yMMMd();

    return AppShell(
      route: '/sales/drafts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Draft Invoices',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Resume, edit, or delete saved invoice drafts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => context.go('/sales/custom'),
                  icon: const Icon(Icons.add),
                  label: const Text('New invoice'),
                ),
              ],
            ),
          ),
          Expanded(
            child: drafts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        const Text('No draft invoices yet'),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => context.go('/sales/custom'),
                          child: const Text('Create invoice'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final draft = list[i];
                    return _DraftCard(
                      draft: draft,
                      dateFmt: dateFmt,
                      onResume: () => _resume(context, ref, draft),
                      onDelete: () => _delete(context, ref, draft),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resume(
    BuildContext context,
    WidgetRef ref,
    HeldSale draft,
  ) async {
    final ok = await ref
        .read(customSalesControllerProvider.notifier)
        .loadDraft(draft.id);
    if (!context.mounted) return;
    if (ok) {
      context.go('/sales/custom');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not restore draft')),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    HeldSale draft,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete draft?'),
        content: Text(
          'Delete "${draft.label ?? 'Invoice draft'}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref
        .read(customSalesControllerProvider.notifier)
        .deleteDraft(draft.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft deleted')),
      );
    }
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.dateFmt,
    required this.onResume,
    required this.onDelete,
  });

  final HeldSale draft;
  final DateFormat dateFmt;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    var lineCount = 0;
    var customer = '';
    try {
      final state = CustomSalesSerializer.decode(draft.payloadJson);
      lineCount = state.lines.length;
      customer = state.customerName ?? 'Walk-in';
    } catch (_) {}

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.label ?? 'Invoice draft',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$lineCount items • $customer • ${dateFmt.format(draft.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onDelete,
            child: const Text('Delete'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onResume,
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }
}
