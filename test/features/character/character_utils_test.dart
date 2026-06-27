import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/character/domain/character_entry.dart';
import 'package:rc0/features/character/domain/character_utils.dart';

CharacterEntry _entry({
  required int id,
  String name = '测试',
  String workTitle = '',
  int workId = 0,
  List<String> aliases = const [],
  String summary = '',
  int sort = 0,
}) {
  return CharacterEntry(
    id: id,
    workId: workId,
    workTitle: workTitle,
    name: name,
    nameOrig: '',
    slug: '',
    gender: 0,
    summary: summary,
    appearance: '',
    personality: '',
    coverUrl: '',
    aliases: aliases,
    sort: sort,
  );
}

void main() {
  group('filterCharactersByCategory', () {
    final items = [
      _entry(id: 1, name: '守岸人', workTitle: '鸣潮', workId: 10, sort: 10),
      _entry(id: 2, name: '荧', workTitle: '原神', workId: 11, sort: 5),
      _entry(id: 3, name: 'OC', workId: 0, aliases: ['JK'], sort: 1),
    ];

    test('全部 returns all items', () {
      expect(filterCharactersByCategory(items, '全部').length, 3);
    });

    test('热门 sorts by sort descending', () {
      final result = filterCharactersByCategory(items, '热门');
      expect(result.first.id, 1);
      expect(result.last.id, 3);
    });

    test('IP category matches workTitle', () {
      final result = filterCharactersByCategory(items, '原神');
      expect(result, hasLength(1));
      expect(result.first.name, '荧');
    });

    test('style category matches aliases', () {
      final result = filterCharactersByCategory(items, 'JK');
      expect(result, hasLength(1));
      expect(result.first.name, 'OC');
    });

    test('原创 matches workId zero', () {
      final result = filterCharactersByCategory(items, '原创');
      expect(result, hasLength(1));
      expect(result.first.name, 'OC');
    });
  });

  group('formatCharacterCount', () {
    test('null shows dash', () {
      expect(formatCharacterCount(null), '—');
    });

    test('formats thousands', () {
      expect(formatCharacterCount(2300), '2.3k');
    });
  });
}
