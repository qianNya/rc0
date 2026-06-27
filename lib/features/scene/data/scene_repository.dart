import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/scene_entry.dart';
import '../domain/scene_utils.dart';
import 'scene_local_store.dart';
import 'scene_seed_catalog.dart';

class SceneRepository extends ChangeNotifier {
  SceneRepository._();

  static final SceneRepository instance = SceneRepository._();

  final List<SceneEntry> _items = [];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  String _category = '全部';
  String _sortTab = '热门';
  bool _initialized = false;

  List<SceneEntry> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get category => _category;
  String get sortTab => _sortTab;

  List<SceneEntry> get hotScenes {
    final sorted = List<SceneEntry>.from(_items)
      ..sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
    return sorted.take(6).toList(growable: false);
  }

  Future<void> _ensureLoaded() async {
    if (_initialized) return;
    await _loadFromStorage();
    _initialized = true;
  }

  Future<void> _loadFromStorage() async {
    final seeds = SceneSeedCatalog.seeds;
    final userJson = await SceneLocalStore.instance.loadUserEntriesJson();
    final userEntries = <SceneEntry>[];
    if (userJson != null && userJson.isNotEmpty) {
      final decoded = jsonDecode(userJson);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            userEntries.add(SceneEntry.fromJson(item));
          }
        }
      }
    }

    _items
      ..clear()
      ..addAll(seeds)
      ..addAll(userEntries);

    await _applyUseCountOverrides();
  }

  Future<void> _applyUseCountOverrides() async {
    for (var i = 0; i < _items.length; i++) {
      final entry = _items[i];
      final extra = await SceneLocalStore.instance.extraUseCount(entry.id);
      if (extra > 0) {
        _items[i] = entry.copyWith(useCount: entry.useCount + extra);
      }
    }
  }

  Future<void> _persistUserEntries() async {
    final userEntries =
        _items.where((e) => !e.isSeed).map((e) => e.toJson()).toList();
    await SceneLocalStore.instance.saveUserEntriesJson(jsonEncode(userEntries));
  }

  List<SceneEntry> _applyFilters(List<SceneEntry> source) {
    var result = filterScenesByCategory(source, _category);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q) ||
                e.location.toLowerCase().contains(q) ||
                e.tags.any((t) => t.toLowerCase().contains(q)) ||
                e.themes.any((t) => t.toLowerCase().contains(q)),
          )
          .toList(growable: false);
    }
    return sortScenesByTab(result, _sortTab);
  }

  Future<void> loadFirstPage({String? q, String? category, String? sortTab}) async {
    _loading = true;
    _error = null;
    _searchQuery = q?.trim() ?? _searchQuery;
    if (category != null) _category = category;
    if (sortTab != null) _sortTab = sortTab;
    notifyListeners();

    try {
      await _ensureLoaded();
      _loading = false;
    } catch (e) {
      _loading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  List<SceneEntry> get filteredItems => _applyFilters(_items);

  Future<SceneEntry?> fetchDetail(String id) async {
    await _ensureLoaded();
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<SceneEntry> relatedScenes(String id, {int limit = 8}) {
    final entry = _items.where((e) => e.id == id).firstOrNull;
    if (entry == null) return const [];

    final scored = <({SceneEntry entry, int score})>[];
    for (final other in _items) {
      if (other.id == id) continue;
      var score = 0;
      if (other.category == entry.category) score += 3;
      for (final tag in other.tags) {
        if (entry.tags.contains(tag)) score += 2;
      }
      for (final theme in other.themes) {
        if (entry.themes.contains(theme)) score += 1;
      }
      if (score > 0) scored.add((entry: other, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((e) => e.entry).toList(growable: false);
  }

  Future<void> incrementUseCount(String id) async {
    await SceneLocalStore.instance.incrementUseCount(id);
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      final entry = _items[index];
      _items[index] = entry.copyWith(useCount: entry.useCount + 1);
      notifyListeners();
    }
  }

  Future<({SceneEntry? scene, String? error})> create({
    required String title,
    String coverUrl = '',
    String description = '',
    String category = '',
    List<String> tags = const [],
    List<String> themes = const [],
    List<String> imageUrls = const [],
    String location = '',
    String city = '',
    Map<String, String> shootingTips = const {},
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (scene: null, error: '请先登录');
    }

    await _ensureLoaded();
    final now = DateTime.now();
    final id = 'scene-${now.millisecondsSinceEpoch}';
    final entry = SceneEntry(
      id: id,
      title: title,
      coverUrl: coverUrl,
      description: description,
      category: category,
      tags: tags,
      themes: themes,
      imageUrls: imageUrls,
      location: location,
      city: city,
      shootingTips: shootingTips,
      favoriteCount: 0,
      useCount: 0,
      viewCount: 0,
      rating: 0,
      sort: 0,
      createdAt: now,
      updatedAt: now,
      isSeed: false,
    );

    _items.insert(0, entry);
    await SceneLocalStore.instance.markOwned(id);
    await _persistUserEntries();
    notifyListeners();
    return (scene: entry, error: null);
  }

  Future<({SceneEntry? scene, String? error})> update({
    required String id,
    required String title,
    String coverUrl = '',
    String description = '',
    String category = '',
    List<String> tags = const [],
    List<String> themes = const [],
    List<String> imageUrls = const [],
    String location = '',
    String city = '',
    Map<String, String> shootingTips = const {},
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (scene: null, error: '请先登录');
    }

    await _ensureLoaded();
    final index = _items.indexWhere((e) => e.id == id);
    if (index < 0) return (scene: null, error: '场景不存在');
    final existing = _items[index];
    if (existing.isSeed) return (scene: null, error: '官方场景不可编辑');

    final entry = existing.copyWith(
      title: title,
      coverUrl: coverUrl,
      description: description,
      category: category,
      tags: tags,
      themes: themes,
      imageUrls: imageUrls,
      location: location,
      city: city,
      shootingTips: shootingTips,
      updatedAt: DateTime.now(),
    );
    _items[index] = entry;
    await _persistUserEntries();
    notifyListeners();
    return (scene: entry, error: null);
  }

  Future<String?> delete(String id) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return '请先登录';
    }

    await _ensureLoaded();
    final existing = _items.where((e) => e.id == id).firstOrNull;
    if (existing == null) return '场景不存在';
    if (existing.isSeed) return '官方场景不可删除';

    _items.removeWhere((e) => e.id == id);
    await _persistUserEntries();
    notifyListeners();
    return null;
  }

  int countScreenplaysForScene(String sceneLibraryId) {
    return screenplaysForScene(sceneLibraryId).length;
  }
}
