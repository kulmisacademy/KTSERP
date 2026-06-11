import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/store_context.dart';
import '../../application/permissions_provider.dart';

/// Hides [child] when the signed-in user lacks [permission].
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  final String permission;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(canPermissionProvider(permission)) ||
        StoreContext.can(permission);
    if (allowed) return child;
    return fallback ?? const SizedBox.shrink();
  }
}
