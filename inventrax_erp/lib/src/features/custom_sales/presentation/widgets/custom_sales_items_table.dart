import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/store_settings_provider.dart';
import '../../../sales/domain/invoice_discount.dart';
import '../../application/custom_sales_controller.dart';
import '../../domain/custom_sales_models.dart';

class CustomSalesItemsTable extends ConsumerWidget {
  const CustomSalesItemsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customSalesControllerProvider);
    final currency = ref.watch(storeCurrencyProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if (state.lines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          'Search and add products to build your invoice',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    if (isWide) {
      return _DesktopTable(lines: state.lines, currency: currency);
    }
    return _MobileList(lines: state.lines, currency: currency);
  }
}

class _DesktopTable extends ConsumerWidget {
  const _DesktopTable({required this.lines, required this.currency});

  final List<CustomSalesLineItem> lines;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(customSalesControllerProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
        columns: const [
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('Unit price')),
          DataColumn(label: Text('Discount')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('')),
        ],
        rows: lines.map((line) {
          return DataRow(
            key: ValueKey(line.lineId),
            color: line.exceedsStock
                ? WidgetStateProperty.all(
                    Colors.orange.withValues(alpha: 0.08),
                  )
                : null,
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(line.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (line.barcode?.isNotEmpty == true)
                      Text(
                        line.barcode!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (line.exceedsStock)
                      Text(
                        'Low stock (${line.stockQty} available)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              DataCell(_QtyControl(
                key: ValueKey('qty-${line.lineId}-${line.quantity}'),
                quantity: line.quantity,
                onChanged: (q) =>
                    notifier.updateLine(line.lineId, quantity: q),
              )),
              DataCell(_MoneyField(
                key: ValueKey('price-${line.lineId}-${line.unitPriceCents}'),
                cents: line.unitPriceCents,
                currency: currency,
                onChanged: (c) =>
                    notifier.updateLine(line.lineId, unitPriceCents: c),
              )),
              DataCell(_LineDiscountField(
                key: ValueKey('disc-${line.lineId}-${line.lineDiscount.kind}-${line.lineDiscount.value}'),
                discount: line.lineDiscount,
                currency: currency,
                onChanged: (d) =>
                    notifier.updateLine(line.lineId, lineDiscount: d),
              )),
              DataCell(Text(
                formatMoney(line.lineTotalCents, currency: currency),
                style: const TextStyle(fontWeight: FontWeight.w700),
              )),
              DataCell(IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => notifier.removeLine(line.lineId),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MobileList extends ConsumerWidget {
  const _MobileList({required this.lines, required this.currency});

  final List<CustomSalesLineItem> lines;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(customSalesControllerProvider.notifier);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final line = lines[i];
        return Card(
          key: ValueKey(line.lineId),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => notifier.removeLine(line.lineId),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _QtyControl(
                        key: ValueKey('qty-m-${line.lineId}-${line.quantity}'),
                        quantity: line.quantity,
                        onChanged: (q) =>
                            notifier.updateLine(line.lineId, quantity: q),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MoneyField(
                        label: 'Price',
                        cents: line.unitPriceCents,
                        currency: currency,
                        onChanged: (c) =>
                            notifier.updateLine(line.lineId, unitPriceCents: c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _LineDiscountField(
                  discount: line.lineDiscount,
                  currency: currency,
                  onChanged: (d) =>
                      notifier.updateLine(line.lineId, lineDiscount: d),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatMoney(line.lineTotalCents, currency: currency),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QtyControl extends StatefulWidget {
  const _QtyControl({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  State<_QtyControl> createState() => _QtyControlState();
}

class _QtyControlState extends State<_QtyControl> {
  late TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: '${widget.quantity}');
  }

  @override
  void didUpdateWidget(_QtyControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity && _c.text != '${widget.quantity}') {
      _c.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: widget.quantity > 1
              ? () => widget.onChanged(widget.quantity - 1)
              : null,
        ),
        SizedBox(
          width: 40,
          child: TextFormField(
            controller: _c,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onFieldSubmitted: (v) {
              final q = int.tryParse(v) ?? 1;
              widget.onChanged(q < 1 ? 1 : q);
            },
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: () => widget.onChanged(widget.quantity + 1),
        ),
      ],
    );
  }
}

class _MoneyField extends StatefulWidget {
  const _MoneyField({
    super.key,
    required this.cents,
    required this.currency,
    required this.onChanged,
    this.label,
  });

  final int cents;
  final String currency;
  final ValueChanged<int> onChanged;
  final String? label;

  @override
  State<_MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<_MoneyField> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: (widget.cents / 100).toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(_MoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cents != widget.cents) {
      _c.text = (widget.cents / 100).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _c,
      decoration: InputDecoration(
        labelText: widget.label,
        isDense: true,
        prefixText: _symbol(widget.currency),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onFieldSubmitted: (v) {
        final parsed = double.tryParse(v) ?? 0;
        widget.onChanged((parsed * 100).round());
      },
    );
  }

  String _symbol(String c) => switch (c) {
        'USD' => '\$',
        'EUR' => '€',
        'GBP' => '£',
        _ => '$c ',
      };
}

class _LineDiscountField extends StatefulWidget {
  const _LineDiscountField({
    super.key,
    required this.discount,
    required this.currency,
    required this.onChanged,
  });

  final InvoiceDiscount discount;
  final String currency;
  final ValueChanged<InvoiceDiscount> onChanged;

  @override
  State<_LineDiscountField> createState() => _LineDiscountFieldState();
}

class _LineDiscountFieldState extends State<_LineDiscountField> {
  late TextEditingController _c;
  late DiscountKind _kind;

  @override
  void initState() {
    super.initState();
    _kind = widget.discount.kind == DiscountKind.none
        ? DiscountKind.fixedCents
        : widget.discount.kind;
    _c = TextEditingController(text: _displayValue(widget.discount));
  }

  @override
  void didUpdateWidget(_LineDiscountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.discount != widget.discount) {
      _kind = widget.discount.kind == DiscountKind.none
          ? DiscountKind.fixedCents
          : widget.discount.kind;
      _c.text = _displayValue(widget.discount);
    }
  }

  String _displayValue(InvoiceDiscount d) {
    if (!d.isActive) return '0';
    if (d.kind == DiscountKind.percentBps) {
      return (d.value / 100).toStringAsFixed(1);
    }
    return (d.value / 100).toStringAsFixed(2);
  }

  void _apply() {
    final raw = double.tryParse(_c.text) ?? 0;
    if (raw <= 0) {
      widget.onChanged(InvoiceDiscount.none);
      return;
    }
    if (_kind == DiscountKind.percentBps) {
      widget.onChanged(
        InvoiceDiscount(
          kind: DiscountKind.percentBps,
          value: (raw * 100).round(),
        ),
      );
    } else {
      widget.onChanged(
        InvoiceDiscount(
          kind: DiscountKind.fixedCents,
          value: (raw * 100).round(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<DiscountKind>(
          value: _kind,
          isDense: true,
          underline: const SizedBox.shrink(),
          items: const [
            DropdownMenuItem(
              value: DiscountKind.fixedCents,
              child: Text('\$', style: TextStyle(fontSize: 12)),
            ),
            DropdownMenuItem(
              value: DiscountKind.percentBps,
              child: Text('%', style: TextStyle(fontSize: 12)),
            ),
          ],
          onChanged: (k) {
            if (k == null) return;
            setState(() => _kind = k);
            _apply();
          },
        ),
        SizedBox(
          width: 64,
          child: TextFormField(
            controller: _c,
            decoration: const InputDecoration(
              isDense: true,
              hintText: '0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (_) => _apply(),
            onEditingComplete: _apply,
          ),
        ),
      ],
    );
  }
}
