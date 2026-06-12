import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/store_context.dart';
import '../../../../core/ux/responsive_dialogs.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/db_provider.dart';

Future<bool?> showPaymentAccountFormSheet(
  BuildContext context, {
  PaymentAccount? existing,
}) {
  return showAppBottomSheet<bool>(
    context: context,
    builder: (ctx) => PaymentAccountFormSheet(existing: existing),
  );
}

class PaymentAccountFormSheet extends ConsumerStatefulWidget {
  const PaymentAccountFormSheet({super.key, this.existing});

  final PaymentAccount? existing;

  @override
  ConsumerState<PaymentAccountFormSheet> createState() =>
      _PaymentAccountFormSheetState();
}

class _PaymentAccountFormSheetState extends ConsumerState<PaymentAccountFormSheet> {
  late final TextEditingController _name;
  late String _type;
  late bool _isDefault;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _type = widget.existing?.accountType ?? 'cash';
    _isDefault = widget.existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(appDatabaseProvider).savePaymentAccount(
            id: widget.existing?.id,
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
            name: _name.text,
            accountType: _type,
            isDefault: _isDefault,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonErrorWithDetail(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEdit ? l10n.acctEditPaymentAccount : l10n.acctAddPaymentAccount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: !isEdit,
            decoration: InputDecoration(
              labelText: l10n.acctPaymentAccountName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: InputDecoration(
              labelText: l10n.acctPaymentAccountType,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'cash', child: Text(l10n.acctWalletTypeCash)),
              DropdownMenuItem(value: 'bank', child: Text(l10n.acctWalletTypeBank)),
              DropdownMenuItem(
                value: 'mobile',
                child: Text(l10n.acctWalletTypeMobile),
              ),
            ],
            onChanged: _saving ? null : (v) => setState(() => _type = v ?? 'cash'),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.acctSetAsDefault),
            subtitle: Text(l10n.acctDefaultPaymentHint),
            value: _isDefault,
            activeThumbColor: InventraXTheme.accent,
            onChanged: _saving ? null : (v) => setState(() => _isDefault = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: InventraXTheme.accent,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? l10n.commonSave : l10n.acctCreateButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
