import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../application/platform_impersonation_service.dart';

/// Shown above store UI while super admin is impersonating a tenant store.
class ImpersonationBanner extends ConsumerWidget {
  const ImpersonationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imp = ref.watch(platformImpersonationProvider);
    if (!imp.active) return const SizedBox.shrink();

    return Material(
      color: const Color(0xFF7C2D12),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.visibility, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Viewing as: ${imp.storeName ?? imp.storeId}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(platformImpersonationProvider.notifier).endImpersonation();
                  if (context.mounted) context.go('/platform/dashboard');
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(context.l10n.platformExitImpersonation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
