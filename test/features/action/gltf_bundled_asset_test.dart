import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled aku aku assets are registered', () async {
    final gltf = await rootBundle.load('assets/model/aku_aku/scene.gltf');
    final bin = await rootBundle.load('assets/model/aku_aku/scene.bin');
    expect(gltf.lengthInBytes, greaterThan(0));
    expect(bin.lengthInBytes, greaterThan(0));

    final doc =
        jsonDecode(utf8.decode(gltf.buffer.asUint8List(), allowMalformed: true))
            as Map<String, dynamic>;
    final meshes = doc['meshes'] as List;
    expect(meshes, isNotEmpty);

    final images = doc['images'] as List;
    for (final image in images) {
      final uri = (image as Map<String, dynamic>)['uri'] as String;
      final texture = await rootBundle.load('assets/model/aku_aku/$uri');
      expect(texture.lengthInBytes, greaterThan(0));
    }
  });

  test('bundled yt gltf buffer uri resolves after url decoding', () async {
    final gltf = await rootBundle.load('assets/model/yt/羽蜕-浅憩之处.gltf');
    final doc =
        jsonDecode(utf8.decode(gltf.buffer.asUint8List(), allowMalformed: true))
            as Map<String, dynamic>;
    final buffers = doc['buffers'] as List;
    final uri = (buffers.single as Map<String, dynamic>)['uri'] as String;

    final bin = await rootBundle.load('assets/model/yt/${Uri.decodeFull(uri)}');
    expect(bin.lengthInBytes, greaterThan(0));
  });
}
