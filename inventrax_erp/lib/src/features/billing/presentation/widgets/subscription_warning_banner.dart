import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../application/billing_providers.dart';
import '../../application/subscription_guard.dart';
import '../../application/subscription_lock_provider.dart';

/// Global trial / expiry warning strip (below offline banner).
class SubscriptionWarningBanner extends ConsumerWidget {
  const SubscriptionWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(subscriptionLockProvider);
    if (lock.isLocked) return const SizedBox.shrink();

    final billing = ref.watch(storeBillingProvider);
    return billing.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (snap) {
        if (snap == null) return const SizedBox.shrink();
        final guard = const SubscriptionGuard();
        final scheme = Theme.of(context).colorScheme;
        final l10n = context.l10n;

        if (guard.shouldShowTrialBanner(snap)) {
          final days = snap.subscription.daysRemaining ?? 0;
          return _BannerShell(
            color: scheme.tertiaryContainer,
            onColor: scheme.onTertiaryContainer,
            icon: Icons.schedule_rounded,
            message: l10n.subscriptionTrialEndsIn(days),
            actionLabel: l10n.subscriptionUpgradeNow,
            onAction: () => context.go('/billing'),
          );
        }

        final daysLeft = guard.daysUntilHardLock(snap);
        if (daysLeft != null && daysLeft <= 7 && daysLeft > 0) {
          return _BannerShell(
            color: scheme.errorContainer.withValues(alpha: 0.85),
            onColor: scheme.onErrorContainer,
            icon: Icons.warning_amber_rounded,
            message: l10n.subscriptionExpiresIn(daysLeft),
            actionLabel: l10n.subscriptionRenewNow,
            onAction: () => context.go('/billing'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({
    required this.color,
    required this.onColor,
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final Color color;
  final Color onColor;
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: onColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: onColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: onColor),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
