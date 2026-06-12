import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/ux/responsive.dart';
import '../application/subscription_lock_provider.dart';

/// Shown when subscription/trial is past grace — billing-only access.
class SubscriptionExpiredPage extends ConsumerWidget {
  const SubscriptionExpiredPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(subscriptionLockProvider);
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: Responsive.pagePadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 72,
                    color: scheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Subscription Required',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lock.message ??
                        'Your subscription has expired. Renew to continue using POS, reports, AI insights, and sync.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.go('/billing'),
                    icon: const Icon(Icons.payment_rounded),
                    label: Text(l10n.subscriptionRenewSubscription),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/billing'),
                    icon: const Icon(Icons.upgrade_rounded),
                    label: Text(l10n.subscriptionUpgradePlan),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/settings'),
                    child: Text(l10n.subscriptionAccountSettings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
