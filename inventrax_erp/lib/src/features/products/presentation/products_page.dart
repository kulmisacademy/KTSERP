import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../barcode/presentation/barcode_input_field.dart';
import '../../barcode/presentation/barcode_label_print.dart';
import '../../../core/media/category_product_icons.dart';
import '../../../core/media/image_storage_service.dart';
import '../../../ui/components/app_button.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/components/app_skeleton.dart';
import '../../../ui/components/app_input.dart';
import '../../../ui/layout/app_shell.dart';
import '../../platform/application/plan_limits_service.dart';
import '../../users/domain/app_permission.dart';
import '../../users/domain/rbac_helpers.dart';
import '../../users/presentation/widgets/permission_gate.dart';
import '../../../ui/widgets/product_image_picker_section.dart';
import '../../brands/presentation/brands_page.dart';
import 'product_catalog_provider.dart';
import 'widgets/product_catalog_card.dart';

const _uuid = Uuid();

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  /// Opens add/edit product dialog (catalog, detail page).
  static Future<void> showEditDialog(
    BuildContext context,
    WidgetRef ref, {
    Product? existing,
  }) =>
      _showProductDialogImpl(context, ref, existing: existing);

  static Future<void> _showProductDialogImpl(
    BuildContext context,
    WidgetRef ref, {
    Product? existing,
  }) async {
    final l10n = context.l10n;
    final creating = existing == null;
    if (creating && !Rbac.canCreateProducts()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to add products.')),
      );
      return;
    }
    if (!creating && !Rbac.canEditProducts()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to edit products.')),
      );
      return;
    }
    final settings = ref.read(storeSettingsProvider).value;
    final storeName = settings?.storeName ?? 'InventraX';

    final name = TextEditingController(text: existing?.name ?? '');
    final secondary = TextEditingController(text: existing?.secondaryName ?? '');
    final barcode = TextEditingController(text: existing?.barcode ?? '');
    var barcodeType = existing?.barcodeType ?? 'code128';
    String? selectedBrandId = existing?.brandId;
    final brands = ref.read(brandsListProvider).value ?? [];
    String? selectedIconId = existing?.categoryIcon ??
        CategoryProductIcons.parseLegacyIconPath(existing?.imagePath);
    String? pickedImagePath;
    Uint8List? pickedImageBytes;
    var clearProductImage = false;
    String? previewUrl = existing?.thumbnailUrl ?? existing?.imageUrl;
    String? previewLocal = existing?.imagePath;
    if (previewLocal != null && previewLocal.startsWith('icon:')) {
      previewLocal = null;
    }
    final cost = TextEditingController(
      text: existing != null
          ? (existing.purchasePriceCents / 100).toString()
          : '',
    );
    final price = TextEditingController(
      text: existing != null
          ? (existing.sellingPriceCents / 100).toString()
          : '',
    );
    final qty = TextEditingController(
      text: existing?.quantity.toString() ?? '0',
    );
    final minAlert = TextEditingController(
      text: existing?.minStockAlert?.toString() ?? '',
    );

    int toCents(String s) =>
        ((double.tryParse(s.trim()) ?? 0) * 100).round();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
        title: Text(existing == null ? l10n.addProduct : l10n.editProduct),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProductImagePickerSection(
                  previewPath: pickedImagePath ?? previewLocal,
                  previewUrl: clearProductImage ? null : previewUrl,
                  categoryIconId: selectedIconId,
                  onCategoryIconChanged: (v) =>
                      setDialogState(() => selectedIconId = v),
                  onImageChanged: ({
                    localPath,
                    imageBytes,
                    imageUrl,
                    thumbnailUrl,
                    clearImage = false,
                  }) {
                    setDialogState(() {
                      if (clearImage) {
                        clearProductImage = true;
                        pickedImagePath = null;
                        pickedImageBytes = null;
                        previewUrl = null;
                      } else if (imageBytes != null || localPath != null) {
                        clearProductImage = false;
                        pickedImagePath = localPath;
                        pickedImageBytes = imageBytes;
                        previewUrl = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                AppInput(controller: name, label: l10n.productNameRequired),
                const SizedBox(height: 10),
                if (brands.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    initialValue: selectedBrandId,
                    decoration: InputDecoration(labelText: l10n.brandLabel),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.noBrand),
                      ),
                      for (final b in brands)
                        DropdownMenuItem<String?>(
                          value: b.id,
                          child: Text(b.name),
                        ),
                    ],
                    onChanged: (v) => setDialogState(() => selectedBrandId = v),
                  ),
                if (brands.isNotEmpty) const SizedBox(height: 10),
                AppInput(controller: secondary, label: l10n.secondaryNameOptional),
                const SizedBox(height: 10),
                BarcodeInputField(
                  controller: barcode,
                  excludeProductId: existing?.id,
                  label: l10n.barcodeLabel,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: barcodeType,
                  decoration: InputDecoration(labelText: l10n.barcodeTypeLabel),
                  items: [
                    DropdownMenuItem(value: 'code128', child: Text(l10n.barcodeTypeCode128)),
                    DropdownMenuItem(value: 'ean13', child: Text(l10n.barcodeTypeEan13)),
                    DropdownMenuItem(value: 'qr', child: Text(l10n.barcodeTypeQr)),
                  ],
                  onChanged: (v) => barcodeType = v ?? barcodeType,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppInput(
                        controller: cost,
                        label: l10n.productsCost,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppInput(
                        controller: price,
                        label: l10n.sellPriceRequired,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppInput(
                        controller: qty,
                        label: l10n.commonQuantity,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppInput(
                        controller: minAlert,
                        label: l10n.minStockAlert,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (existing != null && existing.barcode != null)
            TextButton.icon(
              onPressed: () {
                showBarcodeLabelPreview(ctx, existing, storeName);
              },
              icon: const Icon(Icons.print_outlined, size: 18),
              label: Text(l10n.printLabel),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
        ],
      ),
      ),
    );

    if (ok != true || name.text.trim().isEmpty) {
      name.dispose();
      secondary.dispose();
      barcode.dispose();
      cost.dispose();
      price.dispose();
      qty.dispose();
      minAlert.dispose();
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final barcodeVal = barcode.text.trim();
    if (barcodeVal.isNotEmpty &&
        await db.isBarcodeTaken(
          storeId: StoreContext.storeId,
          barcode: barcodeVal,
          excludeProductId: existing?.id,
        )) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.barcodeAlreadyInUse)),
        );
      }
      return;
    }

    if (existing == null) {
      final limit = await ref.read(planLimitsServiceProvider).checkCanAddProduct(db);
      if (!limit.allowed && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(limit.message ?? l10n.productLimitReached)),
        );
        return;
      }
    }

    final productId = existing?.id ?? _uuid.v4();
    final newCost = toCents(cost.text);
    final newPrice = toCents(price.text);

    final storage = ImageStorageService();
    var imageLocal = existing?.imagePath;
    var imageUrl = existing?.imageUrl;
    var thumbUrl = existing?.thumbnailUrl;
    var hasImage = existing?.hasImage ?? false;

    if (clearProductImage) {
      imageLocal = null;
      imageUrl = null;
      thumbUrl = null;
      hasImage = false;
    } else if (pickedImageBytes != null || pickedImagePath != null) {
      final saved = await persistProductImage(
        storage: storage,
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        productId: productId,
        pickedPath: pickedImagePath,
        imageBytes: pickedImageBytes,
      );
      imageLocal = saved.localPath;
      imageUrl = saved.imageUrl;
      thumbUrl = saved.thumbnailUrl;
      hasImage = saved.hasImage;
      if (!saved.hasImage && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.productImageSaveFailed)),
        );
      }
    }

    await db.upsertProduct(
      ProductsCompanion.insert(
        id: productId,
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        name: name.text.trim(),
        secondaryName: Value(
          secondary.text.trim().isEmpty ? null : secondary.text.trim(),
        ),
        barcode: Value(barcodeVal.isEmpty ? null : barcodeVal),
        barcodeType: Value(barcodeType),
        brandId: Value(selectedBrandId),
        purchasePriceCents: newCost,
        sellingPriceCents: newPrice,
        quantity: Value(int.tryParse(qty.text.trim()) ?? 0),
        minStockAlert: Value(int.tryParse(minAlert.text.trim())),
        imagePath: Value(imageLocal),
        imageUrl: Value(imageUrl),
        thumbnailUrl: Value(thumbUrl),
        categoryIcon: Value(selectedIconId),
        hasImage: Value(hasImage),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (existing != null) {
      Future<void> audit(String field, String? oldV, String? newV) {
        if (oldV == newV) return Future.value();
        return db.recordAuditLog(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          entity: 'product',
          entityId: productId,
          action: 'update',
          field: field,
          oldValue: oldV,
          newValue: newV,
        );
      }

      await audit('barcode', existing.barcode, barcodeVal.isEmpty ? null : barcodeVal);
      await audit(
        'purchase_price_cents',
        '${existing.purchasePriceCents}',
        '$newCost',
      );
      await audit(
        'selling_price_cents',
        '${existing.sellingPriceCents}',
        '$newPrice',
      );
    }

    ref.invalidate(productCatalogProvider);
    ref.invalidate(productInventoryStatsProvider);

    name.dispose();
    secondary.dispose();
    barcode.dispose();
    cost.dispose();
    price.dispose();
    qty.dispose();
    minAlert.dispose();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.productAdded)),
      );
    }
  }

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _searchFocus = FocusNode();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 320) {
      ref.read(productCatalogProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(productCatalogProvider);
    final stats = ref.watch(productInventoryStatsProvider);
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final filter = ref.watch(productCatalogFilterProvider);
    final query = ref.watch(productQueryProvider);
    final brandFilter = ref.watch(productBrandFilterProvider);
    final brands = ref.watch(brandsListProvider);

    final l10n = context.l10n;
    return AppShell(
      route: '/products',
      subtitle: l10n.catalogAndPricing,
      actions: [
        PermissionGate(
          permission: AppPermission.productsCreate,
          child: FilledButton.icon(
            onPressed: () => ProductsPage.showEditDialog(context, ref),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.addProduct),
            style: FilledButton.styleFrom(
              backgroundColor: InventraXTheme.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      child: catalog.when(
        data: (catalogState) {
          final rows = catalogState.items;
          final counts = stats.asData?.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CatalogHeader(
                total: counts?.total ?? rows.length,
                lowStock: counts?.lowStock ?? 0,
                outOfStock: counts?.outOfStock ?? 0,
              ),
              const SizedBox(height: 16),
              _SearchPanel(
                controller: _searchController,
                focusNode: _searchFocus,
                query: query,
                resultCount: rows.length,
                onChanged: (v) => ref.read(productQueryProvider.notifier).set(v),
                onClear: () {
                  _searchController.clear();
                  ref.read(productQueryProvider.notifier).set('');
                },
              ),
              const SizedBox(height: 12),
              _FilterChips(
                filter: filter,
                onSelected: ref.read(productCatalogFilterProvider.notifier).set,
              ),
              brands.when(
                data: (brandRows) {
                  if (brandRows.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: DropdownButtonFormField<String?>(
                      initialValue: brandFilter,
                      decoration: InputDecoration(
                        labelText: l10n.filterByBrand,
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.allBrands),
                        ),
                        for (final b in brandRows)
                          DropdownMenuItem<String?>(
                            value: b.id,
                            child: Text(b.name),
                          ),
                      ],
                      onChanged: (v) =>
                          ref.read(productBrandFilterProvider.notifier).set(v),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: rows.isEmpty
                    ? AppEmptyState(
                        title: query.isNotEmpty ||
                                filter != ProductCatalogFilter.all
                            ? l10n.noMatchingProducts
                            : l10n.noProducts,
                        subtitle: query.isNotEmpty
                            ? l10n.noMatchingProductsSubtitle
                            : l10n.productsEmptySubtitle,
                        icon: Icons.inventory_2_outlined,
                        action: PermissionGate(
                          permission: AppPermission.productsCreate,
                          child: AppButton(
                            label: l10n.addProduct,
                            icon: Icons.add_rounded,
                            onPressed: () =>
                                ProductsPage.showEditDialog(context, ref),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount:
                            rows.length + (catalogState.hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          if (index >= rows.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final p = rows[index];
                          return ProductCatalogCard(
                            product: p,
                            currency: currency,
                            onTap: () => context.go('/products/${p.id}'),
                            onEdit: Rbac.canEditProducts()
                                ? () => ProductsPage.showEditDialog(
                                      context,
                                      ref,
                                      existing: p,
                                    )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const ListPageSkeleton(),
        error: (e, _) => Center(child: Text(userFriendlyError(e, l10n: l10n))),
      ),
    );
  }
}

class _StatPalette {
  const _StatPalette({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color icon;
  final Color value;
  final Color label;
}

const _totalProductsPalette = _StatPalette(
  background: Color(0xFF0F2E28),
  border: Color(0xFF1A5C4A),
  iconBackground: Color(0x331ABC9C),
  icon: Color(0xFF22D4B0),
  value: Color(0xFFF1F5F9),
  label: Color(0xFF94A3B8),
);

const _lowStockPalette = _StatPalette(
  background: Color(0xFF2E2410),
  border: Color(0xFF5C4518),
  iconBackground: Color(0x33F59E0B),
  icon: Color(0xFFF59E0B),
  value: Color(0xFFF1F5F9),
  label: Color(0xFF94A3B8),
);

const _outOfStockPalette = _StatPalette(
  background: Color(0xFF2E1414),
  border: Color(0xFF5C2424),
  iconBackground: Color(0x33E53935),
  icon: Color(0xFFE53935),
  value: Color(0xFFF1F5F9),
  label: Color(0xFF94A3B8),
);

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.total,
    required this.lowStock,
    required this.outOfStock,
  });

  final int total;
  final int lowStock;
  final int outOfStock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.inventory_2_outlined,
            label: l10n.totalProducts,
            value: '$total',
            palette: _totalProductsPalette,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.warning_amber_rounded,
            label: l10n.lowStock,
            value: '$lowStock',
            palette: _lowStockPalette,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.remove_shopping_cart_outlined,
            label: l10n.outOfStock,
            value: '$outOfStock',
            palette: _outOfStockPalette,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final String value;
  final _StatPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: palette.iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: palette.icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: palette.value,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: palette.label,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.resultCount,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final int resultCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: InventraXTheme.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: l10n.searchProductsExtended,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onClear,
                      tooltip: l10n.clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF3F6FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.searchResultCount(resultCount),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.onSelected,
  });

  final ProductCatalogFilter filter;
  final void Function(ProductCatalogFilter) onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: Text(l10n.filterAll),
          selected: filter == ProductCatalogFilter.all,
          onSelected: (_) => onSelected(ProductCatalogFilter.all),
          showCheckmark: false,
        ),
        FilterChip(
          label: Text(l10n.lowStock),
          selected: filter == ProductCatalogFilter.lowStock,
          onSelected: (_) => onSelected(ProductCatalogFilter.lowStock),
          showCheckmark: false,
        ),
        FilterChip(
          label: Text(l10n.outOfStock),
          selected: filter == ProductCatalogFilter.outOfStock,
          onSelected: (_) => onSelected(ProductCatalogFilter.outOfStock),
          showCheckmark: false,
        ),
      ],
    );
  }
}
