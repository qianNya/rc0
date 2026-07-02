import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

class RuntimeAssetApi {
  Future<Map<String, dynamic>> optimizeAsset({
    required String sourceUrl,
    String targetFormat = 'gltf',
    String textureFormat = 'ktx2',
  }) async {
    final uri = Uri.parse('${ApiConfig.serverHost}/v1/assets/optimize');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'source_url': sourceUrl,
        'target_format': targetFormat,
        'texture_format': textureFormat,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
