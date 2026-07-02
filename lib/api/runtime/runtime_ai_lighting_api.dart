import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

class RuntimeAiLightingApi {
  Future<Map<String, dynamic>> suggestLighting({
    required String prompt,
    int? characterId,
    String? sceneId,
  }) async {
    final uri = Uri.parse('${ApiConfig.serverHost}/v1/ai/lighting/suggest');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        if (characterId != null) 'character_id': characterId,
        if (sceneId != null) 'scene_id': sceneId,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
