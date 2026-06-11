import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../domain/invoice_display_preferences.dart';

/// Toggle chips for invoice column visibility — instant, lightweight updates.
class InvoiceDisplayControls extends StatelessWidget {
  const InvoiceDisplayControls({
    super.key,
    required this.display,
    required this.onChanged,
  });

  final InvoiceDisplayPreferences display;
  final ValueChanged<InvoiceDisplayPreferences> onChanged;

  static const _teal = Color(0xFF19D3B4);
  static const _navy = Color(0xFF041F4A);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _presetChip(
          label: l10n.invoiceCompact,
          selected: display.compactMode &&
              !display.showSku &&
              !display.showDiscount &&
              !display.showTax,
          onTap: () => onChanged(InvoiceDisplayPreferences.compact),
        ),
        _presetChip(
          label: l10n.invoiceDetailed,
          selected: display.showSku &&
              display.showDiscount &&
              display.showTax &&
              !display.compactMode,
          onTap: () => onChanged(InvoiceDisplayPreferences.detailed),
        ),
        const SizedBox(width: 4),
        _toggleChip(
          label: l10n.invoiceSku,
          icon: Icons.qr_code_2_outlined,
          value: display.showSku,
          onChanged: (v) => onChanged(
            display.copyWith(showSku: v, compactMode: false),
          ),
        ),
        _toggleChip(
          label: l10n.invoiceDiscount,
          icon: Icons.local_offer_outlined,
          value: display.showDiscount,
          onChanged: (v) => onChanged(
            display.copyWith(showDiscount: v, compactMode: false),
          ),
        ),
        _toggleChip(
          label: l10n.invoiceTax,
          icon: Icons.receipt_long_outlined,
          value: display.showTax,
          onChanged: (v) => onChanged(
            display.copyWith(showTax: v, compactMode: false),
          ),
        ),
      ],
    );
  }

  Widget _presetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : _navy,
        ),
      ),
      backgroundColor: selected ? _navy : const Color(0xFFF1F5F9),
      side: BorderSide(color: selected ? _navy : const Color(0xFFE2E8F0)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }

  Widget _toggleChip({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      avatar: Icon(icon, size: 16, color: value ? _teal : _navy),
      selected: value,
      showCheckmark: false,
      selectedColor: _teal.withValues(alpha: 0.15),
      side: BorderSide(
        color: value ? _teal : const Color(0xFFE2E8F0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      visualDensity: VisualDensity.compact,
      onSelected: onChanged,
    );
  }
}
