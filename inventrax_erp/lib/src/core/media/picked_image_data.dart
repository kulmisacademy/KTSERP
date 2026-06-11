import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'io_file.dart';

/// Image bytes from [ImagePicker], with optional filesystem path (mobile/desktop).
class PickedImageData {
  const PickedImageData({
    required this.bytes,
    this.path,
  });

  final Uint8List bytes;
  final String? path;

  static Future<PickedImageData?> fromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    return PickedImageData(bytes: bytes, path: file.path);
  }
}

/// Resolves bytes from in-memory pick or local path.
Future<Uint8List?> resolvePickedImageBytes({
  Uint8List? bytes,
  String? path,
}) async {
  if (bytes != null && bytes.isNotEmpty) return bytes;
  if (path == null || path.isEmpty) return null;
  final fromDisk = await readLocalBytes(path);
  if (fromDisk == null || fromDisk.isEmpty) return null;
  return Uint8List.fromList(fromDisk);
}
