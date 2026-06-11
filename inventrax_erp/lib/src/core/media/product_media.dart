import '../../data/local/app_database.dart';
import 'category_product_icons.dart';
import 'io_file.dart';

/// Resolved display source for a product thumbnail.
enum ProductMediaKind { network, file, categoryIcon, initials }

class ProductMedia {
  const ProductMedia({
    required this.kind,
    this.networkUrl,
    this.filePath,
    this.categoryIconId,
    this.initials,
  });

  final ProductMediaKind kind;
  final String? networkUrl;
  final String? filePath;
  final String? categoryIconId;
  final String? initials;

  static ProductMedia fromProduct(Product product) {
    final thumb = product.thumbnailUrl?.trim();
    final full = product.imageUrl?.trim();
    final network = (thumb != null && thumb.isNotEmpty)
        ? thumb
        : (full != null && full.isNotEmpty ? full : null);
    if (network != null) {
      return ProductMedia(kind: ProductMediaKind.network, networkUrl: network);
    }

    final local = product.imagePath?.trim();
    if (local != null && local.isNotEmpty && !local.startsWith('icon:')) {
      if (local.startsWith('http')) {
        return ProductMedia(kind: ProductMediaKind.network, networkUrl: local);
      }
      return ProductMedia(kind: ProductMediaKind.file, filePath: local);
    }

    final iconId = product.categoryIcon?.trim().isNotEmpty == true
        ? product.categoryIcon!.trim()
        : CategoryProductIcons.parseLegacyIconPath(product.imagePath);
    if (iconId != null) {
      return ProductMedia(
        kind: ProductMediaKind.categoryIcon,
        categoryIconId: iconId,
      );
    }

    final name = product.name.trim();
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return ProductMedia(
      kind: ProductMediaKind.initials,
      initials: initial,
    );
  }

  static bool productHasPhoto(Product product) {
    if (product.hasImage) return true;
    final media = fromProduct(product);
    return media.kind == ProductMediaKind.network ||
        media.kind == ProductMediaKind.file;
  }

  static Future<bool> localFileExists(String? path) async {
    if (path == null || path.isEmpty) return false;
    return localPathExists(path);
  }
}
