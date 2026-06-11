import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../components/app_skeleton.dart';
import '../../core/media/category_product_icons.dart';
import '../../core/media/product_media.dart';
import '../../data/local/app_database.dart';
import 'local_file_image.dart';

/// Product avatar: photo, category icon, or initials — works in light/dark mode.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.product,
    this.size = 48,
    this.borderRadius = 10,
    this.showBorder = true,
  });

  final Product product;
  final double size;
  final double borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final media = ProductMedia.fromProduct(product);
    final theme = Theme.of(context);

    Widget child = switch (media.kind) {
      ProductMediaKind.network => ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CachedNetworkImage(
            imageUrl: media.networkUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            memCacheWidth: (size * 2).round(),
            fadeInDuration: const Duration(milliseconds: 220),
            fadeOutDuration: const Duration(milliseconds: 120),
            placeholder: (_, __) => _placeholder(theme),
            errorWidget: (_, __, ___) => _fallback(media, theme),
          ),
        ),
      ProductMediaKind.file => FutureBuilder<bool>(
          future: ProductMedia.localFileExists(media.filePath),
          builder: (context, snap) {
            if (snap.data != true) return _fallback(media, theme);
            final img = buildLocalFileImage(
              media.filePath,
              width: size,
              height: size,
              errorBuilder: (_, __, ___) => _fallback(media, theme),
            );
            return ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: img ?? _fallback(media, theme),
            );
          },
        ),
      _ => _fallback(media, theme),
    };

    if (!showBorder) return SizedBox(width: size, height: size, child: child);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }

  Widget _placeholder(ThemeData theme) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: borderRadius,
    );
  }

  Widget _fallback(ProductMedia media, ThemeData theme) {
    if (media.kind == ProductMediaKind.categoryIcon) {
      return _iconTile(
        CategoryProductIcons.iconForId(media.categoryIconId),
        theme,
      );
    }
    return _iconTile(
      null,
      theme,
      label: media.initials ?? '?',
    );
  }

  Widget _iconTile(IconData? icon, ThemeData theme, {String? label}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            InventraXTheme.primary,
            InventraXTheme.primary.withValues(alpha: 0.75),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: size * 0.42)
          : Text(
              label ?? '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.38,
              ),
            ),
    );
  }
}
