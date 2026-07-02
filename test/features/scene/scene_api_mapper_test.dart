import 'package:flutter_test/flutter_test.dart';

import 'package:rc0/api/scene/data/scene-api.dart';
import 'package:rc0/features/scene/data/scene_api_mapper.dart';
import 'package:rc0/features/scene/domain/scene_entry.dart';

void main() {
  group('scene_api_mapper', () {
    test('sceneIdFromDto and sceneIdToApi round-trip', () {
      expect(sceneIdFromDto(42), '42');
      expect(sceneIdToApi('42'), 42);
      expect(sceneIdToApi('seed-1'), isNull);
    });

    test('sceneEntryFromDto maps coordinates and id', () {
      final dto = SceneItem.fromJson({
        'id': 7,
        'title': '天台',
        'cover_url': 'https://example.com/cover.jpg',
        'description': '夜景',
        'category': '天台',
        'tags': ['城市'],
        'themes': ['电影感'],
        'image_urls': [],
        'location': '商业大厦',
        'city': '上海',
        'latitude': 31.2304,
        'longitude': 121.4737,
        'shooting_tips': {'最佳时间': '日落后'},
        'favorite_count': 3,
        'use_count': 1,
        'view_count': 10,
        'rating': 4.5,
        'sort': 5,
        'is_seed': false,
        'created_at': '2025-06-30T08:00:00Z',
        'updated_at': '2025-06-30T09:00:00Z',
      });

      final entry = sceneEntryFromDto(dto);
      expect(entry.id, '7');
      expect(entry.latitude, 31.2304);
      expect(entry.longitude, 121.4737);
      expect(sceneHasLocation(entry), isTrue);
    });

    test('sceneWriteBodyFromEntry preserves coordinates', () {
      final entry = SceneEntry(
        id: '9',
        title: '海边',
        coverUrl: '',
        description: '',
        category: '海边',
        tags: [],
        themes: [],
        imageUrls: [],
        location: '礁石',
        city: '厦门',
        latitude: 24.48,
        longitude: 118.09,
        shootingTips: {},
        favoriteCount: 0,
        useCount: 0,
        viewCount: 0,
        rating: 0,
        sort: 0,
        createdAt: DateTime.utc(2025, 6, 30),
        updatedAt: DateTime.utc(2025, 6, 30),
      );

      final body = sceneWriteBodyFromEntry(entry);
      expect(body.latitude, 24.48);
      expect(body.longitude, 118.09);
      expect(body.toJson()['latitude'], 24.48);
    });

    test('apiSortForTab maps UI tabs', () {
      expect(apiSortForTab('热门'), 'hot');
      expect(apiSortForTab('最新'), 'latest');
      expect(apiSortForTab('收藏最多'), isNull);
    });
  });
}
