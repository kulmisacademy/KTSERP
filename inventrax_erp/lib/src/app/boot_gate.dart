import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../core/startup/startup_profiler.dart';
import '../data/local/db_provider.dart';
import '../observability/monitoring_bootstrap.dart';
import '../sync/supabase_bootstrap.dart';
import 'app.dart';

/// Renders a branded splash **immediately** (first frame paints right away),
/// then initializes Supabase + the local DB in the background. The real app is
/// only mounted once those are ready, so heavy startup work never blocks the
/// first paint. This is what kills the long blank/spinner-only startup.
class BootGate extends StatefulWidget {
  const BootGate({super.key});

  @override
  State<BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<BootGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    StartupProfiler.mark('BootGate mounted (first frame imminent)');
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // Independent — run concurrently. The splash covers this window.
      await Future.wait<void>([
        StartupProfiler.track('monitoring init', MonitoringBootstrap.init),
        StartupProfiler.track('supabase init', initSupabaseIfConfigured),
        StartupProfiler.track('db open', openAppDatabase),
      ]);
    } catch (e, st) {
      StartupProfiler.mark('bootstrap error: $e');
      MonitoringService.captureException(e, stackTrace: st, hint: 'bootstrap');
    }
    StartupProfiler.mark('core services ready');
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const _BootSplashApp();
    return SentryWidget(
      child: const ProviderScope(child: InventraXApp()),
    );
  }
}

/// Minimal MaterialApp shown during bootstrap. Visually matches the HTML splash
/// in `web/index.html` (#061426 + teal spinner) for a seamless handoff.
class _BootSplashApp extends StatelessWidget {
  const _BootSplashApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF061426),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SplashMark(),
              SizedBox(height: 22),
              Text(
                'KULMIS ERP',
                style: TextStyle(
                  color: Color(0xFFE6EEF7),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 26),
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1ABC9C)),
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Loading KULMIS ERP…',
                style: TextStyle(
                  color: Color(0x99E6EEF7),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1ABC9C), Color(0xFF0E8E76)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x591ABC9C),
            blurRadius: 40,
            offset: Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'K',
        style: TextStyle(
          color: Color(0xFF06223A),
          fontSize: 42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
