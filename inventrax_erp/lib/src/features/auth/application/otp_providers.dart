import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase_config.dart';
import '../../../sync/supabase_bootstrap.dart';

class PlatformOtpStats {
  const PlatformOtpStats({
    required this.sentToday,
    required this.verifiedToday,
    required this.failedToday,
    required this.pending,
  });

  final int sentToday;
  final int verifiedToday;
  final int failedToday;
  final int pending;

  factory PlatformOtpStats.fromJson(Map<String, dynamic> json) {
    return PlatformOtpStats(
      sentToday: json['sent_today'] as int? ?? 0,
      verifiedToday: json['verified_today'] as int? ?? 0,
      failedToday: json['failed_today'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
    );
  }
}

final platformOtpStatsProvider =
    FutureProvider.autoDispose<PlatformOtpStats>((ref) async {
  if (!SupabaseConfig.isConfigured) {
    return const PlatformOtpStats(
      sentToday: 0,
      verifiedToday: 0,
      failedToday: 0,
      pending: 0,
    );
  }
  final client = supabaseClient;
  if (client == null) {
    throw StateError('Supabase not initialized');
  }
  final raw = await client.rpc('inventrax_platform_email_otp_stats');
  if (raw is Map) {
    return PlatformOtpStats.fromJson(
      raw.map((k, v) => MapEntry(k.toString(), v)),
    );
  }
  return const PlatformOtpStats(
    sentToday: 0,
    verifiedToday: 0,
    failedToday: 0,
    pending: 0,
  );
});
