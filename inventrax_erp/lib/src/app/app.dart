import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inventrax_erp/l10n/app_localizations.dart';



import '../core/l10n/fallback_platform_localizations.dart';

import '../core/l10n/l10n_dev_banner.dart';

import '../core/l10n/locale_provider.dart';

import '../features/auth/application/session_provider.dart';

import '../core/ux/theme_mode_provider.dart';

import '../observability/widgets/performance_hud.dart';

import '../ui/components/app_skeleton.dart';

import 'app_bootstrap.dart';

import 'app_router.dart';

import 'app_theme.dart';



class InventraXApp extends ConsumerWidget {

  const InventraXApp({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final router = ref.watch(appRouterProvider);

    final themeMode = ref.watch(appThemeModeProvider);

    final locale = ref.watch(appLocaleProvider);



    return MaterialApp.router(

      title: 'InventraX ERP',

      theme: InventraXTheme.light(),

      darkTheme: InventraXTheme.dark(),

      themeMode: themeMode,

      locale: locale.flutterLocale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: const [

        AppLocalizations.delegate,

        ...inventraxLocalizationDelegates,

      ],

      localeResolutionCallback: (device, supported) {

        final selected = locale.flutterLocale;

        if (device == null) return selected;

        for (final l in supported) {

          if (l.languageCode == device.languageCode) return l;

        }

        return selected;

      },

      routerConfig: router,

      builder: (context, child) {

        final shell = child ?? const SizedBox.shrink();

        if (kIsWeb) {

          return _WebAppShell(child: shell);

        }

        return _AppShellOverlay(child: shell);

      },

    );

  }

}



/// Web: no boot overlay, no ink hover — avoids MouseTracker assertion loops.

class _WebAppShell extends StatelessWidget {

  const _WebAppShell({required this.child});



  final Widget child;



  @override

  Widget build(BuildContext context) {

    return Theme(

      data: Theme.of(context).copyWith(

        splashFactory: NoSplash.splashFactory,

        highlightColor: Colors.transparent,

        hoverColor: Colors.transparent,

      ),

      child: Stack(

        fit: StackFit.expand,

        children: [

          L10nDevBanner(child: RepaintBoundary(child: child)),

          const AppServicesBootstrap(),

        ],

      ),

    );

  }

}



/// Desktop/mobile: boot splash overlay while session restores.

class _AppShellOverlay extends ConsumerWidget {

  const _AppShellOverlay({required this.child});



  final Widget child;



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final sessionReady = ref.watch(sessionProvider.select((s) => s.isReady));



    return Stack(

      fit: StackFit.expand,

      children: [

        L10nDevBanner(

          child: PerformanceHud(

            child: RepaintBoundary(child: child),

          ),

        ),

        _BootSplash(visible: !sessionReady),

        const AppServicesBootstrap(),

      ],

    );

  }

}



/// Stays in the tree (opacity + ignore pointer) — removing it on web trips MouseTracker.

class _BootSplash extends StatelessWidget {

  const _BootSplash({required this.visible});



  final bool visible;



  @override

  Widget build(BuildContext context) {

    return Positioned.fill(

      child: IgnorePointer(

        ignoring: !visible,

        child: Opacity(

          opacity: visible ? 1 : 0,

          child: ColoredBox(

            color: Theme.of(context).scaffoldBackgroundColor,

            child: const SafeArea(

              child: Padding(

                padding: EdgeInsets.all(20),

                child: DashboardSkeleton(),

              ),

            ),

          ),

        ),

      ),

    );

  }

}


