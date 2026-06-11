import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../../../ui/components/app_card.dart';
import '../../../../ui/widgets/product_thumbnail.dart';

/// Compact catalog row — dense layout for ERP product lists.
class ProductCatalogCard extends StatelessWidget {
  const ProductCatalogCard({
    super.key,
    required this.product,
    required this.currency,
    required this.onTap,
    this.onEdit,
  });

  final Product product;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowStock = product.minStockAlert != null &&
        product.quantity < product.minStockAlert!;
    final outOfStock = product.quantity <= 0;

    final stockColor = outOfStock
        ? theme.colorScheme.error
        : lowStock
            ? InventraXTheme.warning
            : InventraXTheme.accent;

    final profitCents =
        product.sellingPriceCents - product.purchasePriceCents;
    final profitPct = product.purchasePriceCents > 0
        ? (profitCents / product.purchasePriceCents * 100).round()
        : null;

    final meta = <String>[
      if (product.barcode != null && product.barcode!.isNotEmpty)
        product.barcode!,
      'Sell ${formatMoney(product.sellingPriceCents, currency: currency)}',
      'Cost ${formatMoney(product.purchasePriceCents, currency: currency)}',
      if (profitPct != null) 'Margin $profitPct%',
    ].join(' • ');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ProductThumbnail(product: product, size: 52, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StockPill(
            quantity: product.quantity,
            color: stockColor,
            outOfStock: outOfStock,
            lowStock: lowStock,
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
            ),
        ],
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({
    required this.quantity,
    required this.color,
    required this.outOfStock,
    required this.lowStock,
  });

  final int quantity;
  final Color color;
  final bool outOfStock;
  final bool lowStock;

  @override
  Widget build(BuildContext context) {
    final label = outOfStock
        ? 'Out'
        : lowStock
            ? 'Low'
            : 'Qty';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
