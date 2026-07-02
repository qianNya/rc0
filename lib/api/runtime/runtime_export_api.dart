import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

/// Rust-backed export jobs — Flutter orchestrates, Unity does not call directly.
/// See docs/RUNTIME_3D_RUST_CONTRACTS.md
class RuntimeExportApi {
  Future<Map<String, dynamic>> exportUsd({
    required String sessionId,
    required Map<String, dynamic> sceneSnapshot,
    Map<String, dynamic>? lightingRig,
  }) async {
    final uri = Uri.parse('${ApiConfig.serverHost}/v1/export/usd');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'scene_snapshot': sceneSnapshot,
        if (lightingRig != null) 'lighting_rig': lightingRig,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> exportVideo({
    required String sessionId,
    int fps = 24,
    int durationSec = 5,
    String resolution = '1920x1080',
  }) async {
    final uri = Uri.parse('${ApiConfig.serverHost}/v1/export/video');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'fps': fps,
        'duration_sec': durationSec,
        'resolution': resolution,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
