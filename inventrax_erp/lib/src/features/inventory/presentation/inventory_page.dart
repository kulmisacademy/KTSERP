import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/ux/responsive.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../core/store/active_store_scope.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../barcode/presentation/barcode_input_field.dart';
import '../../barcode/presentation/barcode_lookup.dart';
import '../../barcode/presentation/barcode_scanner_page.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/components/app_input.dart';
import '../../../ui/layout/app_shell.dart';

final inventoryKpisProvider = FutureProvider.autoDispose<_InventoryKpis>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  final storeId = scope.storeId;
  final productCount = await db.countProducts(
    tenantId: StoreContext.tenantId,
    storeId: storeId,
  );
  final lowStockCount = await db.countLowStockProducts(storeId: storeId);
  final costValue = await db.sumInventoryValueAtCostCents(storeId: storeId);
  return _InventoryKpis(
    productCount: productCount,
    lowStockCount: lowStockCount,
    costValueCents: costValue,
  );
});

class _InventoryKpis {
  const _InventoryKpis({
    required this.productCount,
    required this.lowStockCount,
    required this.costValueCents,
  });

  final int productCount;
  final int lowStockCount;
  final int costValueCents;
}

final inventoryProductsProvider =
    StreamProvider.autoDispose<List<Product>>((ref) {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.products)
        ..where((p) => p.storeId.equals(scope.storeId))
        ..orderBy([(p) => OrderingTerm(expression: p.name)]))
      .watch();
});

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final _scan = TextEditingController();
  final _search = TextEditingController();
  Product? _highlight;
  bool _onlyLowStock = false;

  @override
  void dispose() {
    _scan.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _lookupBarcode(String code) async {
    final product = await barcodeLookup(ref).resolve(
      context,
      rawBarcode: code,
      allowCreate: true,
    );
    if (product != null && mounted) setState(() => _highlight = product);
  }

  List<(String, String)> _reasons(AppLocalizations l10n) => [
    ('damaged', l10n.inventoryReasonDamaged),
    ('expired', l10n.inventoryReasonExpired),
    ('theft', l10n.inventoryReasonTheft),
    ('return', l10n.inventoryReasonReturn),
    ('count', l10n.inventoryReasonCount),
    ('initial', l10n.inventoryReasonInitial),
  ];

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(inventoryProductsProvider);
    final settings = ref.watch(storeSettingsProvider);
    final kpis = ref.watch(inventoryKpisProvider);
    final currency = settings.value?.currencyCode ?? 'USD';

    final l10n = context.l10n;
    return AppShell(
      route: '/inventory',
      actions: [
        IconButton(
          tooltip: l10n.inventoryScanBarcode,
          onPressed: () async {
            final code = await scanBarcodeWithCamera(context);
            if (code != null) await _lookupBarcode(code);
          },
          icon: const Icon(Icons.qr_code_scanner),
        ),
        IconButton(
          tooltip: _onlyLowStock ? l10n.inventoryShowAll : l10n.inventoryLowStockOnly,
          onPressed: () => setState(() => _onlyLowStock = !_onlyLowStock),
          icon: Icon(_onlyLowStock ? Icons.filter_alt : Icons.filter_alt_outlined),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 760;
                  final scanField = BarcodeInputField(
                    controller: _scan,
                    label: l10n.inventoryScanBarcode,
                    onSubmitted: _lookupBarcode,
                  );
                  final searchField = TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      labelText: l10n.inventorySearchProducts,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        scanField,
                        const SizedBox(height: 10),
                        searchField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: scanField),
                      const SizedBox(width: 12),
                      SizedBox(width: 360, child: searchField),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: kpis.when(
              loading: () => const SizedBox(
                height: 76,
                child: Center(child: LinearProgressIndicator()),
              ),
              error: (e, _) => Text(l10n.inventoryKpiError(e.toString())),
              data: (k) {
                final cols = Responsive.isMobile(context)
                    ? 1
                    : (Responsive.isTablet(context) ? 2 : 3);
                return GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 88,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _kpiTile(
                      context,
                      label: l10n.navProducts,
                      value: '${k.productCount}',
                      icon: Icons.inventory_2_outlined,
                      color: InventraXTheme.moneyText(Theme.of(context).brightness),
                    ),
                    _kpiTile(
                      context,
                      label: l10n.lowStock,
                      value: '${k.lowStockCount}',
                      icon: Icons.warning_amber_rounded,
                      color: k.lowStockCount > 0
                          ? Colors.orange
                          : InventraXTheme.accent,
                    ),
                    _kpiTile(
                      context,
                      label: l10n.inventoryStockValueCost,
                      value: formatMoney(k.costValueCents, currency: currency),
                      icon: Icons.payments_outlined,
                      color: const Color(0xFF5C6BC0),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_highlight != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: AppCard(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: InventraXTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2, color: InventraXTheme.accent),
                  ),
                  title: Text(_highlight!.name),
                  subtitle: Text(
                    l10n.inventoryBarcodeLine(
                      _highlight!.barcode ?? '—',
                      _highlight!.quantity,
                    ),
                  ),
                  trailing: Text(
                    formatMoney(_highlight!.sellingPriceCents, currency: currency),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: products.when(
        data: (rows) {
          final q = _search.text.trim().toLowerCase();
          var filtered = rows;
          if (q.isNotEmpty) {
            filtered = filtered
                .where((p) => p.name.toLowerCase().contains(q) || (p.barcode ?? '').contains(q))
                .toList();
          }
          if (_onlyLowStock) {
            filtered = filtered
                .where((p) => p.minStockAlert != null && p.quantity < p.minStockAlert!)
                .toList();
          }

          if (filtered.isEmpty) {
            return Center(
              child: Padding(
                padding: Responsive.pagePadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warehouse_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noMatchingProducts,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.inventoryNoMatchingSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final p = filtered[index];
              final low = p.minStockAlert != null && p.quantity < p.minStockAlert!;
              final profitCents = p.sellingPriceCents - p.purchasePriceCents;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: InventraXTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.name.isNotEmpty ? p.name.substring(0, 1).toUpperCase() : '?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: InventraXTheme.moneyText(Theme.of(context).brightness),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                if (low)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l10n.lowStock,
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 34,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _pill(
                                    context,
                                    icon: Icons.layers_outlined,
                                    label: l10n.inventoryQtyPill(p.quantity),
                                  ),
                                  const SizedBox(width: 8),
                                  _pill(
                                    context,
                                    icon: Icons.attach_money,
                                    label: l10n.inventoryCostPill(
                                      formatMoney(
                                        p.purchasePriceCents,
                                        currency: currency,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _pill(
                                    context,
                                    icon: Icons.sell_outlined,
                                    label: l10n.inventorySellPill(
                                      formatMoney(
                                        p.sellingPriceCents,
                                        currency: currency,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _pill(
                                    context,
                                    icon: Icons.trending_up,
                                    label: l10n.inventoryProfitPill(
                                      formatMoney(profitCents, currency: currency),
                                    ),
                                    color: profitCents >= 0
                                        ? InventraXTheme.accent
                                        : Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: l10n.inventoryAdjustStock,
                        onPressed: () => _adjust(context, ref, p),
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(userFriendlyError(e, l10n: l10n))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _adjust(BuildContext context, WidgetRef ref, Product p) async {
    final l10n = context.l10n;
    final reasons = _reasons(l10n);
    final delta = TextEditingController();
    var reason = reasons.first.$1;
    final notes = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.inventoryAdjustTitle(p.name)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.inventoryCurrentQty(p.quantity)),
              const SizedBox(height: 12),
              AppInput(
                controller: delta,
                label: l10n.inventoryChangeDelta,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: reason,
                decoration: InputDecoration(labelText: l10n.inventoryReason),
                items: reasons
                    .map((r) => DropdownMenuItem(value: r.$1, child: Text(r.$2)))
                    .toList(),
                onChanged: (v) => reason = v ?? reason,
              ),
              const SizedBox(height: 12),
              AppInput(controller: notes, label: l10n.commonNotes, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonApply)),
        ],
      ),
    );

    if (ok != true) return;
    final d = int.tryParse(delta.text.trim()) ?? 0;
    if (d == 0) return;

    await ref.read(appDatabaseProvider).adjustInventory(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          productId: p.id,
          deltaQuantity: d,
          reasonCode: reason,
          notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
        );

    delta.dispose();
    notes.dispose();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.inventoryUpdated)),
      );
    }
  }

  Widget _kpiTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: c,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
