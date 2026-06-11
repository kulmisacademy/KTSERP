import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_config.dart';
import '../../sync/supabase_bootstrap.dart';
import 'io_file.dart' show fetchUrlBytesIo, readLocalBytes, writeMediaFile;

/// Saves and uploads store logos & product photos (Supabase Storage + local cache).
class ImageStorageService {
  ImageStorageService({SupabaseClient? client})
      : _client = client ?? supabaseClient;

  final SupabaseClient? _client;

  static const storeLogosBucket = 'store-logos';
  static const productImagesBucket = 'product-images';

  static ({String ext, String contentType}) _mimeForBytes(List<int> bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return (ext: 'jpg', contentType: 'image/jpeg');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return (ext: 'png', contentType: 'image/png');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return (ext: 'webp', contentType: 'image/webp');
    }
    return (ext: 'jpg', contentType: 'image/jpeg');
  }

  Future<String?> saveProductImageLocal({
    required String productId,
    required List<int> bytes,
  }) async {
    return writeMediaFile('product_images', '$productId.jpg', bytes);
  }

  Future<String?> saveStoreLogoLocal({
    required String storeId,
    required List<int> bytes,
  }) async {
    return writeMediaFile('store_logos', '$storeId.jpg', bytes);
  }

  Future<({String? imageUrl, String? thumbnailUrl})?> uploadProductImage({
    required String tenantId,
    required String storeId,
    required String productId,
    required List<int> bytes,
  }) async {
    if (!SupabaseConfig.isConfigured || _client == null) return null;
    final mime = _mimeForBytes(bytes);
    final path = '$tenantId/$storeId/$productId.${mime.ext}';
    try {
      await _client.storage.from(productImagesBucket).uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: mime.contentType,
            ),
          );
      final url = _client.storage.from(productImagesBucket).getPublicUrl(path);
      return (imageUrl: url, thumbnailUrl: url);
    } catch (e) {
      if (kDebugMode) debugPrint('Product image upload failed: $e');
      return null;
    }
  }

  Future<String?> uploadStoreLogo({
    required String tenantId,
    required String storeId,
    required List<int> bytes,
  }) async {
    if (!SupabaseConfig.isConfigured || _client == null) return null;
    final mime = _mimeForBytes(bytes);
    final path = '$tenantId/$storeId/logo.${mime.ext}';
    try {
      await _client.storage.from(storeLogosBucket).uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: mime.contentType,
            ),
          );
      final url = _client.storage.from(storeLogosBucket).getPublicUrl(path);
      await _client.from('stores').update({'logo_url': url}).eq('id', storeId);
      return url;
    } catch (e) {
      if (kDebugMode) debugPrint('Store logo upload failed: $e');
      return null;
    }
  }

  static Future<List<int>?> loadLogoBytes({
    String? localPath,
    String? remoteUrl,
  }) async {
    if (localPath != null && localPath.isNotEmpty) {
      final local = await readLocalBytes(localPath);
      if (local != null) return local;
    }
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return fetchUrlBytesIo(remoteUrl);
    }
    return null;
  }
}
