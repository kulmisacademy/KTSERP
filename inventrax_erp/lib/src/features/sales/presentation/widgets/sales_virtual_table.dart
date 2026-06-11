import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/erp_l10n.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/design/design_system.dart';
import '../../../../data/local/sales_search.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../../debts/presentation/widgets/debt_ui.dart';
import 'sale_detail_drawer.dart';

class SalesVirtualTable extends StatelessWidget {
  const SalesVirtualTable({
    super.key,
    required this.items,
    required this.currency,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onReprint,
    required this.onVoid,
    required this.onRefund,
    this.scrollController,
  });

  final List<SaleListEntry> items;
  final String currency;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final void Function(SaleListEntry entry) onReprint;
  final void Function(SaleListEntry entry) onVoid;
  final void Function(SaleListEntry entry) onRefund;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    if (!isWide) {
      return _SalesCardList(
        items: items,
        currency: currency,
        hasMore: hasMore,
        isLoadingMore: isLoadingMore,
        onLoadMore: onLoadMore,
        onReprint: onReprint,
        onVoid: onVoid,
        onRefund: onRefund,
        scrollController: scrollController,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StickyHeader(l10n: context.l10n),
        Expanded(
          child: _SalesTableBody(
            items: items,
            currency: currency,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            onLoadMore: onLoadMore,
            onReprint: onReprint,
            onVoid: onVoid,
            onRefund: onRefund,
            scrollController: scrollController,
          ),
        ),
      ],
    );
  }
}

class _StickyHeader extends StatelessWidget {
  const _StickyHeader({required this.l10n});
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _HeaderCell(l10n.colInvoice)),
          Expanded(flex: 3, child: _HeaderCell(l10n.colCustomer)),
          Expanded(flex: 2, child: _HeaderCell(l10n.colStatus)),
          Expanded(flex: 2, child: _HeaderCell(l10n.colTotal)),
          Expanded(flex: 2, child: _HeaderCell(l10n.colPayment)),
          Expanded(flex: 3, child: _HeaderCell(l10n.colDate)),
          SizedBox(width: 120, child: _HeaderCell(l10n.colActions)),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: scheme.onSurfaceVariant,
          ),
    );
  }
}

class _SalesTableBody extends StatefulWidget {
  const _SalesTableBody({
    required this.items,
    required this.currency,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onReprint,
    required this.onVoid,
    required this.onRefund,
    this.scrollController,
  });

  final List<SaleListEntry> items;
  final String currency;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final void Function(SaleListEntry entry) onReprint;
  final void Function(SaleListEntry entry) onVoid;
  final void Function(SaleListEntry entry) onRefund;
  final ScrollController? scrollController;

  @override
  State<_SalesTableBody> createState() => _SalesTableBodyState();
}

class _SalesTableBodyState extends State<_SalesTableBody> {
  late final ScrollController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.scrollController == null;
    _controller = widget.scrollController ?? ScrollController();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients || !widget.hasMore || widget.isLoadingMore) {
      return;
    }
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 280) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brightness = theme.brightness;
    final dateFmt = DateFormat('MMM d, HH:mm');
    final itemCount = widget.items.length + (widget.hasMore ? 1 : 0);

    return ListView.builder(
      controller: _controller,
      itemCount: itemCount,
      itemExtent: 56,
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final entry = widget.items[index];
        final sale = entry.sale;
        final voided = sale.status == 'voided';
        final net = sale.totalCents - sale.refundedTotalCents;
        final displayStatus = voided
            ? l10n.statusVoided
            : l10n.saleStatusLabel(
                sale.paymentStatus,
                refundedTotalCents: sale.refundedTotalCents,
              );
        final statusColor = voided
            ? scheme.error
            : debtStatusColor(sale.paymentStatus, brightness);

        return Material(
          color: index.isEven
              ? Colors.transparent
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.25),
          child: InkWell(
            onTap: () => showSaleDetailDrawer(context, entry),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.invoiceLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.customerName ?? l10n.walkIn,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _StatusBadge(
                      label: displayStatus,
                      color: statusColor,
                      brightness: brightness,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatMoney(net, currency: widget.currency),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.moneyText(brightness),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.paymentStatusLabel(sale.paymentStatus),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      dateFmt.format(sale.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: l10n.details,
                          iconSize: 20,
                          onPressed: () => showSaleDetailDrawer(context, entry),
                          icon: const Icon(Icons.open_in_new_rounded),
                        ),
                        if (!voided)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (v) {
                              switch (v) {
                                case 'reprint':
                                  widget.onReprint(entry);
                                case 'refund':
                                  widget.onRefund(entry);
                                case 'void':
                                  widget.onVoid(entry);
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value: 'reprint', child: Text(l10n.printAction)),
                              PopupMenuItem(value: 'refund', child: Text(l10n.refundAction)),
                              PopupMenuItem(value: 'void', child: Text(l10n.voidAction)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.brightness,
  });

  final String label;
  final Color color;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.5 : 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SalesCardList extends StatelessWidget {
  const _SalesCardList({
    required this.items,
    required this.currency,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onReprint,
    required this.onVoid,
    required this.onRefund,
    this.scrollController,
  });

  final List<SaleListEntry> items;
  final String currency;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final void Function(SaleListEntry entry) onReprint;
  final void Function(SaleListEntry entry) onVoid;
  final void Function(SaleListEntry entry) onRefund;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brightness = theme.brightness;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: items.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final entry = items[index];
          final sale = entry.sale;
          final net = sale.totalCents - sale.refundedTotalCents;
          final dateFmt = DateFormat('MMM d • HH:mm');

          return Material(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).cardColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => showSaleDetailDrawer(context, entry),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatMoney(net, currency: currency),
                            style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.moneyText(brightness),
                                ),
                          ),
                        ),
                        Text(
                          entry.invoiceLabel,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.customerName ?? l10n.walkIn} • ${dateFmt.format(sale.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${l10n.paymentStatusLabel(sale.paymentStatus)} • ${l10n.paymentStatusLabel(sale.status)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
