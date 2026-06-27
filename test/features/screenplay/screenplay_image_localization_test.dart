import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/domain/screenplay/screenplay_image_resolver.dart';

void main() {
  test('collects cover and frame remote urls from tree', () {
    final tree = {
      'screenplay': {
        'cover_url': 'https://cdn.example.com/cover.jpg',
      },
      'acts': [
        {
          'scenes': [
            {
              'frames': [
                {'image_url': 'https://cdn.example.com/f0.jpg'},
                {'image_url': 'https://cdn.example.com/f1.jpg'},
              ],
            },
          ],
        },
      ],
    };

    final urls = <String>{};
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
    final cover = ScreenplayImageResolver.coverRemoteUrl(screenplayMap);
    if (cover != null) urls.add(cover);

    final acts = tree['acts'] as List<dynamic>;
    for (final actNode in acts) {
      final scenes = (actNode as Map<String, dynamic>)['scenes'] as List;
      for (final sceneNode in scenes) {
        final frames = (sceneNode as Map)['frames'] as List;
        for (final frame in frames) {
          final remote = ScreenplayImageResolver.frameRemoteUrl(
            frame as Map<String, dynamic>,
          );
          if (remote != null) urls.add(remote);
        }
      }
    }

    expect(urls, {
      'https://cdn.example.com/cover.jpg',
      'https://cdn.example.com/f0.jpg',
      'https://cdn.example.com/f1.jpg',
    });
  });
}
