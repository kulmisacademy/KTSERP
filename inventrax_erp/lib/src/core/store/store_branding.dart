import '../../data/local/app_database.dart';
import '../store_context.dart';

/// Single source of truth helpers for store name, logo, and invoice branding.
abstract final class StoreBranding {
  static String displayName(StoreSetting? settings) {
    final name = settings?.storeName.trim();
    if (name != null && name.isNotEmpty && name != 'My Store') return name;
    final ctx = StoreContext.storeName?.trim();
    if (ctx != null && ctx.isNotEmpty && ctx != 'My Store') return ctx;
    return 'My Store';
  }

  /// Busts Flutter/web image cache when logo or settings change.
  static String? logoUrlWithCacheBust(StoreSetting? settings) {
    final url = settings?.logoUrl?.trim();
    if (url == null || url.isEmpty) return null;
    final stamp = settings!.updatedAt.millisecondsSinceEpoch;
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);
    params['v'] = '$stamp';
    return uri.replace(queryParameters: params).toString();
  }

  static String? logoRemoteForLoad(StoreSetting? settings) {
    return logoUrlWithCacheBust(settings) ?? settings?.logoUrl;
  }

  /// Keeps session + sidebar in sync with Drift store_settings.
  static void applyToSession(StoreSetting? settings) {
    if (settings == null) return;
    StoreContext.storeName = settings.storeName;
  }
}
