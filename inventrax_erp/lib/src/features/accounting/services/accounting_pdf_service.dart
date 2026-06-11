import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/media/branded_pdf_header.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/store_settings_provider.dart';

class AccountingPdfService {
  AccountingPdfService({this.branding});

  final StoreBrandingPdf? branding;

  String _money(int cents, String currency) =>
      formatMoney(cents, currency: currency);

  pw.Document buildTrialBalancePdf({
    required String storeName,
    required DateTime asOf,
    required List<AccountBalanceRow> rows,
    required int totalDebit,
    required int totalCredit,
    String currency = 'USD',
  }) {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header(storeName, 'Trial Balance', asOf),
          pw.SizedBox(height: 12),
          _table(
            headers: const ['Code', 'Account', 'Debit', 'Credit', 'Balance'],
            rows: [
              for (final r in rows)
                [
                  r.account.code,
                  r.account.name,
                  r.debitCents > 0 ? _money(r.debitCents, currency) : '—',
                  r.creditCents > 0 ? _money(r.creditCents, currency) : '—',
                  _money(r.balanceCents, currency),
                ],
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Totals — Debit: ${_money(totalDebit, currency)} | '
            'Credit: ${_money(totalCredit, currency)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ..._footerWidgets(),
        ],
      ),
    );
    return doc;
  }

  pw.Document buildProfitLossPdf({
    required String storeName,
    required DateTime from,
    required DateTime to,
    required int revenue,
    required int cogs,
    required int expenses,
    required int netProfit,
    required List<({String name, int cents})> expenseLines,
    String currency = 'USD',
  }) {
    final doc = pw.Document();
    final gross = revenue - cogs;
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header(storeName, 'Profit & Loss', to, subtitle: 'From $from to $to'),
          pw.SizedBox(height: 12),
          _line('Revenue', revenue, currency),
          _line('Cost of goods sold', -cogs, currency),
          _line('Gross profit', gross, currency, bold: true),
          pw.SizedBox(height: 8),
          pw.Text('Expenses', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          for (final e in expenseLines) _line(e.name, -e.cents, currency),
          pw.Divider(),
          _line('Net profit', netProfit, currency, bold: true),
          ..._footerWidgets(),
        ],
      ),
    );
    return doc;
  }

  pw.Document buildBalanceSheetPdf({
    required String storeName,
    required DateTime asOf,
    required List<AccountBalanceRow> assets,
    required List<AccountBalanceRow> liabilities,
    required List<AccountBalanceRow> equity,
    required int totalAssets,
    required int totalLiabilities,
    required int totalEquity,
    String currency = 'USD',
  }) {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _header(storeName, 'Balance Sheet', asOf),
          pw.SizedBox(height: 12),
          ..._section('Assets', assets, currency),
          ..._section('Liabilities', liabilities, currency),
          ..._section('Equity', equity, currency),
          pw.SizedBox(height: 8),
          pw.Text(
            'Assets ${_money(totalAssets, currency)} = '
            'Liabilities + Equity ${_money(totalLiabilities + totalEquity, currency)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ..._footerWidgets(),
        ],
      ),
    );
    return doc;
  }

  List<pw.Widget> _section(
    String title,
    List<AccountBalanceRow> rows,
    String currency,
  ) {
    var total = 0;
    for (final r in rows) {
      total += r.balanceCents;
    }
    return [
      pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      for (final r in rows)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(r.account.name),
            pw.Text(_money(r.balanceCents, currency)),
          ],
        ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Total $title', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(_money(total, currency), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
      pw.SizedBox(height: 12),
    ];
  }

  pw.Widget _line(
    String label,
    int cents,
    String currency, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : null)),
          pw.Text(_money(cents, currency), style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : null)),
        ],
      ),
    );
  }

  pw.Widget _header(
    String storeName,
    String title,
    DateTime date, {
    String? subtitle,
  }) {
    if (branding != null) {
      return branding!.buildHeader(
        title,
        subtitle: subtitle,
        asOf: date,
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(storeName, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        if (subtitle != null) pw.Text(subtitle, style: const pw.TextStyle(fontSize: 10)),
        pw.Text('As of $date', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  List<pw.Widget> _footerWidgets() {
    final f = branding?.buildFooter();
    return f == null ? [] : [pw.SizedBox(height: 12), f];
  }

  pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        for (var i = 0; i < headers.length; i++)
          i: i == 1 ? const pw.FlexColumnWidth(3) : const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            for (final h in headers)
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
          ],
        ),
        for (final row in rows)
          pw.TableRow(
            children: [
              for (final cell in row)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(cell, style: const pw.TextStyle(fontSize: 9)),
                ),
            ],
          ),
      ],
    );
  }
}
