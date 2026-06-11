import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/store/store_branding.dart';
import '../../data/local/app_database.dart';
import '../../data/local/store_settings_provider.dart';
import 'local_file_image.dart';

/// Store logo that refreshes when settings change (cache-busted remote URL).
class BrandedStoreLogo extends ConsumerWidget {
  const BrandedStoreLogo({
    super.key,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider).value;
    return _BrandedStoreLogoBody(
      settings: settings,
      width: width,
      height: height,
      borderRadius: borderRadius,
      fit: fit,
    );
  }
}

class _BrandedStoreLogoBody extends StatelessWidget {
  const _BrandedStoreLogoBody({
    required this.settings,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.fit,
  });

  final StoreSetting? settings;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final local = settings?.logoLocalPath;
    final remote = StoreBranding.logoUrlWithCacheBust(settings);

    final localImg = buildLocalFileImage(
      local,
      width: width,
      height: height,
      fit: fit,
    );
    if (localImg != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: localImg,
      );
    }

    if (remote != null && remote.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          remote,
          key: ValueKey(remote),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(context),
        ),
      );
    }

    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Icon(
      Icons.storefront_outlined,
      size: width * 0.6,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
    );
  }
}
