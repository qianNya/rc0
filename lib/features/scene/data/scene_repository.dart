import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../api/scene/api/scene-api.dart' as scene_api;
import '../../../api/scene/data/scene-api.dart';
import '../../../core/network/api_callback.dart';
import '../../../core/auth/auth_bridge.dart';
import '../../../core/media/app_media_upload_service.dart';
import '../domain/scene_entry.dart';
import '../domain/scene_utils.dart';
import 'scene_api_mapper.dart';
import 'scene_local_store.dart';

class SceneRepository extends ChangeNotifier {
  SceneRepository._();

  static final SceneRepository instance = SceneRepository._();

  final List<SceneEntry> _items = [];
  final List<SceneEntry> _hotItems = [];
  final List<SceneEntry> _mapItems = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _mapLoading = false;
  String? _error;
  String? _mapError;
  String _searchQuery = '';
  String _category = '全部';
  String _sortTab = '热门';
  int _page = 1;
  int _pageSize = 20;
  num _total = 0;
  int _mapLoadGeneration = 0;

  List<SceneEntry> get items => List.unmodifiable(_items);
  List<SceneEntry> get mapItems => List.unmodifiable(_mapItems);
  List<SceneEntry> get hotScenes => List.unmodifiable(_hotItems);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get mapLoading => _mapLoading;
  String? get error => _error;
  String? get mapError => _mapError;
  String get searchQuery => _searchQuery;
  String get category => _category;
  String get sortTab => _sortTab;
  num get total => _total;
  bool get hasMore => _items.length < _total.toInt();

  List<SceneEntry> get filteredItems => _items;

  List<SceneEntry> filterByCategory(String category) {
    return filterScenesByCategory(_items, category);
  }

  String? _categoryParam(String? category) {
    final cat = category ?? _category;
    if (cat == '全部' || cat == '热门') return null;
    return cat;
  }

  String? _sortParam({String? category, String? sortTab}) {
    final cat = category ?? _category;
    if (cat == '热门') return 'hot';
    return apiSortForTab(sortTab ?? _sortTab);
  }

  Future<void> loadFirstPage({
    String? q,
    String? category,
    String? sortTab,
    int pageSize = 20,
  }) async {
    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    _searchQuery = q?.trim() ?? _searchQuery;
    if (category != null) _category = category;
    if (sortTab != null) _sortTab = sortTab;
    notifyListeners();

    final main = _fetchPage(
      page: 1,
      pageSize: pageSize,
      category: _categoryParam(_category),
      q: _searchQuery.isEmpty ? null : _searchQuery,
      sort: _sortParam(),
    );
    final hot = _fetchPage(
      page: 1,
      pageSize: 6,
      sort: 'hot',
    );

    final results = await Future.wait([main, hot]);
    _loading = false;

    final pageResult = results[0];
    final hotResult = results[1];

    if (pageResult.error != null) {
      _error = pageResult.error;
      _items.clear();
      _total = 0;
    } else {
      _items
        ..clear()
        ..addAll(pageResult.items);
      _total = pageResult.total;
      await _applyUseCountOverrides();
    }

    if (hotResult.error == null) {
      _hotItems
        ..clear()
        ..addAll(hotResult.items);
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !hasMore) return;

    _loadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final result = await _fetchPage(
      page: nextPage,
      pageSize: _pageSize,
      category: _categoryParam(_category),
      q: _searchQuery.isEmpty ? null : _searchQuery,
      sort: _sortParam(),
    );

    _loadingMore = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items.addAll(result.items);
      _total = result.total;
      _page = nextPage;
      await _applyUseCountOverrides();
    }
    notifyListeners();
  }

  Future<void> loadMapScenes({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    String? city,
  }) async {
    final generation = ++_mapLoadGeneration;
    _mapLoading = true;
    _mapError = null;
    notifyListeners();

    final result = await _fetchPage(
      page: 1,
      pageSize: 100,
      category: _categoryParam(_category),
      q: _searchQuery.isEmpty ? null : _searchQuery,
      city: city,
      hasLocation: true,
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );

    if (generation != _mapLoadGeneration) return;

    _mapLoading = false;
    if (result.error != null) {
      _mapError = result.error;
      _mapItems.clear();
    } else {
      _mapItems
        ..clear()
        ..addAll(result.items);
      await _applyUseCountOverridesFor(_mapItems);
    }
    notifyListeners();
  }

  Future<void> ensureScenesInCache(Iterable<String> ids) async {
    var changed = false;
    for (final id in ids) {
      if (_items.any((e) => e.id == id)) continue;
      final result = await fetchDetail(id);
      if (result.scene != null) {
        _items.add(result.scene!);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  Future<void> _applyUseCountOverrides() async {
    await _applyUseCountOverridesFor(_items);
  }

  Future<void> _applyUseCountOverridesFor(List<SceneEntry> target) async {
    for (var i = 0; i < target.length; i++) {
      final entry = target[i];
      final extra = await SceneLocalStore.instance.extraUseCount(entry.id);
      if (extra > 0) {
        target[i] = entry.copyWith(useCount: entry.useCount + extra);
      }
    }
  }

  Future<({SceneEntry? scene, String? error})> fetchDetail(String id) async {
    final apiId = sceneIdToApi(id);
    if (apiId == null) return (scene: null, error: '场景不存在');

    final cached = _items.where((e) => e.id == id).firstOrNull;
    if (cached != null) return (scene: cached, error: null);

    final (resp, error) = await apiCallback<SceneItem>(
      ({ok, fail, eventually}) => scene_api.getScene(
        apiId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (scene: null, error: error);
    if (resp == null) return (scene: null, error: '场景不存在');

    final entry = sceneEntryFromDto(resp);
    final extra = await SceneLocalStore.instance.extraUseCount(entry.id);
    final withUse = extra > 0
        ? entry.copyWith(useCount: entry.useCount + extra)
        : entry;
    return (scene: withUse, error: null);
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
    _bumpUseCountInList(_items, id);
    _bumpUseCountInList(_hotItems, id);
    _bumpUseCountInList(_mapItems, id);
    notifyListeners();
  }

  void _bumpUseCountInList(List<SceneEntry> list, String id) {
    final index = list.indexWhere((e) => e.id == id);
    if (index >= 0) {
      final entry = list[index];
      list[index] = entry.copyWith(useCount: entry.useCount + 1);
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
    double? latitude,
    double? longitude,
    Map<String, String> shootingTips = const {},
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (scene: null, error: '请先登录');
    }

    final resolvedCover = await _resolveRemoteUrl(coverUrl);
    if (resolvedCover.error != null) {
      return (scene: null, error: resolvedCover.error);
    }
    final resolvedImages = await _resolveRemoteUrls(imageUrls);
    if (resolvedImages.error != null) {
      return (scene: null, error: resolvedImages.error);
    }

    final (resp, error) = await apiCallback<SceneItem>(
      ({ok, fail, eventually}) => scene_api.createScene(
        body: SceneWriteBody(
          title: title,
          coverUrl: resolvedCover.url ?? '',
          description: description,
          category: category,
          tags: tags,
          themes: themes,
          imageUrls: resolvedImages.urls,
          location: location,
          city: city,
          latitude: latitude,
          longitude: longitude,
          shootingTips: shootingTips,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return (scene: null, error: error);
    if (resp == null) return (scene: null, error: '创建失败');

    final entry = sceneEntryFromDto(resp);
    await SceneLocalStore.instance.markOwned(entry.id);
    _items.insert(0, entry);
    _total = _total + 1;
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
    double? latitude,
    double? longitude,
    Map<String, String> shootingTips = const {},
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (scene: null, error: '请先登录');
    }

    final apiId = sceneIdToApi(id);
    if (apiId == null) return (scene: null, error: '场景不存在');

    final existing = _items.where((e) => e.id == id).firstOrNull;
    if (existing?.isSeed == true) {
      return (scene: null, error: '官方场景不可编辑');
    }

    final resolvedCover = await _resolveRemoteUrl(coverUrl);
    if (resolvedCover.error != null) {
      return (scene: null, error: resolvedCover.error);
    }
    final resolvedImages = await _resolveRemoteUrls(imageUrls);
    if (resolvedImages.error != null) {
      return (scene: null, error: resolvedImages.error);
    }

    final (resp, error) = await apiCallback<SceneItem>(
      ({ok, fail, eventually}) => scene_api.updateScene(
        apiId,
        body: SceneWriteBody(
          title: title,
          coverUrl: resolvedCover.url ?? '',
          description: description,
          category: category,
          tags: tags,
          themes: themes,
          imageUrls: resolvedImages.urls,
          location: location,
          city: city,
          latitude: latitude,
          longitude: longitude,
          shootingTips: shootingTips,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return (scene: null, error: error);
    if (resp == null) return (scene: null, error: '更新失败');

    final entry = sceneEntryFromDto(resp);
    _replaceInCaches(entry);
    notifyListeners();
    return (scene: entry, error: null);
  }

  Future<String?> delete(String id) async {
    if (!AuthBridge.isLoggedIn) {
      return '请先登录';
    }

    final apiId = sceneIdToApi(id);
    if (apiId == null) return '场景不存在';

    final existing = _items.where((e) => e.id == id).firstOrNull;
    if (existing?.isSeed == true) return '官方场景不可删除';

    final (_, error) = await apiCallback<Map<String, dynamic>>(
      ({ok, fail, eventually}) => scene_api.deleteScene(
        apiId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return error;

    _items.removeWhere((e) => e.id == id);
    _hotItems.removeWhere((e) => e.id == id);
    _mapItems.removeWhere((e) => e.id == id);
    _total = (_total - 1).clamp(0, double.infinity);
    notifyListeners();
    return null;
  }

  void _replaceInCaches(SceneEntry entry) {
    for (final list in [_items, _hotItems, _mapItems]) {
      final index = list.indexWhere((e) => e.id == entry.id);
      if (index >= 0) list[index] = entry;
    }
  }

  Future<({String? url, String? error})> _resolveRemoteUrl(String path) async {
    if (path.isEmpty) return (url: '', error: null);
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return (url: path, error: null);
    }
    if (kIsWeb) return (url: path, error: null);

    final file = File(path);
    if (!file.existsSync()) return (url: '', error: null);

    final result = await AppMediaUploadService.instance.uploadLocalFile(file.path);
    if (result.error != null) return (url: null, error: result.error);
    return (url: result.result?.displayUrl ?? '', error: null);
  }

  Future<({List<String> urls, String? error})> _resolveRemoteUrls(
    List<String> paths,
  ) async {
    final urls = <String>[];
    for (final path in paths) {
      final resolved = await _resolveRemoteUrl(path);
      if (resolved.error != null) {
        return (urls: <String>[], error: resolved.error);
      }
      if (resolved.url != null && resolved.url!.isNotEmpty) {
        urls.add(resolved.url!);
      }
    }
    return (urls: urls, error: null);
  }

  Future<({List<SceneEntry> items, num total, String? error})> _fetchPage({
    required int page,
    required int pageSize,
    String? category,
    String? q,
    String? city,
    String? sort,
    bool hasLocation = false,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
  }) async {
    final (resp, error) = await apiCallback<ListScenesResp>(
      ({ok, fail, eventually}) => scene_api.listScenes(
        page: page,
        pageSize: pageSize,
        category: category,
        q: q,
        city: city,
        sort: sort,
        hasLocation: hasLocation ? true : null,
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (items: <SceneEntry>[], total: 0, error: error);
    }

    final items = (resp?.list ?? []).map(sceneEntryFromDto).toList();
    return (items: items, total: resp?.total ?? 0, error: null);
  }

  int countScreenplaysForScene(String sceneLibraryId) {
    return screenplaysForScene(sceneLibraryId).length;
  }
}
