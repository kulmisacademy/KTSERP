import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/ux/responsive.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../../../ui/components/app_skeleton.dart';
import '../../../../ui/widgets/product_thumbnail.dart';
import '../pos_cart_providers.dart';
import '../pos_products_provider.dart';

enum PosProductViewMode { grid, list }

class PosProductViewModeNotifier extends Notifier<PosProductViewMode> {
  @override
  PosProductViewMode build() => PosProductViewMode.grid;

  void set(PosProductViewMode mode) => state = mode;
}

final posProductViewModeProvider =
    NotifierProvider<PosProductViewModeNotifier, PosProductViewMode>(
  PosProductViewModeNotifier.new,
);

/// POS product picker with grid / list toggle.
class PosProductCatalog extends ConsumerWidget {
  const PosProductCatalog({super.key, required this.onProductTap});

  final void Function(Product product) onProductTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productCatalogProvider);
    final viewMode = ref.watch(posProductViewModeProvider);
    final cartQtyById = ref.watch(posCartQtyByIdProvider);
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ViewToolbar(
          viewMode: viewMode,
          onModeChanged: ref.read(posProductViewModeProvider.notifier).set,
          productCount: products.maybeWhen(data: (d) => d.length, orElse: () => null),
        ),
        AppSpacing.gapXs(),
        Expanded(
          child: products.when(
            data: (rows) {
              if (rows.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      AppSpacing.gapXs(),
                      Text(
                        'No products match your search',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              if (viewMode == PosProductViewMode.list) {
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => AppSpacing.gapXs(),
                  itemBuilder: (context, index) {
                    final p = rows[index];
                    return PosProductListCard(
                      product: p,
                      currency: currency,
                      cartQty: cartQtyById[p.id] ?? 0,
                      onTap: () => onProductTap(p),
                    );
                  },
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = Responsive.gridCrossCount(context);
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.xs,
                      crossAxisSpacing: AppSpacing.xs,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final p = rows[index];
                      return PosProductGridCard(
                        product: p,
                        currency: currency,
                        cartQty: cartQtyById[p.id] ?? 0,
                        onTap: () => onProductTap(p),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const PosCatalogSkeleton(),
            error: (e, _) => Center(child: Text(l10n.posCatalogLoadError)),
          ),
        ),
      ],
    );
  }
}

class _ViewToolbar extends StatelessWidget {
  const _ViewToolbar({
    required this.viewMode,
    required this.onModeChanged,
    required this.productCount,
  });

  final PosProductViewMode viewMode;
  final void Function(PosProductViewMode) onModeChanged;
  final int? productCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Row(
      children: [
        SegmentedButton<PosProductViewMode>(
          segments: [
            ButtonSegment(
              value: PosProductViewMode.grid,
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(l10n.viewGrid),
            ),
            ButtonSegment(
              value: PosProductViewMode.list,
              icon: const Icon(Icons.view_list_rounded, size: 18),
              label: Text(l10n.viewList),
            ),
          ],
          selected: {viewMode},
          onSelectionChanged: (s) {
            if (s.isNotEmpty) onModeChanged(s.first);
          },
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
        if (productCount != null)
          Text(
            l10n.productCountLabel(productCount!),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class PosProductGridCard extends StatefulWidget {
  const PosProductGridCard({
    super.key,
    required this.product,
    required this.currency,
    required this.cartQty,
    required this.onTap,
  });

  final Product product;
  final String currency;
  final int cartQty;
  final VoidCallback onTap;

  @override
  State<PosProductGridCard> createState() => _PosProductGridCardState();
}

class _PosProductGridCardState extends State<PosProductGridCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final product = widget.product;
    final currency = widget.currency;
    final cartQty = widget.cartQty;
    final onTap = widget.onTap;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final lowStock = product.minStockAlert != null &&
        product.quantity < product.minStockAlert!;
    final outOfStock = product.quantity <= 0;
    final inCart = cartQty > 0;
    final profitCents = product.sellingPriceCents - product.purchasePriceCents;
    final showProfit = profitCents != 0;
    final profitColor =
        profitCents >= 0 ? AppColors.accent : theme.colorScheme.error;
    final disabled = outOfStock;
    final brightness = theme.brightness;

    return Material(
      color: AppColors.surface(brightness),
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: AppRadius.mdAll,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: inCart
                  ? AppColors.accent.withValues(alpha: 0.95)
                  : AppColors.border(brightness),
              width: inCart ? 2 : 1,
            ),
            boxShadow: AppShadows.subtle(brightness),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: ProductThumbnail(
                          product: product,
                          size: 72,
                          borderRadius: 12,
                          showBorder: false,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: inCart
                            ? _CartBadge(qty: cartQty)
                            : outOfStock
                                ? _Tag(
                                    label: l10n.tagOut,
                                    color: theme.colorScheme.error,
                                  )
                                : lowStock
                                    ? _Tag(
                                        label: l10n.tagLow,
                                        color: AppColors.warning,
                                      )
                                    : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXs(),
                Text(
                  product.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapXs(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatMoney(product.sellingPriceCents, currency: currency),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.action(brightness),
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showProfit)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: profitColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: profitColor.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          l10n.posProfitLine(
                            formatMoney(profitCents, currency: currency),
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: profitColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.posCostStockLine(formatMoney(product.purchasePriceCents, currency: currency), product.quantity)}'
                  '${product.barcode != null && product.barcode!.isNotEmpty ? ' • ${product.barcode}' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    onPressed: disabled ? null : onTap,
                    icon: Icon(
                      inCart ? Icons.add_rounded : Icons.add_shopping_cart_outlined,
                      size: 18,
                    ),
                    label: Text(inCart ? l10n.posAddMore : l10n.posAddToCart),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          disabled ? null : AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PosProductListCard extends StatelessWidget {
  const PosProductListCard({
    super.key,
    required this.product,
    required this.currency,
    required this.cartQty,
    required this.onTap,
  });

  final Product product;
  final String currency;
  final int cartQty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final lowStock = product.minStockAlert != null &&
        product.quantity < product.minStockAlert!;
    final outOfStock = product.quantity <= 0;
    final inCart = cartQty > 0;
    final profitCents = product.sellingPriceCents - product.purchasePriceCents;

    final meta = <String>[
      if (product.barcode != null && product.barcode!.isNotEmpty)
        product.barcode!,
      if (product.sku != null && product.sku!.isNotEmpty) 'SKU ${product.sku}',
      'Stock ${product.quantity}',
    ].join(' • ');

    final brightness = theme.brightness;

    return Material(
      color: AppColors.surface(brightness),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: outOfStock ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: inCart
                  ? AppColors.accent
                  : AppColors.border(brightness),
              width: inCart ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ProductThumbnail(product: product, size: 40, borderRadius: 8),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.posSellLine(
                                formatMoney(
                                  product.sellingPriceCents,
                                  currency: currency,
                                ),
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.action(brightness),
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            l10n.posProfitLine(
                              formatMoney(profitCents, currency: currency),
                            ),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: profitCents >= 0
                                  ? AppColors.accent
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (inCart) ...[
                  _CartBadge(qty: cartQty),
                  const SizedBox(width: 8),
                ] else if (outOfStock)
                  _Tag(label: l10n.posOutOfStock, color: theme.colorScheme.error)
                else if (lowStock)
                  _Tag(label: l10n.posLowStock, color: AppColors.warning),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: outOfStock
                        ? theme.colorScheme.surfaceContainerHighest
                        : AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: outOfStock ? theme.disabledColor : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.qty});

  final int qty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.posQtyInCart(qty),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
