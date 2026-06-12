import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/ux/responsive.dart';

/// Standard scroll body padding for accounting pages.
class AccountingPageBody extends StatelessWidget {
  const AccountingPageBody({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding ?? Responsive.pagePadding(context),
      child: child,
    );
  }
}

class AccountingPageHeader extends StatelessWidget {
  const AccountingPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AccountingSurfaceCard extends StatelessWidget {
  const AccountingSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AccountingEmptyState extends StatelessWidget {
  const AccountingEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.pagePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: InventraXTheme.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: InventraXTheme.primary.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class AccountingLoadingState extends StatelessWidget {
  const AccountingLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class AccountingStatusBanner extends StatelessWidget {
  const AccountingStatusBanner({
    super.key,
    required this.ok,
    required this.title,
    required this.subtitle,
  });

  final bool ok;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = ok ? InventraXTheme.accent : const Color(0xFFE53935);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.verified_outlined : Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountingSectionTitle extends StatelessWidget {
  const AccountingSectionTitle({
    super.key,
    required this.label,
    this.count,
    this.color,
  });

  final String label;
  final int? count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? InventraXTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AccountingSourceChip extends StatelessWidget {
  const AccountingSourceChip({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (source) {
      'sale' => ('Sale', InventraXTheme.accent),
      'purchase' => ('Purchase', const Color(0xFF5C6BC0)),
      'expense' => ('Expense', const Color(0xFFFFA000)),
      'debt' => ('Debt', const Color(0xFF8D6E63)),
      'deposit' => ('Deposit', InventraXTheme.primary),
      'withdrawal' => ('Withdrawal', const Color(0xFFE53935)),
      'sale_void' => ('Void', const Color(0xFFE53935)),
      'manual' => ('Manual', const Color(0xFF64748B)),
      _ => (source, const Color(0xFF64748B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

Color accountTypeColor(String type) {
  return switch (type) {
    'asset' => InventraXTheme.primary,
    'liability' => const Color(0xFFE53935),
    'equity' => const Color(0xFF5C6BC0),
    'revenue' => InventraXTheme.accent,
    'expense' => const Color(0xFFFFA000),
    _ => const Color(0xFF64748B),
  };
}

String accountTypeLabel(String type) {
  return switch (type) {
    'asset' => 'Assets',
    'liability' => 'Liabilities',
    'equity' => 'Equity',
    'revenue' => 'Revenue',
    'expense' => 'Expenses',
    _ => type,
  };
}

class AccountingReportLine extends StatelessWidget {
  const AccountingReportLine({
    super.key,
    required this.label,
    required this.amount,
    this.bold = false,
    this.indent = false,
    this.highlight = false,
    this.negative = false,
  });

  final String label;
  final String amount;
  final bool bold;
  final bool indent;
  final bool highlight;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final base = bold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;
    final amountColor = negative
        ? const Color(0xFFE53935)
        : (highlight ? InventraXTheme.accent : null);

    return Padding(
      padding: EdgeInsets.only(
        left: indent ? 12 : 0,
        top: bold ? 12 : 8,
        bottom: bold ? 12 : 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: base?.copyWith(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          Text(
            amount,
            style: base?.copyWith(
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountingDataTableCard extends StatelessWidget {
  const AccountingDataTableCard({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return AccountingSurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          headingTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
          columns: [
            for (final c in columns) DataColumn(label: Text(c)),
          ],
          rows: [
            for (final row in rows)
              DataRow(
                cells: [for (final cell in row) DataCell(Text(cell))],
              ),
          ],
        ),
      ),
    );
  }
}

class AccountingFormCard extends StatelessWidget {
  const AccountingFormCard({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AccountingSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          ...children,
        ],
      ),
    );
  }
}

class AccountListTile extends StatelessWidget {
  const AccountListTile({
    super.key,
    required this.code,
    required this.name,
    required this.trailing,
    this.badge,
    this.onTap,
  });

  final String code;
  final String name;
  final Widget trailing;
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: InventraXTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  code,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: InventraXTheme.primary,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 4),
                      badge!,
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentWalletCard extends StatelessWidget {
  const PaymentWalletCard({
    super.key,
    required this.name,
    required this.accountType,
    required this.isDefault,
    this.onTap,
  });

  final String name;
  final String accountType;
  final bool isDefault;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (accountType) {
      'bank' => Icons.account_balance_rounded,
      'mobile' => Icons.phone_android_rounded,
      _ => Icons.payments_rounded,
    };
    final color = switch (accountType) {
      'bank' => InventraXTheme.primary,
      'mobile' => InventraXTheme.accent,
      _ => const Color(0xFFFFA000),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accountType.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                    ),
                  ],
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: InventraXTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Default',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: InventraXTheme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
