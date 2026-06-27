import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/scene/domain/scene_entry.dart';
import 'package:rc0/features/scene/domain/scene_utils.dart';

SceneEntry _entry({
  required String id,
  String title = '测试场景',
  String category = '海边',
  List<String> tags = const [],
  List<String> themes = const [],
  int favoriteCount = 0,
  int useCount = 0,
  int viewCount = 0,
  int sort = 0,
}) {
  final now = DateTime.now();
  return SceneEntry(
    id: id,
    title: title,
    coverUrl: '',
    description: '',
    category: category,
    tags: tags,
    themes: themes,
    imageUrls: const [],
    location: '',
    city: '',
    shootingTips: const {},
    favoriteCount: favoriteCount,
    useCount: useCount,
    viewCount: viewCount,
    rating: 0,
    sort: sort,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('filterScenesByCategory', () {
    final items = [
      _entry(
        id: '1',
        title: '海边礁石',
        category: '海边',
        tags: ['自然风光'],
        favoriteCount: 100,
        sort: 10,
      ),
      _entry(
        id: '2',
        title: '樱花小径',
        category: '自然风光',
        tags: ['樱花'],
        favoriteCount: 50,
        sort: 5,
      ),
      _entry(
        id: '3',
        title: '校园操场',
        category: '校园',
        themes: ['JK'],
        favoriteCount: 20,
        sort: 1,
      ),
    ];

    test('全部 returns all items', () {
      expect(filterScenesByCategory(items, '全部').length, 3);
    });

    test('热门 sorts by favoriteCount descending', () {
      final result = filterScenesByCategory(items, '热门');
      expect(result.first.id, '1');
      expect(result.last.id, '3');
    });

    test('category matches category field', () {
      final result = filterScenesByCategory(items, '校园');
      expect(result, hasLength(1));
      expect(result.first.title, '校园操场');
    });

    test('theme tag matches themes', () {
      final result = filterScenesByCategory(items, 'JK');
      expect(result, hasLength(1));
      expect(result.first.id, '3');
    });
  });

  group('sortScenesByTab', () {
    final items = [
      _entry(id: 'a', useCount: 10, viewCount: 100, favoriteCount: 5),
      _entry(id: 'b', useCount: 20, viewCount: 50, favoriteCount: 15),
    ];

    test('使用最多 sorts by useCount', () {
      final result = sortScenesByTab(items, '使用最多');
      expect(result.first.id, 'b');
    });

    test('收藏最多 sorts by favoriteCount', () {
      final result = sortScenesByTab(items, '收藏最多');
      expect(result.first.id, 'b');
    });
  });

  group('countScenesWithLibraryIdInTree', () {
    test('finds scene_library_id in nested tree', () {
      final tree = <String, dynamic>{
        'acts': [
          {
            'scenes': [
              {
                'scene': {
                  'scene_library_id': 'seed-coast-rocks',
                  'scene_library_title': '海边礁石',
                },
                'frames': [],
              },
            ],
          },
        ],
      };
      expect(
        countScenesWithLibraryIdInTree(tree, 'seed-coast-rocks'),
        1,
      );
    });
  });

  group('parseTimeOfDayFromTips', () {
    test('maps sunset hints', () {
      expect(
        parseTimeOfDayFromTips({'最佳时间': '日落前1小时'}),
        '黄昏',
      );
    });
  });
}
