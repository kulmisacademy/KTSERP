import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/media/image_storage_service.dart';
import '../../core/media/picked_image_data.dart';
import 'local_file_image.dart';

class StoreLogoPicker extends StatefulWidget {
  const StoreLogoPicker({
    super.key,
    this.localPath,
    this.remoteUrl,
    required this.onChanged,
  });

  final String? localPath;
  final String? remoteUrl;
  final void Function({
    String? localPath,
    String? remoteUrl,
    Uint8List? imageBytes,
    bool clear,
  }) onChanged;

  @override
  State<StoreLogoPicker> createState() => _StoreLogoPickerState();
}

class _StoreLogoPickerState extends State<StoreLogoPicker> {
  final _picker = ImagePicker();
  Uint8List? _previewBytes;
  var _busy = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 88,
      );
      if (file == null) return;
      final picked = await PickedImageData.fromXFile(file);
      if (picked == null) return;
      setState(() => _previewBytes = picked.bytes);
      widget.onChanged(
        localPath: picked.path,
        remoteUrl: null,
        imageBytes: picked.bytes,
        clear: false,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLogo = _previewBytes != null ||
        (widget.localPath?.isNotEmpty ?? false) ||
        (widget.remoteUrl?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: _busy
                    ? const Center(child: CircularProgressIndicator())
                    : _logoPreview(theme),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _busy ? null : () => _pick(ImageSource.gallery),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload logo'),
            ),
            if (!kIsWeb)
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Take photo'),
              ),
            if (hasLogo)
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        setState(() => _previewBytes = null);
                        widget.onChanged(clear: true);
                      },
                child: const Text('Remove logo'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _logoPreview(ThemeData theme) {
    if (_previewBytes != null) {
      return Image.memory(_previewBytes!, fit: BoxFit.cover);
    }
    final fileImg = buildLocalFileImage(
      widget.localPath,
      width: 112,
      height: 112,
      fit: BoxFit.cover,
    );
    if (fileImg != null) return fileImg;
    final remote = widget.remoteUrl;
    if (remote != null && remote.isNotEmpty) {
      return Image.network(
        remote,
        key: ValueKey(remote),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(theme),
      );
    }
    return _placeholder(theme);
  }

  Widget _placeholder(ThemeData theme) {
    return Icon(
      Icons.storefront_outlined,
      size: 48,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
    );
  }
}

Future<({String? localPath, String? logoUrl})> persistStoreLogo({
  required ImageStorageService storage,
  required String tenantId,
  required String storeId,
  String? pickedPath,
  Uint8List? imageBytes,
  bool clear = false,
}) async {
  if (clear) {
    return (localPath: null, logoUrl: null);
  }
  final bytes = await resolvePickedImageBytes(bytes: imageBytes, path: pickedPath);
  if (bytes == null || bytes.isEmpty) {
    return (localPath: null, logoUrl: null);
  }
  final local = await storage.saveStoreLogoLocal(storeId: storeId, bytes: bytes);
  final url = await storage.uploadStoreLogo(
    tenantId: tenantId,
    storeId: storeId,
    bytes: bytes,
  );
  return (localPath: local, logoUrl: url);
}
