import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/media/category_product_icons.dart';
import '../../core/media/image_storage_service.dart';
import '../../core/media/picked_image_data.dart';
import 'local_file_image.dart' show buildLocalFileImage;

/// Optional product photo: gallery, camera, or remove.
class ProductImagePickerSection extends StatefulWidget {
  const ProductImagePickerSection({
    super.key,
    this.previewPath,
    this.previewUrl,
    this.categoryIconId,
    this.onCategoryIconChanged,
    this.onImageChanged,
    this.compact = false,
  });

  final String? previewPath;
  final String? previewUrl;
  final String? categoryIconId;
  final ValueChanged<String?>? onCategoryIconChanged;
  final void Function({
    String? localPath,
    Uint8List? imageBytes,
    String? imageUrl,
    String? thumbnailUrl,
    bool clearImage,
  })? onImageChanged;
  final bool compact;

  @override
  State<ProductImagePickerSection> createState() =>
      _ProductImagePickerSectionState();
}

class _ProductImagePickerSectionState extends State<ProductImagePickerSection> {
  final _picker = ImagePicker();
  String? _localPath;
  Uint8List? _previewBytes;
  String? _remoteUrl;
  String? _iconId;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _localPath = widget.previewPath;
    _remoteUrl = widget.previewUrl;
    _iconId = widget.categoryIconId;
  }

  @override
  void didUpdateWidget(ProductImagePickerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.previewPath != widget.previewPath) {
      _localPath = widget.previewPath;
      _previewBytes = null;
    }
    if (oldWidget.previewUrl != widget.previewUrl) {
      _remoteUrl = widget.previewUrl;
    }
    if (oldWidget.categoryIconId != widget.categoryIconId) {
      _iconId = widget.categoryIconId;
    }
  }

  bool get _hasPreview =>
      _previewBytes != null ||
      (_localPath != null && _localPath!.isNotEmpty) ||
      (_remoteUrl != null && _remoteUrl!.isNotEmpty);

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file == null) return;
      final picked = await PickedImageData.fromXFile(file);
      if (picked == null) return;
      setState(() {
        _previewBytes = picked.bytes;
        _localPath = picked.path;
        _remoteUrl = null;
      });
      widget.onImageChanged?.call(
        localPath: picked.path,
        imageBytes: picked.bytes,
        clearImage: false,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _remove() {
    setState(() {
      _localPath = null;
      _previewBytes = null;
      _remoteUrl = null;
    });
    widget.onImageChanged?.call(clearImage: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewSize = widget.compact ? 72.0 : 96.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Product image (optional)',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload a photo or use a category icon — skip anytime.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: previewSize,
                height: previewSize,
                color: theme.colorScheme.surfaceContainerHighest,
                child: _busy
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : _buildPreview(theme, previewSize),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_outlined, size: 18),
                    label: const Text('Upload'),
                  ),
                  if (!kIsWeb)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Camera'),
                    ),
                  if (_hasPreview)
                    TextButton.icon(
                      onPressed: _busy ? null : _remove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Remove'),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (!_hasPreview && widget.onCategoryIconChanged != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _iconId,
            decoration: const InputDecoration(
              labelText: 'Category icon (when no photo)',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Auto (first letter)'),
              ),
              ...CategoryProductIcons.choices.map(
                (c) => DropdownMenuItem<String?>(
                  value: c.id,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 18),
                      const SizedBox(width: 8),
                      Text(c.label),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (v) {
              setState(() => _iconId = v);
              widget.onCategoryIconChanged?.call(v);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPreview(ThemeData theme, double size) {
    if (_previewBytes != null) {
      return Image.memory(
        _previewBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _iconPreview(theme),
      );
    }
    final local = buildLocalFileImage(
      _localPath,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => _iconPreview(theme),
    );
    if (local != null) return local;
    if (_remoteUrl != null && _remoteUrl!.isNotEmpty) {
      return Image.network(
        _remoteUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _iconPreview(theme),
      );
    }
    return _iconPreview(theme);
  }

  Widget _iconPreview(ThemeData theme) {
    final icon = CategoryProductIcons.iconForId(_iconId);
    return Center(
      child: Icon(
        icon,
        size: 36,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Persists picked product image locally and optionally uploads to Supabase.
Future<({
  String? localPath,
  String? imageUrl,
  String? thumbnailUrl,
  bool hasImage,
})> persistProductImage({
  required ImageStorageService storage,
  required String tenantId,
  required String storeId,
  required String productId,
  String? pickedPath,
  Uint8List? imageBytes,
  bool clearImage = false,
}) async {
  if (clearImage) {
    return (localPath: null, imageUrl: null, thumbnailUrl: null, hasImage: false);
  }
  final bytes = await resolvePickedImageBytes(bytes: imageBytes, path: pickedPath);
  if (bytes == null || bytes.isEmpty) {
    return (localPath: null, imageUrl: null, thumbnailUrl: null, hasImage: false);
  }
  final local = await storage.saveProductImageLocal(
    productId: productId,
    bytes: bytes,
  );
  final uploaded = await storage.uploadProductImage(
    tenantId: tenantId,
    storeId: storeId,
    productId: productId,
    bytes: bytes,
  );
  return (
    localPath: local,
    imageUrl: uploaded?.imageUrl,
    thumbnailUrl: uploaded?.thumbnailUrl ?? uploaded?.imageUrl,
    hasImage: uploaded != null || local != null,
  );
}
