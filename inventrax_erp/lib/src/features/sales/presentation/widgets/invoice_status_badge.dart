import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/app_colors.dart';

/// Soft professional status pill for invoice / payment states.
class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final InvoiceStatusTone tone;

  factory InvoiceStatusBadge.payment(String status) {
    return InvoiceStatusBadge(
      label: _title(status),
      tone: switch (status) {
        'paid' => InvoiceStatusTone.success,
        'partially_paid' => InvoiceStatusTone.warning,
        'unpaid' => InvoiceStatusTone.danger,
        _ => InvoiceStatusTone.neutral,
      },
    );
  }

  factory InvoiceStatusBadge.sale(String status) {
    return InvoiceStatusBadge(
      label: _title(status),
      tone: switch (status) {
        'completed' => InvoiceStatusTone.success,
        'voided' => InvoiceStatusTone.danger,
        'partial_refund' => InvoiceStatusTone.warning,
        _ => InvoiceStatusTone.neutral,
      },
    );
  }

  static String _title(String raw) =>
      raw.replaceAll('_', ' ').split(' ').map((w) {
        if (w.isEmpty) return w;
        return '${w[0].toUpperCase()}${w.substring(1)}';
      }).join(' ');

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final (bg, fg) = _pillColors(tone, brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static (Color bg, Color fg) _pillColors(
    InvoiceStatusTone tone,
    Brightness brightness,
  ) {
    if (brightness == Brightness.dark) {
      return switch (tone) {
        InvoiceStatusTone.success => (
            const Color(0xFF0D3D32),
            const Color(0xFF6EE7B7),
          ),
        InvoiceStatusTone.warning => (
            const Color(0xFF422006),
            const Color(0xFFFCD34D),
          ),
        InvoiceStatusTone.danger => (
            const Color(0xFF450A0A),
            const Color(0xFFFCA5A5),
          ),
        InvoiceStatusTone.neutral => (
            AppColors.brandNavyMid,
            AppColors.textSecondaryDark,
          ),
      };
    }
    return switch (tone) {
      InvoiceStatusTone.success => (
          const Color(0xFFD8F5EE),
          const Color(0xFF0D6B57),
        ),
      InvoiceStatusTone.warning => (
          const Color(0xFFFFF4E5),
          const Color(0xFFB45309),
        ),
      InvoiceStatusTone.danger => (
          const Color(0xFFFEE2E2),
          const Color(0xFFB91C1C),
        ),
      InvoiceStatusTone.neutral => (
          const Color(0xFFF1F5F9),
          const Color(0xFF475569),
        ),
    };
  }
}

enum InvoiceStatusTone { success, warning, danger, neutral }
