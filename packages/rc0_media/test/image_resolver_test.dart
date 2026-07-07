import 'package:flutter_test/flutter_test.dart';
import 'package:rc0_core/rc0_core.dart';
import 'package:rc0_media/rc0_media.dart';

void main() {
  group('ImageResolver', () {
    test('displayPath prefers local when allowed', () {
      const ref = ImageRef(
        remoteUrl: 'https://cdn.example/a.webp',
        localPath: '/tmp/local.webp',
      );

      expect(
        ImageResolver.displayPath(ref: ref),
        '/tmp/local.webp',
      );
    });

    test('frameDisplayRemoteUrl falls back to thumbnail', () {
      final url = ImageResolver.frameDisplayRemoteUrl({
        'thumbnail_url': 'https://cdn.example/thumb.webp',
      });

      expect(url, 'https://cdn.example/thumb.webp');
    });

    test('resolveNetworkImageUrl repairs legacy host', () {
      expect(
        resolveNetworkImageUrl('https://112.74.176.124:9090/idea/x.webp'),
        'https://112.74.176.124:9090/idea/x.webp',
      );
    });
  });
}
