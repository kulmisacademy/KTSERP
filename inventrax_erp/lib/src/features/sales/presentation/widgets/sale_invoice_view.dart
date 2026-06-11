import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../../../ui/widgets/local_file_image.dart';
import '../../domain/invoice_branding.dart';
import '../../domain/invoice_display_preferences.dart';
import '../../domain/invoice_totals_engine.dart';
import '../../domain/sale_invoice_data.dart';
import 'invoice_status_badge.dart';

/// Enterprise invoice paper (white for print fidelity). Supports compact modal layout.
class SaleInvoiceView extends StatelessWidget {
  const SaleInvoiceView({
    super.key,
    required this.data,
    required this.branding,
    this.interactive = true,
    this.compact = false,
    this.totalsBreakdown,
    this.display = InvoiceDisplayPreferences.compact,
  });

  final SaleInvoiceData data;
  final InvoiceBranding branding;
  final bool interactive;
  final bool compact;
  final InvoiceTotalsBreakdown? totalsBreakdown;
  final InvoiceDisplayPreferences display;

  static const a4Aspect = 210 / 297;
  static const maxPaperWidth = 794.0;

  static const _navy = Color(0xFF041F4A);
  static const _teal = Color(0xFF19D3B4);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat.yMMMd(locale);
    final money = (int c) => formatMoney(c, currency: data.currencyCode);
    final isRtl = Bidi.isRtlLanguage(locale);

    return LayoutBuilder(
      builder: (context, constraints) {
        final paperWidth = constraints.maxWidth.clamp(280.0, maxPaperWidth);
        final padH = compact ? 20.0 : (isRtl ? 36.0 : 48.0);
        final padTop = compact ? 18.0 : 44.0;
        final padBottom = compact ? 20.0 : 40.0;

        return Center(
          child: Container(
            width: paperWidth,
            constraints: compact
                ? BoxConstraints(maxWidth: maxPaperWidth)
                : BoxConstraints(
                    maxWidth: maxPaperWidth,
                    minHeight: paperWidth / a4Aspect,
                  ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(compact ? 8 : 4),
              boxShadow: compact
                  ? [
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isRtl ? padH - 4 : padH,
                padTop,
                isRtl ? padH : padH - 4,
                padBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StoreHeader(branding: branding, compact: compact),
                  SizedBox(height: compact ? 14 : 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.invoiceTitle,
                              style: GoogleFonts.inter(
                                fontSize: compact ? 20 : 26,
                                fontWeight: FontWeight.w800,
                                color: _navy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: compact ? 4 : 6),
                            Text(
                              '${l10n.invoiceNumber}${data.invoiceNumber}',
                              style: GoogleFonts.inter(
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w600,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            alignment: WrapAlignment.end,
                            children: [
                              InvoiceStatusBadge.sale(data.status),
                              InvoiceStatusBadge.payment(data.paymentStatus),
                            ],
                          ),
                          SizedBox(height: compact ? 8 : 12),
                          _MetaLine(l10n.invoiceDate, dateFmt.format(data.createdAt)),
                          if (data.dueDate != null)
                            _MetaLine(l10n.invoiceDueDate, dateFmt.format(data.dueDate!)),
                          if (data.paymentMethod != null)
                            _MetaLine(l10n.invoicePaymentStatus, data.paymentMethod!),
                        ],
                      ),
                    ],
                  ),
                  if (compact) ...[
                    const SizedBox(height: 12),
                    _GrandTotalStrip(
                      label: l10n.invoiceGrandTotal,
                      value: money(data.totalCents),
                      paidLabel: l10n.invoicePaid,
                      paidValue: money(data.paidCents),
                      remaining: data.remainingCents > 0
                          ? '${l10n.invoiceRemaining}: ${money(data.remainingCents)}'
                          : null,
                    ),
                  ],
                  SizedBox(height: compact ? 14 : 24),
                  _CustomerCard(
                    title: l10n.invoiceBillTo,
                    name: data.customerName ?? l10n.invoiceWalkIn,
                    phone: data.customerPhone,
                    email: data.customerEmail,
                    address: data.customerAddress,
                    compact: compact,
                  ),
                  SizedBox(height: compact ? 14 : 24),
                  _ItemsTable(
                    data: data,
                    money: money,
                    interactive: interactive,
                    l10n: l10n,
                    compact: compact,
                    display: display,
                  ),
                  SizedBox(height: compact ? 14 : 20),
                  Align(
                    alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                    child: SizedBox(
                      width: compact ? 260 : 280,
                      child: _TotalsBlock(
                        data: data,
                        money: money,
                        l10n: l10n,
                        compact: compact,
                        breakdown: totalsBreakdown ?? InvoiceTotalsEngine.fromSaleInvoice(data),
                        display: display,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 16 : 28),
                  _Footer(branding: branding, l10n: l10n, compact: compact),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GrandTotalStrip extends StatelessWidget {
  const _GrandTotalStrip({
    required this.label,
    required this.value,
    required this.paidLabel,
    required this.paidValue,
    this.remaining,
  });

  final String label;
  final String value;
  final String paidLabel;
  final String paidValue;
  final String? remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF0FDF9),
        border: Border.all(color: const Color(0xFF19D3B4).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SaleInvoiceView._muted,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: SaleInvoiceView._teal,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$paidLabel: $paidValue',
                style: GoogleFonts.inter(fontSize: 11, color: SaleInvoiceView._muted),
              ),
              if (remaining != null)
                Text(
                  remaining!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SaleInvoiceView._navy,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.branding, required this.compact});

  final InvoiceBranding branding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InvoiceLogo(branding: branding, compact: compact),
        SizedBox(width: compact ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branding.storeName,
                style: GoogleFonts.inter(
                  fontSize: compact ? 15 : 18,
                  fontWeight: FontWeight.w800,
                  color: SaleInvoiceView._navy,
                ),
              ),
              if (branding.phone != null) ...[
                SizedBox(height: compact ? 2 : 4),
                _ContactLine(Icons.phone_outlined, branding.phone!, compact: compact),
              ],
              if (branding.email != null)
                _ContactLine(Icons.mail_outline, branding.email!, compact: compact),
              if (branding.address != null)
                _ContactLine(Icons.location_on_outlined, branding.address!, compact: compact),
              if (branding.taxNumber != null)
                _ContactLine(
                  Icons.receipt_long_outlined,
                  'Tax: ${branding.taxNumber}',
                  compact: compact,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoiceLogo extends StatelessWidget {
  const _InvoiceLogo({required this.branding, required this.compact});

  final InvoiceBranding branding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 64.0;
    final local = buildLocalFileImage(
      branding.logoLocalPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    if (local != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: local,
      );
    }

    final remote = branding.logoRemoteUrl;
    if (remote != null && remote.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          remote,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _initials(size),
        ),
      );
    }

    return _initials(size);
  }

  Widget _initials(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF19D3B4), Color(0xFF0B5D6B)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        branding.initials,
        style: GoogleFonts.inter(
          fontSize: compact ? 16 : 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine(this.icon, this.text, {this.compact = false});

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: compact ? 2 : 3),
      child: Row(
        children: [
          Icon(icon, size: compact ? 12 : 14, color: SaleInvoiceView._muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: compact ? 11 : 12,
                color: SaleInvoiceView._muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.inter(fontSize: 10, color: SaleInvoiceView._muted),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
        textAlign: TextAlign.end,
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.title,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.compact = false,
  });

  final String title;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(color: SaleInvoiceView._border),
        color: const Color(0xFFF8FAFC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: SaleInvoiceView._teal,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: compact ? 14 : 15,
              fontWeight: FontWeight.w700,
              color: SaleInvoiceView._navy,
            ),
          ),
          if (phone?.isNotEmpty == true) _line(phone!),
          if (email?.isNotEmpty == true) _line(email!),
          if (address?.isNotEmpty == true) _line(address!),
        ],
      ),
    );
  }

  Widget _line(String t) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          t,
          style: GoogleFonts.inter(fontSize: 11, color: SaleInvoiceView._muted),
        ),
      );
}

class _ItemsTable extends StatefulWidget {
  const _ItemsTable({
    required this.data,
    required this.money,
    required this.interactive,
    required this.l10n,
    required this.compact,
    required this.display,
  });

  final SaleInvoiceData data;
  final String Function(int) money;
  final bool interactive;
  final dynamic l10n;
  final bool compact;
  final InvoiceDisplayPreferences display;

  @override
  State<_ItemsTable> createState() => _ItemsTableState();
}

class _ItemsTableState extends State<_ItemsTable> {
  int? _hovered;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final vPad = widget.compact ? 7.0 : 11.0;
    final hPad = widget.compact ? 8.0 : 10.0;
    final cols = InvoiceTableLayout.visibleColumns(widget.display);
    final headers = InvoiceTableLayout.headerLabels(
      widget.display,
      product: l10n.invoiceProduct,
      sku: l10n.invoiceSku,
      qty: l10n.invoiceQty,
      unitPrice: l10n.invoiceUnitPrice,
      discount: l10n.invoiceDiscount,
      tax: l10n.invoiceTax,
      lineTotal: l10n.invoiceLineTotal,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SaleInvoiceView._border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Table(
          columnWidths: InvoiceTableLayout.flutterColumnWidths(widget.display),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
              children: headers
                  .map(
                    (h) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad - 1),
                      child: Text(
                        h,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: SaleInvoiceView._navy,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            for (var i = 0; i < widget.data.lines.length; i++)
              _row(i, widget.data.lines[i], cols, hPad, vPad),
          ],
        ),
      ),
    );
  }

  TableRow _row(
    int index,
    SaleInvoiceLine line,
    List<InvoiceTableColumn> cols,
    double hPad,
    double vPad,
  ) {
    final hover = widget.interactive && _hovered == index;
    final cell = (String text, {bool bold = false}) => Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: SaleInvoiceView._navy,
            ),
          ),
        );

    final cells = cols.map((col) {
      final text = switch (col) {
        InvoiceTableColumn.product => line.name,
        InvoiceTableColumn.sku => line.barcode ?? '—',
        InvoiceTableColumn.qty => _qty(line.quantity),
        InvoiceTableColumn.unitPrice => widget.money(line.unitPriceCents),
        InvoiceTableColumn.discount =>
          line.lineDiscountCents > 0 ? widget.money(line.lineDiscountCents) : '—',
        InvoiceTableColumn.tax =>
          line.lineTaxCents > 0 ? widget.money(line.lineTaxCents) : '—',
        InvoiceTableColumn.lineTotal => widget.money(line.lineTotalCents),
      };
      final bold = col == InvoiceTableColumn.lineTotal;
      if (col == InvoiceTableColumn.product &&
          widget.interactive &&
          !kIsWeb) {
        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = index),
          onExit: (_) => setState(() => _hovered = null),
          child: cell(text),
        );
      }
      return cell(text, bold: bold);
    }).toList();

    return TableRow(
      decoration: BoxDecoration(
        color: hover ? const Color(0xFFF0FDF9) : Colors.white,
      ),
      children: cells,
    );
  }

  String _qty(double q) => q == q.roundToDouble() ? '${q.toInt()}' : q.toStringAsFixed(2);
}

class _TotalsBlock extends StatelessWidget {
  const _TotalsBlock({
    required this.data,
    required this.money,
    required this.l10n,
    required this.compact,
    required this.breakdown,
    required this.display,
  });

  final SaleInvoiceData data;
  final String Function(int) money;
  final dynamic l10n;
  final bool compact;
  final InvoiceTotalsBreakdown breakdown;
  final InvoiceDisplayPreferences display;

  @override
  Widget build(BuildContext context) {
    final taxLabel = brandingTaxName(data, l10n);

    return Column(
      children: [
        _totalRow(l10n.invoiceSubtotal, money(breakdown.itemsSubtotalCents)),
        if (breakdown.showLineDiscounts)
          _totalRow('Item discounts', '-${money(breakdown.lineDiscountsCents)}'),
        if (breakdown.showInvoiceDiscount)
          _totalRow(l10n.invoiceDiscount, '-${money(breakdown.invoiceDiscountCents)}'),
        if (display.showTax && breakdown.showTax)
          _totalRow(taxLabel, money(breakdown.taxCents)),
        if (breakdown.paidCents > 0)
          _totalRow(l10n.invoicePaid, money(breakdown.paidCents)),
        if (breakdown.remainingCents > 0)
          _totalRow(l10n.invoiceRemaining, money(breakdown.remainingCents)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 10),
          child: const Divider(color: SaleInvoiceView._border, height: 1),
        ),
        _totalRow(
          l10n.invoiceGrandTotal,
          money(breakdown.grandTotalCents),
          grand: true,
          compact: compact,
        ),
      ],
    );
  }

  String brandingTaxName(SaleInvoiceData data, dynamic l10n) {
    return data.taxName?.trim().isNotEmpty == true ? data.taxName! : l10n.invoiceTax;
  }

  Widget _totalRow(String label, String value, {bool grand = false, bool compact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 3 : 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: grand ? (compact ? 13 : 14) : 11,
                fontWeight: grand ? FontWeight.w700 : FontWeight.w500,
                color: grand ? SaleInvoiceView._navy : SaleInvoiceView._muted,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: grand ? (compact ? 16 : 18) : 11,
              fontWeight: FontWeight.w800,
              color: grand ? SaleInvoiceView._teal : SaleInvoiceView._navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.branding, required this.l10n, required this.compact});

  final InvoiceBranding branding;
  final dynamic l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final footer = branding.invoiceFooter;
    final contact = <String>[
      if (branding.phone != null) branding.phone!,
      if (branding.email != null) branding.email!,
      if (branding.address != null) branding.address!,
    ];

    return Column(
      children: [
        const Divider(color: SaleInvoiceView._border),
        SizedBox(height: compact ? 8 : 12),
        Text(
          footer?.isNotEmpty == true ? footer! : l10n.invoiceThankYou,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: compact ? 11 : 12,
            color: SaleInvoiceView._muted,
            height: 1.4,
          ),
        ),
        if (contact.isNotEmpty) ...[
          SizedBox(height: compact ? 6 : 8),
          Text(
            '${branding.storeName} • ${contact.join(' • ')}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: SaleInvoiceView._muted.withValues(alpha: 0.85),
            ),
          ),
        ],
      ],
    );
  }
}
