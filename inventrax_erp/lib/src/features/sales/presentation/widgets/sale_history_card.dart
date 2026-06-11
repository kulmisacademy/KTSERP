import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_theme.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/store_settings_provider.dart';

class SaleHistoryCard extends StatelessWidget {
  const SaleHistoryCard({
    super.key,
    required this.sale,
    required this.currency,
    required this.onReprint,
    required this.onView,
    required this.onVoid,
    required this.onRefund,
  });

  final Sale sale;
  final String currency;
  final VoidCallback onReprint;
  final VoidCallback onView;
  final VoidCallback onVoid;
  final VoidCallback onRefund;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final voided = sale.status == 'voided';
    final refunded = sale.refundedTotalCents;
    final net = sale.totalCents - refunded;
    final partial = sale.status == 'partial_refund' || refunded > 0;
    final dateFmt = DateFormat('MMM d, yyyy • HH:mm');

    final status = voided
        ? _SaleStatus.voided
        : partial
            ? _SaleStatus.refunded
            : _SaleStatus.completed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: voided ? null : onReprint,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: status.borderColor.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusIcon(status: status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatMoney(net, currency: currency),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: voided
                                      ? theme.colorScheme.onSurfaceVariant
                                      : InventraXTheme.moneyText(
                                          theme.brightness,
                                        ),
                                  decoration:
                                      voided ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            _StatusChip(status: status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFmt.format(sale.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (action) {
                      switch (action) {
                        case 'view':
                          onView();
                        case 'receipt':
                          onReprint();
                        case 'refund':
                          onRefund();
                        case 'void':
                          onVoid();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility_outlined),
                          title: Text('View receipt'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'receipt',
                        child: ListTile(
                          leading: Icon(Icons.receipt_long_outlined),
                          title: Text('Reprint receipt'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (!voided) ...[
                        const PopupMenuItem(
                          value: 'refund',
                          child: ListTile(
                            leading: Icon(Icons.undo_rounded),
                            title: Text('Partial refund'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'void',
                          child: ListTile(
                            leading: Icon(Icons.block, color: Colors.red),
                            title: Text('Void sale'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: _paymentLabel(sale.paymentJson),
                  ),
                  _InfoChip(
                    icon: Icons.tag_outlined,
                    label: '#${sale.id.substring(0, 8).toUpperCase()}',
                  ),
                  if (sale.discountCents > 0)
                    _InfoChip(
                      icon: Icons.discount_outlined,
                      label:
                          'Discount ${formatMoney(sale.discountCents, currency: currency)}',
                    ),
                  if (sale.taxCents > 0)
                    _InfoChip(
                      icon: Icons.percent_outlined,
                      label: 'Tax ${formatMoney(sale.taxCents, currency: currency)}',
                    ),
                ],
              ),
              if (refunded > 0 || voided) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: status.borderColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    voided
                        ? 'Voided: ${sale.voidReason ?? "No reason given"}'
                        : 'Refunded ${formatMoney(refunded, currency: currency)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: status.borderColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _paymentLabel(String paymentJson) {
    try {
      final m = jsonDecode(paymentJson);
      if (m is! Map) return 'Payment';
      final method = m['method']?.toString();
      if (method == 'split') return 'Split payment';
      if (method != null && method.isNotEmpty) {
        return method[0].toUpperCase() + method.substring(1);
      }
    } catch (_) {}
    return 'Payment';
  }
}

enum _SaleStatus { completed, refunded, voided }

extension on _SaleStatus {
  Color get borderColor => switch (this) {
        _SaleStatus.completed => InventraXTheme.accent,
        _SaleStatus.refunded => InventraXTheme.warning,
        _SaleStatus.voided => const Color(0xFFE53935),
      };

  String get label => switch (this) {
        _SaleStatus.completed => 'Completed',
        _SaleStatus.refunded => 'Refunded',
        _SaleStatus.voided => 'Voided',
      };

  IconData get icon => switch (this) {
        _SaleStatus.completed => Icons.check_circle_rounded,
        _SaleStatus.refunded => Icons.undo_rounded,
        _SaleStatus.voided => Icons.cancel_rounded,
      };
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final _SaleStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: status.borderColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(status.icon, color: status.borderColor, size: 24),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _SaleStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.borderColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.borderColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: InventraXTheme.moneyText(Theme.of(context).brightness),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
