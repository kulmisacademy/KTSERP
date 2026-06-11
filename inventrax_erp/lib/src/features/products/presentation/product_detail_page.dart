import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/layout/app_shell.dart';
import '../../../ui/widgets/product_thumbnail.dart';
import '../../users/domain/app_permission.dart';
import 'products_page.dart';

final productDetailProvider = FutureProvider.autoDispose
    .family<
        ({
          Product product,
          List<InventoryMovement> movements,
          List<
              ({
                Purchase purchase,
                PurchaseItem item,
                String? supplierName,
              })> purchases,
        })?,
        String>(
  (ref, productId) async {
    final db = ref.watch(appDatabaseProvider);
    final storeId = StoreContext.storeId;
    final product = await db.getProductById(
      storeId: storeId,
      productId: productId,
    );
    if (product == null) return null;

    final movements = await db.listInventoryMovementsForProduct(
      storeId: storeId,
      productId: productId,
    );
    final purchases = await db.listProductPurchaseHistory(
      storeId: storeId,
      productId: productId,
    );

    return (
      product: product,
      movements: movements,
      purchases: purchases,
    );
  },
);

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(productDetailProvider(productId));
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final dateFmt = DateFormat('MMM d, yyyy • HH:mm');

    return AppShell(
      title: 'Product',
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bundle) {
          if (bundle == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Product not found'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/products'),
                    child: const Text('Back to catalog'),
                  ),
                ],
              ),
            );
          }

          final p = bundle.product;
          final profitCents = p.sellingPriceCents - p.purchasePriceCents;
          final marginPct = p.purchasePriceCents > 0
              ? (profitCents / p.purchasePriceCents * 100).toStringAsFixed(1)
              : '—';

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              AppCard(
                child: Column(
                  children: [
                    ProductThumbnail(
                      product: p,
                      size: 140,
                      borderRadius: 16,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      p.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (p.secondaryName != null &&
                        p.secondaryName!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        p.secondaryName!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _MetricRow(
                      children: [
                        _MetricChip(
                          label: 'Sell',
                          value: formatMoney(
                            p.sellingPriceCents,
                            currency: currency,
                          ),
                          color: InventraXTheme.primary,
                        ),
                        _MetricChip(
                          label: 'Cost',
                          value: formatMoney(
                            p.purchasePriceCents,
                            currency: currency,
                          ),
                        ),
                        _MetricChip(
                          label: 'Margin',
                          value: '$marginPct%',
                          color: profitCents >= 0
                              ? InventraXTheme.accent
                              : Theme.of(context).colorScheme.error,
                        ),
                        _MetricChip(
                          label: 'Stock',
                          value: '${p.quantity}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (p.barcode != null && p.barcode!.isNotEmpty)
                      Text(
                        'Barcode: ${p.barcode}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/products'),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Catalog'),
                    ),
                  ),
                  if (StoreContext.can(AppPermission.productsEdit)) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await ProductsPage.showEditDialog(
                            context,
                            ref,
                            existing: p,
                          );
                          ref.invalidate(productDetailProvider(productId));
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: FilledButton.styleFrom(
                          backgroundColor: InventraXTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Stock history',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              if (bundle.movements.isEmpty)
                const AppCard(
                  child: Text('No stock movements recorded yet.'),
                )
              else
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < bundle.movements.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _MovementTile(
                          movement: bundle.movements[i],
                          dateFmt: dateFmt,
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Purchase history',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              if (bundle.purchases.isEmpty)
                const AppCard(
                  child: Text('No purchases recorded for this product.'),
                )
              else
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < bundle.purchases.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        _PurchaseTile(
                          row: bundle.purchases[i],
                          currency: currency,
                          dateFmt: DateFormat('MMM d, yyyy'),
                          onTap: () => context.go(
                            '/purchases/${bundle.purchases[i].purchase.id}',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: children,
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.primary).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (color ?? theme.colorScheme.primary).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({
    required this.movement,
    required this.dateFmt,
  });

  final InventoryMovement movement;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = movement.deltaQuantity;
    final positive = delta > 0;
    final color = positive
        ? InventraXTheme.accent
        : delta < 0
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          positive ? Icons.add : Icons.remove,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        _movementLabel(movement.reasonCode),
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        [
          dateFmt.format(movement.createdAt),
          if (movement.notes != null && movement.notes!.isNotEmpty)
            movement.notes!,
          if (movement.referenceId != null)
            'Ref ${movement.referenceId!.substring(0, 8)}',
        ].join(' • '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${positive ? '+' : ''}$delta',
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static String _movementLabel(String code) {
    return switch (code) {
      'sale' => 'Sale',
      'purchase' => 'Purchase',
      'sale_void' => 'Sale voided',
      'sale_refund' => 'Sale refund',
      'damaged' => 'Damaged goods',
      'expired' => 'Expired',
      'theft' => 'Shrinkage',
      'return' => 'Supplier return',
      'count' => 'Stock count',
      'initial' => 'Initial stock',
      _ => code,
    };
  }
}

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({
    required this.row,
    required this.currency,
    required this.dateFmt,
    required this.onTap,
  });

  final ({
    Purchase purchase,
    PurchaseItem item,
    String? supplierName,
  }) row;
  final String currency;
  final DateFormat dateFmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inv = row.purchase.invoiceNumber;
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.local_shipping_outlined),
      title: Text(
        row.supplierName ?? 'Supplier',
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        [
          dateFmt.format(row.purchase.purchaseDate),
          if (inv != null && inv.isNotEmpty) 'Invoice $inv',
          'Qty ${row.item.quantity} @ ${formatMoney(row.item.purchasePriceCents, currency: currency)}',
        ].join(' • '),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatMoney(row.item.lineTotalCents, currency: currency),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}
