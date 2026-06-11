import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/media/branded_pdf_header.dart';
import '../../../data/local/app_database.dart';
import '../domain/report_models.dart';

class PdfReportService {
  pw.Document buildDailyReportPdf({
    required DateTime from,
    required DateTime to,
    required ProfitSnapshot profit,
    required List<Sale> sales,
    StoreBrandingPdf? branding,
  }) {
    final doc = pw.Document();
    String currency(int cents) => (cents / 100).toStringAsFixed(2);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          if (branding != null)
            branding.buildHeader(
              'Business Report',
              subtitle: 'From $from to $to',
            )
          else ...[
            pw.Text(
              'InventraX — Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('From: $from'),
            pw.Text('To:   $to'),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _row('Sales', currency(profit.salesCents)),
              _row('COGS', currency(profit.cogsCents)),
              _row('Expenses', currency(profit.expensesCents)),
              _row('Profit', currency(profit.profitCents)),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Sales',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Date/Time'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Sale ID'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Total'),
                  ),
                ],
              ),
              ...sales.map(
                (s) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(s.createdAt.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(s.id),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(currency(s.totalCents)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (branding?.buildFooter() != null) ...[
            pw.SizedBox(height: 16),
            branding!.buildFooter()!,
          ],
        ],
      ),
    );

    return doc;
  }

  pw.TableRow _row(String k, String v) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(k),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(v),
        ),
      ],
    );
  }
}

