import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase_config.dart';
import '../sync/supabase_bootstrap.dart';
import 'observability_hub.dart';

/// Lightweight connectivity probe (no extra packages).
class ConnectivityMonitor {
  static Future<bool> checkOnline() async {
    if (kIsWeb) {
      // Web: assume online if Supabase client exists; realtime/sync will fail gracefully.
      return supabaseClient != null;
    }
    try {
      final result = await InternetAddress.lookup('one.one.one.one')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

class ConnectivityController extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    if (!SupabaseConfig.isConfigured) {
      return false;
    }
    Future.microtask(_probe);
    _timer = Timer.periodic(const Duration(seconds: 12), (_) => _probe());
    ref.onDispose(() {
      _timer?.cancel();
    });
    return true;
  }

  Future<void> _probe() async {
    final online = await ConnectivityMonitor.checkOnline();
    ObservabilityHub.instance.setNetwork(online);
    if (state != online) state = online;
  }

  Future<void> refresh() => _probe();
}

final connectivityProvider = NotifierProvider<ConnectivityController, bool>(
  ConnectivityController.new,
);
