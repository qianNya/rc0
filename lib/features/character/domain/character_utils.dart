import '../../../core/data/app_catalog.dart';
import '../../screenplay/data/screenplay_local_repository.dart';
import 'character_entry.dart';

String formatCharacterCount(int? value) {
  if (value == null) return '—';
  if (value >= 10000) {
    final w = value / 10000;
    return w >= 10 ? '${w.toInt()}万' : '${w.toStringAsFixed(1)}万';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return k >= 10 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
  }
  return '$value';
}

List<CharacterEntry> filterCharactersByCategory(
  List<CharacterEntry> items,
  String category,
) {
  if (category == '全部') return items;
  if (category == '热门') {
    final sorted = List<CharacterEntry>.from(items)
      ..sort((a, b) => b.sort.compareTo(a.sort));
    return sorted;
  }

  final ipCategories = {
    '原神',
    '崩坏星穹铁道',
    '鸣潮',
    '绝区零',
    '明日方舟',
  };
  if (ipCategories.contains(category)) {
    return items
        .where(
          (e) =>
              e.workTitle.contains(category) ||
              e.name.contains(category) ||
              e.aliases.any((a) => a.contains(category)),
        )
        .toList(growable: false);
  }

  if (category == '原创') {
    return items
        .where((e) => e.workId == 0 || e.workTitle.isEmpty)
        .toList(growable: false);
  }

  return items
      .where(
        (e) =>
            e.aliases.any((a) => a.contains(category)) ||
            e.summary.contains(category) ||
            e.appearance.contains(category),
      )
      .toList(growable: false);
}

/// Wiki 角色库分类筛选（含「推荐」与 IP 简称）。
List<CharacterEntry> filterWikiCharactersByCategory(
  List<CharacterEntry> items,
  String category, {
  int Function(int characterId)? screenplayCountFor,
}) {
  if (category == '推荐') {
    final countFor = screenplayCountFor ?? screenplayCountForCharacter;
    final sorted = List<CharacterEntry>.from(items)
      ..sort(
        (a, b) => countFor(b.id).compareTo(countFor(a.id)),
      );
    return sorted;
  }
  if (category == '星穹铁道') {
    return filterCharactersByCategory(items, '崩坏星穹铁道');
  }
  if (category == '崩坏') {
    return items
        .where((e) => e.workTitle.contains('崩坏'))
        .toList(growable: false);
  }
  return filterCharactersByCategory(items, category);
}

String wikiCharacterSourceTag(CharacterEntry entry) {
  if (entry.workTitle.isNotEmpty) return entry.workTitle;
  if (entry.workId == 0) return '原创';
  return '官方';
}

bool matchesMyCharacterTab(
  CharacterEntry entry,
  int tabIndex, {
  required Set<int> ownedIds,
}) {
  switch (tabIndex) {
    case 0:
      return entry.workId > 0 && entry.workTitle.isNotEmpty;
    case 1:
      return entry.workId == 0 || ownedIds.contains(entry.id);
    case 2:
      return false;
    default:
      return true;
  }
}

int countFramesWithCharacterInTree(Map<String, dynamic> node, int characterId) {
  var count = 0;
  final id = node['acgn_character_id'];
  if (id is num && id.toInt() == characterId) {
    count++;
  }
  for (final value in node.values) {
    if (value is Map<String, dynamic>) {
      count += countFramesWithCharacterInTree(value, characterId);
    } else if (value is List) {
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          count += countFramesWithCharacterInTree(item, characterId);
        }
      }
    }
  }
  return count;
}

List<String> screenplaysForCharacter(int characterId) {
  final repo = ScreenplayLocalRepository.instance;
  final linked = <String>{};

  for (final doc in repo.localScreenplays.map(
    (s) => repo.documentById(s.id),
  )) {
    if (doc == null || doc.meta.browseCache) continue;
    if (countFramesWithCharacterInTree(doc.tree, characterId) > 0) {
      linked.add(doc.meta.localId);
    }
  }

  return linked.toList(growable: false);
}

int screenplayCountForCharacter(int characterId) {
  return screenplaysForCharacter(characterId).length;
}

List<String> characterCategoryOptions() {
  return AppCatalog.characterCategoryChips
      .where((c) => c != '全部' && c != '热门')
      .toList(growable: false);
}
