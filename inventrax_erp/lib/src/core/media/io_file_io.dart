import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<bool> localPathExists(String path) async => File(path).exists();

Future<List<int>?> readLocalBytes(String path) async {
  final f = File(path);
  if (!await f.exists()) return null;
  return f.readAsBytes();
}

Future<List<int>?> fetchUrlBytesIo(String url) async {
  if (kIsWeb) return null;
  try {
    final client = HttpClient();
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close();
    if (res.statusCode != 200) return null;
    return await res.fold<List<int>>(
      <int>[],
      (prev, chunk) => prev..addAll(chunk),
    );
  } catch (_) {
    return null;
  }
}

Future<String?> writeMediaFile(
  String subfolder,
  String filename,
  List<int> bytes,
) async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(base.path, 'inventrax_media', subfolder));
  if (!await dir.exists()) await dir.create(recursive: true);
  final dest = File(p.join(dir.path, filename));
  await dest.writeAsBytes(bytes, flush: true);
  return dest.path;
}
