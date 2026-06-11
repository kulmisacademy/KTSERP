import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../data/accounting_provider.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

class AddJournalEntryPage extends ConsumerStatefulWidget {
  const AddJournalEntryPage({super.key});

  @override
  ConsumerState<AddJournalEntryPage> createState() => _AddJournalEntryPageState();
}

class _AddJournalEntryPageState extends ConsumerState<AddJournalEntryPage> {
  final _description = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  String? _debitAccountId;
  String? _creditAccountId;
  final _amount = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _description.dispose();
    _notes.dispose();
    _amount.dispose();
    super.dispose();
  }

  int _cents(String s) => ((double.tryParse(s.trim()) ?? 0) * 100).round();

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accounts = ref.watch(chartOfAccountsProvider);
    final dateLabel = DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
        .format(_date);

    return AccountingShell(
      title: l10n.acctNewJournalEntry,
      child: accounts.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text(l10n.acctErrorDetail(e.toString()))),
        data: (accts) {
          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: l10n.acctManualJournalEntry,
                  subtitle: l10n.acctManualJournalSubtitle,
                  trailing: TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.commonCancel),
                  ),
                ),
                AccountingStatusBanner(
                  ok: true,
                  title: l10n.acctBalancedEntryRequired,
                  subtitle: l10n.acctBalancedEntryBannerSubtitle,
                ),
                const SizedBox(height: 20),
                AccountingFormCard(
                  title: l10n.acctEntryDetails,
                  children: [
                    TextField(
                      controller: _description,
                      decoration: _fieldDecoration(
                        l10n.acctDescription,
                        icon: Icons.description_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: InventraXTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: InventraXTheme.primary,
                        ),
                      ),
                      title: Text(l10n.acctEntryDate),
                      subtitle: Text(dateLabel),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _debitAccountId,
                      decoration: _fieldDecoration(
                        l10n.acctDebitAccount,
                        icon: Icons.arrow_downward,
                      ),
                      items: accts
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text('${a.code} ${a.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _debitAccountId = v),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _creditAccountId,
                      decoration: _fieldDecoration(
                        l10n.acctCreditAccount,
                        icon: Icons.arrow_upward,
                      ),
                      items: accts
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text('${a.code} ${a.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _creditAccountId = v),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration(
                        l10n.acctAmount,
                        icon: Icons.attach_money,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _notes,
                      maxLines: 2,
                      decoration: _fieldDecoration(l10n.acctNotesOptional),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _posting ? null : _submit,
                      icon: _posting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(l10n.acctPostEntry),
                      style: FilledButton.styleFrom(
                        backgroundColor: InventraXTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final cents = _cents(_amount.text);
    if (cents <= 0 ||
        _debitAccountId == null ||
        _creditAccountId == null ||
        _description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.acctFillRequiredFields)),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      await ref.read(accountingEngineProvider).postManualJournal(
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
            entryDate: _date,
            description: _description.text.trim(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            userId: StoreContext.userId,
            lines: [
              (
                accountId: _debitAccountId!,
                debitCents: cents,
                creditCents: 0,
              ),
              (
                accountId: _creditAccountId!,
                debitCents: 0,
                creditCents: cents,
              ),
            ],
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.acctJournalPosted)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.acctErrorDetail(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
}
