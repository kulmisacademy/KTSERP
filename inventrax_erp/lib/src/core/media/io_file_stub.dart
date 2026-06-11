import 'package:http/http.dart' as http;

Future<bool> localPathExists(String path) async => false;

Future<List<int>?> readLocalBytes(String path) async => null;

Future<List<int>?> fetchUrlBytesIo(String url) async {
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
      return res.bodyBytes;
    }
  } catch (_) {}
  return null;
}

/// Local media cache (not available on web).
Future<String?> writeMediaFile(
  String subfolder,
  String filename,
  List<int> bytes,
) async =>
    null;
