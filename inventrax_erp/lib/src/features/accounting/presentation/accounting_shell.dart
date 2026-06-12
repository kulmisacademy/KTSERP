import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/acct_l10n.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/ux/responsive.dart';
import '../../../ui/layout/app_shell.dart';

class AccountingShell extends ConsumerWidget {
  const AccountingShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  static const _primary = <_AcctNav>[
    _AcctNav(Icons.insights_outlined, '/accounting'),
    _AcctNav(Icons.account_tree_outlined, '/accounting/chart'),
    _AcctNav(Icons.menu_book_outlined, '/accounting/journals'),
    _AcctNav(Icons.receipt_long_outlined, '/accounting/ledger'),
  ];

  static const _cash = <_AcctNav>[
    _AcctNav(Icons.swap_vert_rounded, '/accounting/cash'),
    _AcctNav(Icons.account_balance_wallet_outlined, '/accounting/payment-accounts'),
  ];

  static const _reports = <_AcctNav>[
    _AcctNav(Icons.balance_outlined, '/accounting/reports/trial-balance'),
    _AcctNav(Icons.trending_up_rounded, '/accounting/reports/profit-loss'),
    _AcctNav(Icons.table_chart_outlined, '/accounting/reports/balance-sheet'),
    _AcctNav(Icons.water_drop_outlined, '/accounting/reports/cash-flow'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLocaleProvider);
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).matchedLocation;
    final showSideNav = Responsive.isDesktop(context);

    final nav = Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calculate_outlined,
                    color: scheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.navAccounting,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                _NavSection(
                  title: l10n.acctNavSectionBooks,
                  items: _primary,
                  location: location,
                ),
                _NavSection(
                  title: l10n.acctNavSectionCash,
                  items: _cash,
                  location: location,
                ),
                _NavSection(
                  title: l10n.acctNavSectionReports,
                  items: _reports,
                  location: location,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final body = showSideNav
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 252, child: nav),
              VerticalDivider(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(child: child),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MobileAcctNavBar(location: location),
              Expanded(child: child),
            ],
          );

    return AppShell(
      title: title,
      actions: actions,
      child: body,
    );
  }
}

class _NavSection extends StatelessWidget {
  const _NavSection({
    required this.title,
    required this.items,
    required this.location,
  });

  final String title;
  final List<_AcctNav> items;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
            ),
          ),
          for (final item in items)
            _NavTile(item: item, selected: location == item.path),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected});

  final _AcctNav item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = localizedAcctNavLabel(context.l10n, item.path);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(item.path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? scheme.primary
                              : scheme.onSurface,
                        ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcctNav {
  const _AcctNav(this.icon, this.path);
  final IconData icon;
  final String path;
}

class _MobileAcctNavBar extends StatelessWidget {
  const _MobileAcctNavBar({required this.location});

  final String location;

  static const _all = [
    ...AccountingShell._primary,
    ...AccountingShell._cash,
    ...AccountingShell._reports,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: Responsive.pagePaddingHorizontal(context),
            itemCount: _all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _all[index];
              final selected = location == item.path ||
                  location.startsWith('${item.path}/');
              final label = localizedAcctNavLabel(context.l10n, item.path);
              return FilterChip(
                selected: selected,
                showCheckmark: false,
                avatar: Icon(
                  item.icon,
                  size: 16,
                  color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                ),
                label: Text(label),
                onSelected: (_) => context.go(item.path),
              );
            },
          ),
        ),
      ),
    );
  }
}
