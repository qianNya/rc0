import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../http/network_error.dart';
import '../data/data-api.dart';
import '../vars/kv.dart';
import '../vars/vars.dart';

/// Multipart file upload to POST /api/data/upload.
Future<({UploadResp? resp, String? error})> uploadFile(File file) async {
  try {
    final bytes = await file.readAsBytes();
    final filename = file.path.split(Platform.pathSeparator).last;
    return uploadBytes(bytes, filename);
  } catch (e) {
    return (resp: null, error: friendlyNetworkError(e));
  }
}

/// Multipart upload from in-memory bytes.
Future<({UploadResp? resp, String? error})> uploadBytes(
  Uint8List bytes,
  String filename,
) async {
  final tokens = await getTokens();
  final boundary = '----Rc0Upload${DateTime.now().millisecondsSinceEpoch}';
  final client = HttpClient();

  try {
    final request = await client.postUrl(
      Uri.parse('${serverHost}/api/data/upload'),
    );
    request.headers.set(
      'Content-Type',
      'multipart/form-data; boundary=$boundary',
    );
    if (tokens != null) {
      request.headers.set('Authorization', 'Bearer ${tokens.accessToken}');
    }

    final contentType = _mimeType(filename);
    final header = StringBuffer()
      ..write('--$boundary\r\n')
      ..write(
        'Content-Disposition: form-data; name="file"; filename="$filename"\r\n',
      )
      ..write('Content-Type: $contentType\r\n\r\n');

    final footer = '\r\n--$boundary--\r\n';
    final bodyBytes = <int>[
      ...utf8.encode(header.toString()),
      ...bytes,
      ...utf8.encode(footer),
    ];

    request.contentLength = bodyBytes.length;
    request.add(bodyBytes);

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      return (resp: null, error: '上传失败: HTTP ${response.statusCode}');
    }

    final base = jsonDecode(body) as Map<String, dynamic>;
    if (base['code'] != 0) {
      return (resp: null, error: base['desc'] as String? ?? '上传失败');
    }

    final data = base['data'] as Map<String, dynamic>;
    return (resp: UploadResp.fromJson(data), error: null);
  } catch (e) {
    return (resp: null, error: friendlyNetworkError(e));
  } finally {
    client.close();
  }
}

String _mimeType(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.json')) return 'application/json';
  return 'image/jpeg';
}
