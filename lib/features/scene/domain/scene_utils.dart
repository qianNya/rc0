import '../../../core/data/app_catalog.dart';
import '../../screenplay/data/screenplay_draft.dart';
import '../../screenplay/data/screenplay_local_repository.dart';
import 'scene_entry.dart';

String formatSceneCount(int? value) {
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

List<SceneEntry> filterScenesByCategory(
  List<SceneEntry> items,
  String category,
) {
  if (category == '全部') return items;
  if (category == '热门') {
    final sorted = List<SceneEntry>.from(items)
      ..sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
    return sorted;
  }

  return items
      .where(
        (e) =>
            e.category == category ||
            e.tags.contains(category) ||
            e.themes.contains(category),
      )
      .toList(growable: false);
}

List<SceneEntry> sortScenesByTab(List<SceneEntry> items, String tab) {
  final sorted = List<SceneEntry>.from(items);
  switch (tab) {
    case '最新':
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case '热门':
      sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    case '收藏最多':
      sorted.sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
    case '使用最多':
      sorted.sort((a, b) => b.useCount.compareTo(a.useCount));
    default:
      sorted.sort((a, b) => b.sort.compareTo(a.sort));
  }
  return sorted;
}

bool matchesMySceneTab(
  SceneEntry entry,
  int tabIndex, {
  required Set<String> favoriteIds,
  required Set<String> ownedIds,
  required Set<String> usedIds,
}) {
  switch (tabIndex) {
    case 0:
      return favoriteIds.contains(entry.id);
    case 1:
      return usedIds.contains(entry.id);
    case 2:
      return ownedIds.contains(entry.id) || !entry.isSeed;
    default:
      return true;
  }
}

bool sceneNodeMatchesLibraryId(Map<String, dynamic> node, String sceneLibraryId) {
  final id = node['scene_library_id'];
  if (id is String && id == sceneLibraryId) return true;
  if (id is num && id.toString() == sceneLibraryId) return true;
  return false;
}

int countScenesWithLibraryIdInTree(
  Map<String, dynamic> node,
  String sceneLibraryId,
) {
  var count = 0;
  if (sceneNodeMatchesLibraryId(node, sceneLibraryId)) {
    count++;
  }
  for (final value in node.values) {
    if (value is Map<String, dynamic>) {
      count += countScenesWithLibraryIdInTree(value, sceneLibraryId);
    } else if (value is List) {
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          count += countScenesWithLibraryIdInTree(item, sceneLibraryId);
        }
      }
    }
  }
  return count;
}

List<String> screenplaysForScene(String sceneLibraryId) {
  final repo = ScreenplayLocalRepository.instance;
  final linked = <String>{};

  for (final doc in repo.localScreenplays.map(
    (s) => repo.documentById(s.id),
  )) {
    if (doc == null || doc.meta.browseCache) continue;

    final screenplayMap = doc.tree['screenplay'] as Map<String, dynamic>?;
    if (screenplayMap != null) {
      final linkedScenesRaw = screenplayMap['linked_scenes'];
      if (linkedScenesRaw is List) {
        for (final item in linkedScenesRaw) {
          if (item is Map<String, dynamic>) {
            final link = ScreenplaySceneLink.fromJson(item);
            if (link.id == sceneLibraryId) {
              linked.add(doc.meta.localId);
              break;
            }
          }
        }
      }
    }

    if (countScenesWithLibraryIdInTree(doc.tree, sceneLibraryId) > 0) {
      linked.add(doc.meta.localId);
    }
  }

  return linked.toList(growable: false);
}

List<String> sceneCategoryOptions() {
  return AppCatalog.sceneCategoryChips
      .where((c) => c != '全部' && c != '热门')
      .toList(growable: false);
}

String? parseTimeOfDayFromTips(Map<String, String> tips) {
  final best = tips['最佳时间'] ?? '';
  if (best.contains('清晨') || best.contains('上午')) return '清晨';
  if (best.contains('下午')) return '下午';
  if (best.contains('日落') || best.contains('傍晚')) return '黄昏';
  if (best.contains('夜景') || best.contains('蓝调') || best.contains('夜')) {
    return '夜晚';
  }
  return null;
}

String? parseWeatherFromTips(Map<String, String> tips) {
  final light = tips['灯光'] ?? '';
  if (light.contains('雾')) return '雾';
  if (light.contains('雨')) return '雨';
  if (light.contains('晴') || light.contains('自然光')) return '晴';
  if (light.contains('阴') || light.contains('柔光')) return '阴';
  return null;
}
