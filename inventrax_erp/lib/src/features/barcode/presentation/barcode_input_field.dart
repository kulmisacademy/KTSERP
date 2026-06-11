import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/db_provider.dart';
import '../domain/barcode_service.dart';
import 'barcode_scanner_page.dart';

/// Barcode text field with camera scan + auto-generate. HID scanners type here.
class BarcodeInputField extends ConsumerStatefulWidget {
  const BarcodeInputField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.excludeProductId,
    this.autofocus = false,
    this.label = 'Barcode',
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? excludeProductId;
  final bool autofocus;
  final String label;

  @override
  ConsumerState<BarcodeInputField> createState() => _BarcodeInputFieldState();
}

class _BarcodeInputFieldState extends ConsumerState<BarcodeInputField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: 'Scan or type barcode',
              prefixIcon: const Icon(Icons.qr_code_scanner),
            ),
            textInputAction: TextInputAction.done,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            IconButton.filledTonal(
              tooltip: 'Scan with camera',
              onPressed: () async {
                final code = await scanBarcodeWithCamera(context);
                if (code != null && mounted) {
                  widget.controller.text = code;
                  widget.onChanged?.call(code);
                  widget.onSubmitted?.call(code);
                }
              },
              icon: const Icon(Icons.camera_alt_outlined),
            ),
            IconButton.filledTonal(
              tooltip: 'Generate barcode',
              onPressed: _generate,
              icon: const Icon(Icons.auto_fix_high),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _generate() async {
    final db = ref.read(appDatabaseProvider);
    String? code;
    for (var i = 0; i < 8; i++) {
      final candidate = BarcodeService.generateCode128();
      final taken = await db.isBarcodeTaken(
        storeId: StoreContext.storeId,
        barcode: candidate,
        excludeProductId: widget.excludeProductId,
      );
      if (!taken) {
        code = candidate;
        break;
      }
    }
    if (code == null || !mounted) return;
    widget.controller.text = code;
    HapticFeedback.mediumImpact();
    widget.onChanged?.call(code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.barcodeGenerated(code))),
    );
  }
}
