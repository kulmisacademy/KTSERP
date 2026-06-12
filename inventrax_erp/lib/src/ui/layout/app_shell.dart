import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design_system.dart';
import '../../core/design/inventrax_brand_theme.dart';
import '../../core/ux/responsive.dart';
import '../../core/ux/responsive_page.dart';
import '../../core/ux/web_interaction.dart';
import '../../core/l10n/l10n_extension.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/l10n/nav_l10n.dart';
import '../../core/l10n/sidebar_locale_menu.dart';
import '../../core/store_context.dart';
import '../../data/local/store_settings_provider.dart';
import '../widgets/platform_brand_logo.dart';
import '../../features/auth/application/session_provider.dart';
import '../../features/users/application/permissions_provider.dart';
import '../../features/users/domain/permission_registry.dart';
import '../../features/users/domain/permission_service.dart';
import '../../features/billing/presentation/widgets/subscription_warning_banner.dart';
import '../../features/platform/presentation/widgets/impersonation_banner.dart';
import '../../observability/widgets/sync_status_indicator.dart';

final navCollapsedProvider = NotifierProvider<_NavCollapsed, bool>(
  _NavCollapsed.new,
);

class _NavCollapsed extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
    this.title,
    this.route,
    this.actions = const [],
    this.fullBleed = false,
    this.subtitle,
  }) : assert(title != null || route != null, 'Provide title or route for AppShell');

  final Widget child;

  /// Pre-localized title (use [route] when possible for auto-refresh on locale change).
  final String? title;

  /// App route path — title resolved from ARB when locale changes.
  final String? route;
  final List<Widget> actions;
  final bool fullBleed;

  /// Optional context line under the title (mobile AppBar only).
  final String? subtitle;

  static bool _canSeeNav(SidebarNavEntry nav, PermissionService checker) {
    if (checker.has(nav.permissionId)) return true;
    if (nav.route == '/sales/custom' || nav.route == '/sales/drafts') {
      return checker.has('sales.history.create') ||
          checker.has('pos.terminal.view');
    }
    return false;
  }

  static List<_NavItem> _visibleItems(WidgetRef ref, String Function(String route) labelFor) {
    final checker = ref.watch(permissionServiceProvider);
    return [
      for (final nav in InventraxPermissionRegistry.sidebarNav)
        if (_canSeeNav(nav, checker))
          _NavItem(labelFor(nav.route), nav.icon, nav.route, nav.permissionId),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDrawerLayout = !Responsive.isDesktop(context);
    final collapsed = ref.watch(navCollapsedProvider);
    final l10n = context.l10n;
    final resolvedTitle = route != null
        ? localizedNavLabel(l10n, route!)
        : title!;
    final items = _visibleItems(ref, (r) => localizedNavLabel(l10n, r));

    final content = _PageScaffold(
      actions: actions,
      fullBleed: fullBleed,
      isDrawerLayout: isDrawerLayout,
      child: child,
    );

    if (isDrawerLayout) {
      return Scaffold(
        drawer: _NavDrawer(items: items),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: responsiveMobileBackLeading(context),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resolvedTitle,
                style: TextStyle(
                  fontSize: Responsive.titleFontSize(context, desktop: 20),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          actions: [
            const SyncStatusIndicator(),
            const SizedBox(width: 4),
            ...actions,
          ],
        ),
        body: SafeArea(
          top: false,
          child: content,
        ),
      );
    }

    // Desktop: persistent sidebar — no duplicate title in AppBar.
    return SizedBox.expand(
      child: Row(
        children: [
          _Sidebar(
            items: items,
            collapsed: collapsed,
            onToggle: () => ref.read(navCollapsedProvider.notifier).toggle(),
          ),
          Expanded(
            child: Scaffold(
              body: SafeArea(child: content),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageScaffold extends ConsumerWidget {
  const _PageScaffold({
    required this.child,
    required this.actions,
    required this.fullBleed,
    required this.isDrawerLayout,
  });

  final Widget child;
  final List<Widget> actions;
  final bool fullBleed;
  final bool isDrawerLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inset = Responsive.pageInset(context);

    final topBar = isDrawerLayout
        ? null
        : Padding(
            padding: EdgeInsets.fromLTRB(inset, fullBleed ? 8 : 16, inset, 0),
            child: SizedBox(
              height: 36,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SyncStatusIndicator(),
                  const Spacer(),
                  ...actions,
                ],
              ),
            ),
          );

    if (fullBleed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ImpersonationBanner(),
          const CompactOfflineBanner(),
          const SubscriptionWarningBanner(),
          if (topBar != null) topBar,
          Expanded(child: child),
        ],
      );
    }

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ImpersonationBanner(),
          const CompactOfflineBanner(),
          const SubscriptionWarningBanner(),
          if (topBar != null) topBar,
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(inset, 12, inset, inset),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.items,
    required this.collapsed,
    required this.onToggle,
  });

  final List<_NavItem> items;
  final bool collapsed;
  final VoidCallback onToggle;

  static const _headerHeight = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLocaleProvider);
    final l10n = context.l10n;
    final w = collapsed ? 72.0 : 248.0;
    final storeName = ref.watch(storeDisplayNameProvider);
    final userLabel = StoreContext.displayName?.trim().isNotEmpty == true
        ? StoreContext.displayName!
        : (StoreContext.userEmail ?? '');

    final brand = context.brand;

    final sidebar = Material(
        color: brand.sidebarBackground,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: _headerHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const PlatformBrandLogo(
                        size: 36,
                        style: BrandLogoStyle.sidebar,
                      ),
                      if (!collapsed) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.brandName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              if (storeName.isNotEmpty)
                                Text(
                                  storeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ] else
                        const Spacer(),
                      IconButton(
                        onPressed: onToggle,
                        icon: Icon(
                          collapsed ? Icons.chevron_right : Icons.chevron_left,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Expanded(
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final i = items[index];
                    return _NavTile(
                      item: i,
                      collapsed: collapsed,
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 2, 6, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!collapsed && userLabel.isNotEmpty)
                      SizedBox(
                        height: 28,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                child: Text(
                                  userLabel.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  userLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    _SidebarFooterAction(
                      collapsed: collapsed,
                      icon: Icons.settings_outlined,
                      label: l10n.navSettings,
                      onTap: () => context.go('/settings'),
                    ),
                    SidebarLocaleMenu(collapsed: collapsed),
                    _SidebarFooterAction(
                      collapsed: collapsed,
                      icon: Icons.logout,
                      label: l10n.signOut,
                      onTap: () => ref.read(sessionProvider.notifier).signOut(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );

    if (kIsWeb) {
      return RepaintBoundary(
        child: SizedBox(width: w, child: sidebar),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: w,
      child: sidebar,
    );
  }
}

class _SidebarFooterAction extends StatelessWidget {
  const _SidebarFooterAction({
    required this.collapsed,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final bool collapsed;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: collapsed ? 32 : 30,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: WebInteraction.tap(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 6),
            child: Row(
              children: [
                Icon(icon, color: Colors.white60, size: 16),
                if (!collapsed) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.collapsed,
  });

  final _NavItem item;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).uri.toString();
    final active = _isNavActive(current, item.route);
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 38,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: WebInteraction.tap(
            onTap: () => context.go(item.route),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: active
                    ? brand.sidebarActive.withValues(alpha: 0.22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: active
                    ? Border.all(color: brand.sidebarActive.withValues(alpha: 0.45))
                    : Border.all(color: Colors.transparent),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: active ? brand.sidebarActive : Colors.white70,
                    size: 20,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.85),
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDrawer extends ConsumerWidget {
  const _NavDrawer({required this.items});

  final List<_NavItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLocaleProvider);
    final l10n = context.l10n;
    final brand = context.brand;

    return Drawer(
      backgroundColor: brand.sidebarBackground,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const PlatformBrandLogo(
                    size: 40,
                    style: BrandLogoStyle.sidebar,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.brandName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final i = items[index];
                  return _DrawerNavTile(item: i, brand: brand);
                },
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white70),
              title: Text(l10n.navSettings, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/settings');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SidebarLocaleMenu(lightStyle: true),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: Text(l10n.signOut, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(sessionProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.item,
    required this.brand,
  });

  final _NavItem item;
  final InventraXBrandTheme brand;

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).uri.toString();
    final active = _isNavActive(current, item.route);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: active ? brand.sidebarActive : Colors.white70,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.85),
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: active,
        selectedTileColor: brand.sidebarActive.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () {
          Navigator.of(context).pop();
          context.go(item.route);
        },
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route, this.permission);
  final String label;
  final IconData icon;
  final String route;
  final String permission;
}

bool _isNavActive(String current, String route) {
  if (current == route) return true;
  if (route == '/purchases') return current == '/purchases';
  if (route == '/sales') {
    return current == '/sales' ||
        (current.startsWith('/sales/') &&
            !current.startsWith('/sales/custom'));
  }
  if (route == '/dashboard') return false;
  return current.startsWith('$route/');
}
