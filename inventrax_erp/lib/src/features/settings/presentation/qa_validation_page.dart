import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/env_config.dart';
import '../../../core/store_context.dart';
import '../../../data/local/db_provider.dart';
import '../../../qa/qa_check.dart';
import '../../../qa/qa_runner.dart';
import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/layout/app_shell.dart';
import '../../users/domain/app_permission.dart';

class _QaRunNotifier extends AsyncNotifier<QaRunReport?> {
  @override
  Future<QaRunReport?> build() async => null;

  Future<void> run() async {
    state = const AsyncLoading();
    try {
      final db = ref.read(appDatabaseProvider);
      final report = await QaRunner(db).runAll();
      state = AsyncData(report);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final qaRunProvider =
    AsyncNotifierProvider.autoDispose<_QaRunNotifier, QaRunReport?>(
  _QaRunNotifier.new,
);

class QaValidationPage extends ConsumerWidget {
  const QaValidationPage({super.key});

  static const _manualChecks = [
    ('POS', [
      'Rapid barcode scans (50+ in a row)',
      'Checkout while offline, then reconnect',
      'Partial payment + debt creation',
      'Void sale restores stock',
      'Partial refund restores stock',
    ]),
    ('Sync & offline', [
      'Kill network mid-checkout — sale saved locally',
      'Force-close app with pending queue — recovers on reopen',
      'Two devices: sale on A appears on B after sync',
      'No duplicate stock deduction on same sale',
    ]),
    ('Long session', [
      'POS open 2+ hours — memory stable, 60 FPS',
      'SQLite file size reasonable after session',
      'Sync queue drains when online',
    ]),
    ('Security', [
      'Staff role cannot access settings/health',
      'RLS blocks cross-tenant reads (Supabase)',
    ]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!StoreContext.can(AppPermission.systemHealthView) &&
        !StoreContext.isStoreOwner) {
      return const AppShell(
        title: 'QA validation',
        child: Center(child: Text('Access denied')),
      );
    }

    final run = ref.watch(qaRunProvider);

    return AppShell(
      title: 'QA validation',
      subtitle: kDebugMode ? 'Debug build' : 'Production checks',
      actions: [
        AppButton(
          label: 'Run automated checks',
          icon: Icons.play_arrow_rounded,
          onPressed: () => ref.read(qaRunProvider.notifier).run(),
        ),
        const SizedBox(width: 8),
      ],
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enterprise validation phase',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Run automated integrity and performance checks on this device. '
                  'Use the manual checklist before production rollout.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => context.push('/settings/health'),
                  icon: const Icon(Icons.monitor_heart_outlined, size: 18),
                  label: const Text('Open system health'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (EnvConfig.sentryDsn.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sentry monitoring',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Project flutter · org ktsnove. After tapping verify, open your '
                    'Sentry dashboard — the event may take a few seconds.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      throw StateError('This is test exception');
                    },
                    child: const Text('Verify Sentry Setup'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          run.when(
            data: (report) {
              if (report == null) {
                return AppCard(
                  child: Text(
                    'Tap "Run automated checks" to validate inventory, sync, SQL, and performance on this store.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              return _AutomatedResults(report: report);
            },
            loading: () => const AppCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) => AppCard(
              child: Text('Check run failed: $e'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Manual QA checklist',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          for (final section in _manualChecks)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(section.$1),
                children: [
                  for (final item in section.$2)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_box_outline_blank, size: 20),
                      title: Text(item, style: Theme.of(context).textTheme.bodySmall),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AutomatedResults extends StatelessWidget {
  const _AutomatedResults({required this.report});

  final QaRunReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passColor = Colors.green.shade700;
    final failColor = theme.colorScheme.error;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                report.allPassed ? Icons.verified_outlined : Icons.warning_amber_rounded,
                color: report.allPassed ? passColor : failColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  report.allPassed
                      ? 'All checks passed'
                      : '${report.failCount} check(s) need attention',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${report.duration.inMilliseconds}ms',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...report.checks.map((c) {
            final color = c.passed
                ? passColor
                : c.severity == QaSeverity.critical
                    ? failColor
                    : Colors.orange.shade800;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                c.passed ? Icons.check_circle : Icons.error_outline,
                color: color,
                size: 22,
              ),
              title: Text(c.title),
              subtitle: Text('${c.message}${c.durationMs != null ? ' · ${c.durationMs}ms' : ''}'),
              trailing: Chip(
                label: Text(c.category, style: const TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            );
          }),
        ],
      ),
    );
  }
}
