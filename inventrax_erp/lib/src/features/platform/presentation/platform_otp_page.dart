import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../ui/components/app_metric_card.dart';
import '../../auth/application/otp_providers.dart';
import 'widgets/platform_widgets.dart';

class PlatformOtpPage extends ConsumerWidget {
  const PlatformOtpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(platformOtpStatsProvider);

    return ListView(
      children: [
        PlatformPageHeader(
          title: l10n.platformOtpTitle,
          subtitle: l10n.platformOtpSubtitle,
        ),
        stats.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.platformErrorDetail(e.toString())),
          ),
          data: (s) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                AppMetricCard(
                  title: l10n.platformOtpSentToday,
                  value: '${s.sentToday}',
                  icon: Icons.mark_email_read_outlined,
                ),
                AppMetricCard(
                  title: l10n.platformOtpVerifiedToday,
                  value: '${s.verifiedToday}',
                  icon: Icons.verified_user_outlined,
                ),
                AppMetricCard(
                  title: l10n.platformOtpFailedToday,
                  value: '${s.failedToday}',
                  icon: Icons.error_outline,
                ),
                AppMetricCard(
                  title: l10n.platformOtpPending,
                  value: '${s.pending}',
                  icon: Icons.hourglass_top_outlined,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.apps_rounded),
              title: Text(l10n.platformAppBranding),
              subtitle: Text(l10n.platformAppBrandingSubtitle),
            ),
          ),
        ),
      ],
    );
  }
}
