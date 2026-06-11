import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../core/media/image_storage_service.dart';
import '../../../ui/components/app_input.dart';
import '../../../ui/widgets/product_image_picker_section.dart';
import 'barcode_input_field.dart';

const _uuid = Uuid();

/// Returned when registering a product during a purchase receive flow.
class QuickProductReceiveResult {
  const QuickProductReceiveResult({
    required this.product,
    required this.receiveQty,
  });

  final Product product;
  final int receiveQty;
}

/// Fast-register a new product after barcode scan (purchase / POS / inventory).
class QuickProductSheet extends ConsumerStatefulWidget {
  const QuickProductSheet({
    super.key,
    this.barcode,
    this.initialName,
    this.forPurchaseReceive = false,
  });

  final String? barcode;
  final String? initialName;

  /// When true, quantity is for this purchase line — stock starts at 0 until received.
  final bool forPurchaseReceive;

  @override
  ConsumerState<QuickProductSheet> createState() => _QuickProductSheetState();
}

class _QuickProductSheetState extends ConsumerState<QuickProductSheet> {
  final _name = TextEditingController();
  final _secondary = TextEditingController();
  final _cost = TextEditingController();
  final _sell = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _barcode = TextEditingController();
  var _saving = false;
  String? _pickedImagePath;
  Uint8List? _pickedImageBytes;
  var _clearImage = false;
  String? _categoryIconId;

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) _barcode.text = widget.barcode!;
    if (widget.initialName != null) _name.text = widget.initialName!;
  }

  @override
  void dispose() {
    _name.dispose();
    _secondary.dispose();
    _cost.dispose();
    _sell.dispose();
    _qty.dispose();
    _barcode.dispose();
    super.dispose();
  }

  int _cents(String s) => ((double.tryParse(s.trim()) ?? 0) * 100).round();

  Future<void> _save() async {
    final sell = _cents(_sell.text);
    final cost = _cents(_cost.text);
    final qty = int.tryParse(_qty.text.trim()) ?? 0;
    final barcode = _barcode.text.trim();
    final nameTrimmed = _name.text.trim();
    if (sell <= 0 || qty <= 0) return;
    if (barcode.isEmpty && nameTrimmed.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a product name when barcode is empty'),
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      if (barcode.isNotEmpty &&
          await db.isBarcodeTaken(storeId: StoreContext.storeId, barcode: barcode)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.barcodeAlreadyInUse)),
          );
        }
        return;
      }

      final id = _uuid.v4();
      final name = nameTrimmed.isEmpty
          ? (barcode.isEmpty ? 'Unnamed item' : 'Item $barcode')
          : nameTrimmed;
      final stockQty = widget.forPurchaseReceive ? 0 : qty;

      var imageLocal = null as String?;
      var imageUrl = null as String?;
      var thumbUrl = null as String?;
      var hasImage = false;
      if (!_clearImage &&
          (_pickedImageBytes != null || _pickedImagePath != null)) {
        final saved = await persistProductImage(
          storage: ImageStorageService(),
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          productId: id,
          pickedPath: _pickedImagePath,
          imageBytes: _pickedImageBytes,
        );
        imageLocal = saved.localPath;
        imageUrl = saved.imageUrl;
        thumbUrl = saved.thumbnailUrl;
        hasImage = saved.hasImage;
      }

      await db.upsertProduct(
        ProductsCompanion.insert(
          id: id,
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          name: name,
          secondaryName: Value(
            _secondary.text.trim().isEmpty ? null : _secondary.text.trim(),
          ),
          barcode: Value(barcode.isEmpty ? null : barcode),
          purchasePriceCents: cost > 0 ? cost : sell,
          sellingPriceCents: sell,
          quantity: Value(stockQty),
          imagePath: Value(imageLocal),
          imageUrl: Value(imageUrl),
          thumbnailUrl: Value(thumbUrl),
          categoryIcon: Value(_categoryIconId),
          hasImage: Value(hasImage),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final product = barcode.isNotEmpty
          ? await db.findProductByBarcode(
              storeId: StoreContext.storeId,
              barcode: barcode,
            )
          : await db.getProductById(
              storeId: StoreContext.storeId,
              productId: id,
            );
      if (!mounted || product == null) return;
      if (widget.forPurchaseReceive) {
        Navigator.of(context).pop(
          QuickProductReceiveResult(product: product, receiveQty: qty),
        );
      } else {
        Navigator.of(context).pop(product);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.new_releases, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'New product detected',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.forPurchaseReceive
                  ? 'Set prices and how many you are receiving on this purchase. Stock updates when you complete the purchase.'
                  : 'Enter prices and quantity — name is optional for fast stock-in.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ProductImagePickerSection(
              compact: true,
              categoryIconId: _categoryIconId,
              onCategoryIconChanged: (v) => setState(() => _categoryIconId = v),
              onImageChanged: ({
                localPath,
                imageBytes,
                imageUrl,
                thumbnailUrl,
                clearImage = false,
              }) {
                setState(() {
                  if (clearImage) {
                    _clearImage = true;
                    _pickedImagePath = null;
                    _pickedImageBytes = null;
                  } else if (imageBytes != null || localPath != null) {
                    _clearImage = false;
                    _pickedImagePath = localPath;
                    _pickedImageBytes = imageBytes;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            BarcodeInputField(
              controller: _barcode,
              label: 'Barcode (optional)',
            ),
            const SizedBox(height: 12),
            AppInput(controller: _name, label: 'Product name (optional)'),
            const SizedBox(height: 10),
            AppInput(controller: _secondary, label: 'Secondary name (optional)'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    controller: _cost,
                    label: 'Purchase price *',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppInput(
                    controller: _sell,
                    label: 'Selling price *',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppInput(
              controller: _qty,
              label: widget.forPurchaseReceive
                  ? 'Quantity receiving *'
                  : 'Quantity *',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save & continue'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Product?> showQuickProductSheet(
  BuildContext context, {
  required String barcode,
  String? initialName,
}) {
  return showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => QuickProductSheet(barcode: barcode, initialName: initialName),
  );
}

/// New product during purchase — qty applies to cart line, not pre-stock.
Future<QuickProductReceiveResult?> showQuickProductSheetForPurchase(
  BuildContext context, {
  String? barcode,
}) {
  return showModalBottomSheet<QuickProductReceiveResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => QuickProductSheet(
      barcode: barcode,
      forPurchaseReceive: true,
    ),
  );
}
