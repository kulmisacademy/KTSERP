import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/env_config.dart';
import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/l10n/locale_provider.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../core/l10n/platform_l10n.dart';
import '../../../core/store_context.dart';
import '../application/platform_providers.dart';
import '../../../ui/widgets/platform_brand_logo.dart';
import 'widgets/platform_widgets.dart';

class PlatformShell extends ConsumerWidget {
  const PlatformShell({super.key, required this.child});

  final Widget child;

  static const _sections = [
    _NavSection('overview', [
      _NavItem('/platform/dashboard', Icons.space_dashboard_rounded),
      _NavItem('/platform/search', Icons.manage_search_rounded),
    ]),
    _NavSection('business', [
      _NavItem('/platform/stores', Icons.storefront_rounded),
    ]),
    _NavSection('monetization', [
      _NavItem('/platform/plans', Icons.layers_rounded),
      _NavItem('/platform/billing-subscriptions', Icons.autorenew_rounded),
      _NavItem('/platform/billing-transactions', Icons.receipt_long_rounded),
      _NavItem('/platform/billing-gateway', Icons.hub_outlined),
      _NavItem('/platform/billing-trial', Icons.hourglass_top_rounded),
      _NavItem('/platform/billing-analytics', Icons.insights_rounded),
      _NavItem('/platform/billing', Icons.payments_rounded),
    ]),
    _NavSection('operations', [
      _NavItem('/platform/storage', Icons.cloud_rounded),
      _NavItem('/platform/otp', Icons.pin_outlined),
      _NavItem('/platform/alerts', Icons.notifications_active_rounded),
      _NavItem('/platform/audit', Icons.history_rounded),
      _NavItem('/platform/health', Icons.monitor_heart_rounded),
    ]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLocaleProvider);
    final loc = GoRouterState.of(context).matchedLocation;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 960;
    final alertCount = ref.watch(platformAnalyticsProvider).maybeWhen(
          data: (a) => a?.alerts.length ?? 0,
          orElse: () => 0,
        );

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.bgLight,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Row(
          children: [
            if (isWide) _SidebarPanel(loc: loc, alertCount: alertCount),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    isWide: isWide,
                    loc: loc,
                    alertCount: alertCount,
                    onMenu: isWide ? null : () => Scaffold.of(context).openDrawer(),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        border: Border(
                          left: isWide
                              ? BorderSide(
                                  color: AppColors.borderLight.withValues(alpha: 0.8),
                                )
                              : BorderSide.none,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: isWide
            ? null
            : Drawer(
                backgroundColor: PlatformColors.sidebar,
                child: _SidebarContent(loc: loc, alertCount: alertCount),
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isWide,
    required this.loc,
    required this.alertCount,
    this.onMenu,
  });

  final bool isWide;
  final String loc;
  final int alertCount;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pageTitle = _titleForRoute(l10n, loc);
    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                if (onMenu != null)
                  IconButton(icon: const Icon(Icons.menu), onPressed: onMenu),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pageTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        l10n.platformCommandCenter,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Alerts',
                  onPressed: () => context.go('/platform/alerts'),
                  icon: Badge(
                    isLabelVisible: alertCount > 0,
                    label: Text('$alertCount'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                ),
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search),
                  onPressed: () => context.go('/platform/search'),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        StoreContext.displayName ?? 'Super Admin',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.store_outlined, size: 18),
                  label: Text(l10n.platformStoreApp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _titleForRoute(AppLocalizations l10n, String loc) {
    if (loc.startsWith('/platform/stores/')) {
      return l10n.platformStoreInfo;
    }
    return localizedPlatformNavLabel(l10n, loc);
  }
}

class _SidebarPanel extends StatelessWidget {
  const _SidebarPanel({required this.loc, required this.alertCount});

  final String loc;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PlatformColors.sidebar,
      child: SizedBox(
        width: 272,
        child: _SidebarContent(loc: loc, alertCount: alertCount),
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({required this.loc, required this.alertCount});

  final String loc;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const PlatformBrandLogo(
                  size: 40,
                  style: BrandLogoStyle.sidebar,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EnvConfig.appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        l10n.platformSuperAdmin,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                for (final section in PlatformShell._sections) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                    child: Text(
                      localizedPlatformSectionTitle(l10n, section.key).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  for (final item in section.items)
                    _NavTile(
                      item: item,
                      selected: loc == item.route || loc.startsWith('${item.route}/'),
                      badge: item.route == '/platform/alerts' && alertCount > 0
                          ? alertCount
                          : null,
                      onTap: () => context.go(item.route),
                    ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54),
            title: Text(l10n.platformStoreApp, style: const TextStyle(color: Colors.white70)),
            onTap: () => context.go('/dashboard'),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: selected ? Colors.white : Colors.white60,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizedPlatformNavLabel(context.l10n, item.route),
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
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

class _NavSection {
  const _NavSection(this.key, this.items);
  final String key;
  final List<_NavItem> items;
}

class _NavItem {
  const _NavItem(this.route, this.icon);
  final String route;
  final IconData icon;
}
