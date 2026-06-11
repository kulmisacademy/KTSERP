import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/components/app_button.dart';

/// Shown when a signed-in user navigates to a route they lack permission for.
/// Uses a minimal scaffold (not [AppShell]) to avoid layout edge cases.
class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key, this.blockedRoute});

  final String? blockedRoute;

  @override
  Widget build(BuildContext context) {
    final route = blockedRoute?.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Access denied')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Access denied',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  route != null && route.isNotEmpty
                      ? 'You do not have permission to access $route.'
                      : 'You do not have permission to access this page.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Go to dashboard',
                  icon: Icons.home_outlined,
                  onPressed: () => context.go('/dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
