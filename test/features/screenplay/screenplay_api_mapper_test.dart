import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/screenplay/data/screenplay_api_mapper.dart';

Map<String, dynamic> _sampleTree({
  int actId = 0,
  int sceneId = 0,
  int frameId = 0,
  String imageUrl = '',
  int? acgnImageId,
}) {
  return {
    'screenplay': {
      'id': 1001,
      'title': 'Test Screenplay',
      'subtitle': '',
      'summary': 'summary',
      'cover_url': '',
    },
    'acts': [
      {
        'act': {
          'id': actId,
          'title': 'Act 1',
          'summary': 'act summary',
          'sort': 1,
        },
        'scenes': [
          {
            'scene': {
              'id': sceneId,
              'title': 'Scene 1',
              'summary': null,
              'location': 'studio',
              'time_of_day': 'day',
              'sort': 1,
            },
            'frames': [
              {
                'id': frameId,
                'title': 'Frame 1',
                'dialogue': 'hello',
                'action_note': null,
                'sort': 1,
                'duration_sec': 3,
                'image_url': imageUrl,
                'thumbnail_url': '',
                'acgn_image_id': acgnImageId,
                'aspect_ratio': '16:9',
                'shot_type': 'wide',
                'extra_params': {},
              },
            ],
          },
        ],
      },
    ],
  };
}

void main() {
  group('buildSaveTreePayload', () {
    test('initial publish uses nested structure without tree wrapper', () {
      final payload = ScreenplayApiMapper.buildSaveTreePayload(
        tree: _sampleTree(),
        visibility: 0,
        refToImageId: const {'frame-0-0-0': 101},
        isRepublish: false,
      );

      expect(payload.containsKey('tree'), isFalse);
      expect(payload['screenplay'], isA<Map<String, dynamic>>());
      expect(payload['acts'], isA<List>());

      final act = (payload['acts'] as List).first as Map<String, dynamic>;
      expect(act.containsKey('act'), isTrue);
      expect(act.containsKey('scenes'), isTrue);
      expect((act['act'] as Map)['id'], isNull);

      final scene = (act['scenes'] as List).first as Map<String, dynamic>;
      expect(scene.containsKey('scene'), isTrue);
      expect(scene.containsKey('frames'), isTrue);

      final frame = (scene['frames'] as List).first as Map<String, dynamic>;
      expect(frame['image_ref'], 'frame-0-0-0');
      expect(frame['id'], isNull);

      final assetMap = payload['asset_map'] as Map<String, dynamic>;
      expect(assetMap['frame-0-0-0']['remote_image_id'], 101);
    });

    test('republish keeps remote ids', () {
      final payload = ScreenplayApiMapper.buildSaveTreePayload(
        tree: _sampleTree(actId: 11, sceneId: 22, frameId: 33),
        visibility: 1,
        refToImageId: const {},
        isRepublish: true,
      );

      final act = (payload['acts'] as List).first as Map<String, dynamic>;
      expect((act['act'] as Map)['id'], 11);

      final scene = (act['scenes'] as List).first as Map<String, dynamic>;
      expect((scene['scene'] as Map)['id'], 22);

      final frame = (scene['frames'] as List).first as Map<String, dynamic>;
      expect(frame['id'], 33);
      expect((payload['screenplay'] as Map)['visibility'], 1);
    });

    test('existing remote frame uses image_url channel', () {
      final payload = ScreenplayApiMapper.buildSaveTreePayload(
        tree: _sampleTree(
          actId: 1,
          sceneId: 2,
          frameId: 3,
          imageUrl: 'https://cdn.example.com/frame.jpg',
          acgnImageId: 55,
        ),
        visibility: 0,
        refToImageId: const {},
        isRepublish: true,
      );

      final frame = (((payload['acts'] as List).first as Map)['scenes']
              as List)
          .first['frames'][0] as Map<String, dynamic>;

      expect(frame['image_url'], 'https://cdn.example.com/frame.jpg');
      expect(frame['acgn_image_id'], 55);
      expect(frame['image_ref'], isNull);
      expect(payload.containsKey('asset_map'), isFalse);
    });

    test('cover url is included when provided', () {
      final payload = ScreenplayApiMapper.buildSaveTreePayload(
        tree: _sampleTree(),
        visibility: 0,
        refToImageId: const {},
        isRepublish: false,
        coverUrl: 'https://cdn.example.com/cover.jpg',
      );

      expect(
        (payload['screenplay'] as Map)['cover_url'],
        'https://cdn.example.com/cover.jpg',
      );
    });

    test('payload excludes local-only fields from tree input', () {
      final tree = _sampleTree();
      (tree['screenplay'] as Map<String, dynamic>)['local_cover_path'] =
          '/tmp/cover.jpg';
      final frame = (((tree['acts'] as List).first as Map)['scenes'] as List)
          .first['frames'][0] as Map<String, dynamic>;
      frame['local_image_path'] = '/tmp/frame.jpg';

      final payload = ScreenplayApiMapper.buildSaveTreePayload(
        tree: tree,
        visibility: 0,
        refToImageId: const {'frame-0-0-0': 9},
        isRepublish: false,
      );

      expect(payload.toString().contains('local_'), isFalse);
    });
  });
}
