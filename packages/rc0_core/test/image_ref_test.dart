import 'package:flutter_test/flutter_test.dart';
import 'package:rc0_core/rc0_core.dart';

void main() {
  group('ImageRef', () {
    test('fromFrameMap reads legacy fields', () {
      final ref = ImageRef.fromFrameMap({
        'acgn_image_id': 'img-1',
        'acgn_image_file_id': 'file-1',
        'image_url': 'https://cdn.example/a.webp',
        'local_image_path': '/tmp/frame.webp',
      });

      expect(ref.imageId, 'img-1');
      expect(ref.fileId, 'file-1');
      expect(ref.remoteUrl, 'https://cdn.example/a.webp');
      expect(ref.localPath, '/tmp/frame.webp');
      expect(ref.isEmpty, isFalse);
    });

    test('applyToFrameMap dual-writes unified fields', () {
      const ref = ImageRef(
        imageId: 'img-2',
        fileId: 'file-2',
        remoteUrl: 'https://cdn.example/b.webp',
        localPath: '/tmp/cover.webp',
      );

      final frame = ref.applyToFrameMap({});
      expect(frame['acgn_image_id'], 'img-2');
      expect(frame['acgn_image_file_id'], 'file-2');
      expect(frame['image_url'], 'https://cdn.example/b.webp');
      expect(frame['local_image_path'], '/tmp/cover.webp');
    });

    test('round-trips json', () {
      const ref = ImageRef(
        imageId: 'a',
        fileId: 'b',
        remoteUrl: 'https://x/y.webp',
        localPath: '/local/x.webp',
      );

      final decoded = ImageRef.fromJson(ref.toJson());
      expect(decoded, ref);
    });
  });
}
