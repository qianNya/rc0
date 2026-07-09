import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../api/character/api/character-api.dart' as character_api;
import '../../../api/character/data/character-api.dart';
import '../../../core/auth/auth_bridge.dart';
import '../../../core/media/app_media_upload_service.dart';
import '../../../core/network/api_callback.dart';
import '../domain/character_detail_data.dart';
import '../domain/character_entry.dart';
import '../domain/character_utils.dart';
import 'character_local_store.dart';

class CharacterRepository extends ChangeNotifier {
  CharacterRepository._();

  static final CharacterRepository instance = CharacterRepository._();

  final List<CharacterEntry> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _pageSize = 20;
  num _total = 0;
  int? _filterWorkId;
  int? _filterTagId;
  String _searchQuery = '';

  List<CharacterEntry> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  num get total => _total;
  int? get filterWorkId => _filterWorkId;
  int? get filterTagId => _filterTagId;
  String get searchQuery => _searchQuery;
  bool get hasMore => _items.length < _total.toInt();

  List<CharacterEntry> filterByCategory(String category) {
    return filterCharactersByCategory(_items, category);
  }

  int countScreenplaysForCharacter(int characterId) {
    return screenplayCountForCharacter(characterId);
  }

  CharacterEntry _fromDto(CharacterItem dto) {
    return CharacterEntry(
      id: dto.id.toInt(),
      workId: dto.workId.toInt(),
      workTitle: dto.workTitle,
      name: dto.name,
      nameOrig: dto.nameOrig,
      slug: dto.slug,
      gender: dto.gender.toInt(),
      summary: dto.summary,
      appearance: dto.appearance,
      personality: dto.personality,
      coverUrl: dto.coverUrl,
      avatarImageId: dto.avatarImageId?.toInt(),
      aliases: List<String>.from(dto.aliases),
      visibility: dto.visibility.toInt(),
      style: CharacterStyle.fromJson(dto.styleJson),
      tags: dto.tags
          .map(
            (t) => CharacterTagRef(
              id: t.id.toInt(),
              name: t.name,
              slug: t.slug,
              namespace: t.namespace,
            ),
          )
          .toList(growable: false),
      sort: dto.sort.toInt(),
    );
  }

  CharacterCostumeItem _costumeFromDto(CostumeItem dto) {
    return CharacterCostumeItem(
      id: dto.id.toInt(),
      name: dto.name,
      coverUrl: dto.coverUrl,
      description: dto.description,
      isDefault: dto.isDefault,
      slug: dto.slug,
    );
  }

  CharacterPropItem _propFromDto(PropItem dto) {
    return CharacterPropItem(
      id: dto.id.toInt(),
      name: dto.name,
      description: dto.description,
      coverUrl: dto.coverUrl,
      ownerType: dto.ownerType.toInt(),
      ownerId: dto.ownerId.toInt(),
    );
  }

  CharacterSceneAffinityItem _affinityFromDto(SceneAffinityItem dto) {
    return CharacterSceneAffinityItem(
      id: dto.id.toInt(),
      sceneId: dto.sceneId.toInt(),
      weight: dto.weight.toInt(),
      note: dto.note,
    );
  }

  CharacterWorkItem _workFromDto(CharacterScreenplayItem dto) {
    return CharacterWorkItem(
      id: dto.id.toString(),
      title: dto.title,
      coverPath: dto.coverUrl,
      kind: dto.kind.toInt(),
      publishStatus: dto.publishStatus.toInt(),
      featured: dto.kind.toInt() == 2,
    );
  }

  CharacterWriteBody _toBody({
    int workId = 0,
    required String name,
    String nameOrig = '',
    String slug = '',
    int gender = 0,
    String summary = '',
    String appearance = '',
    String personality = '',
    String coverUrl = '',
    int? avatarImageId,
    List<String> aliases = const [],
    Map<String, dynamic> styleJson = const {},
    int visibility = 1,
    List<int>? tagIds,
    int sort = 0,
  }) {
    return CharacterWriteBody(
      workId: workId,
      name: name,
      nameOrig: nameOrig,
      slug: slug,
      gender: gender,
      summary: summary,
      appearance: appearance,
      personality: personality,
      coverUrl: coverUrl,
      avatarImageId: avatarImageId,
      aliases: aliases,
      styleJson: styleJson,
      visibility: visibility,
      tagIds: tagIds,
      sort: sort,
    );
  }

  Future<({String url, int? imageId, String? error})> _resolveRemoteUrl(
    String path,
  ) async {
    if (path.isEmpty) return (url: '', imageId: null, error: null);
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return (url: path, imageId: null, error: null);
    }
    if (kIsWeb) return (url: path, imageId: null, error: null);

    final file = File(path);
    if (!file.existsSync()) return (url: '', imageId: null, error: null);

    final result =
        await AppMediaUploadService.instance.uploadLocalFile(file.path);
    if (result.error != null) {
      return (url: '', imageId: null, error: result.error);
    }
    return (
      url: result.result?.displayUrl ?? '',
      imageId: result.result?.imageId,
      error: null,
    );
  }

  Future<void> _linkCoverIfPossible({
    required int characterId,
    required int? imageId,
  }) async {
    if (imageId == null || imageId <= 0) return;
    await apiCallback<Map<String, dynamic>>(
      ({ok, fail, eventually}) => character_api.linkImageCharacter(
        imageId,
        characterId: characterId,
        relationType: 1,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
  }

  /// Upload local reference paths and link as relation_type=3.
  Future<void> uploadAndLinkReferenceImages({
    required int characterId,
    required List<String> localPaths,
  }) async {
    if (!AuthBridge.isLoggedIn || characterId <= 0) return;
    for (final path in localPaths) {
      final trimmed = path.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        continue;
      }
      final resolved = await _resolveRemoteUrl(trimmed);
      final imageId = resolved.imageId;
      if (imageId == null || imageId <= 0) continue;
      await apiCallback<Map<String, dynamic>>(
        ({ok, fail, eventually}) => character_api.linkImageCharacter(
          imageId,
          characterId: characterId,
          relationType: 3,
          ok: ok,
          fail: fail,
          eventually: eventually,
        ),
      );
    }
  }

  Future<void> loadFirstPage({
    int pageSize = 20,
    int? workId,
    String? q,
    int? tagId,
  }) async {
    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    _filterWorkId = workId;
    _filterTagId = tagId;
    _searchQuery = q?.trim() ?? '';
    notifyListeners();

    final result = await _fetchPage(
      page: 1,
      pageSize: pageSize,
      workId: workId,
      q: _searchQuery.isEmpty ? null : _searchQuery,
      tagId: tagId,
    );
    _loading = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items
        ..clear()
        ..addAll(result.items);
      _total = result.total;
      _page = 1;
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
      workId: _filterWorkId,
      q: _searchQuery.isEmpty ? null : _searchQuery,
      tagId: _filterTagId,
    );
    _loadingMore = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items.addAll(result.items);
      _total = result.total;
      _page = nextPage;
    }
    notifyListeners();
  }

  Future<({CharacterEntry? character, String? error})> fetchDetail(
    int id,
  ) async {
    final (resp, error) = await apiCallback<CharacterItem>(
      ({ok, fail, eventually}) => character_api.getCharacter(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (character: null, error: error);
    if (resp == null) return (character: null, error: '角色不存在');
    return (character: _fromDto(resp), error: null);
  }

  Future<({List<CharacterEntry> items, num total, String? error})>
      fetchWorkCharacters({
    required int workId,
    int page = 1,
    int pageSize = 50,
    String? q,
  }) async {
    final (resp, error) = await apiCallback<ListCharactersResp>(
      ({ok, fail, eventually}) => character_api.listWorkCharacters(
        workId,
        page: page,
        pageSize: pageSize,
        q: q,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) {
      return (items: <CharacterEntry>[], total: 0, error: error);
    }
    final items = (resp?.list ?? []).map(_fromDto).toList();
    return (items: items, total: resp?.total ?? 0, error: null);
  }

  Future<({CharacterEntry? character, String? error})> create({
    int workId = 0,
    required String name,
    String nameOrig = '',
    String slug = '',
    int gender = 0,
    String summary = '',
    String appearance = '',
    String personality = '',
    String coverUrl = '',
    int? avatarImageId,
    List<String> aliases = const [],
    Map<String, dynamic> styleJson = const {},
    int visibility = 1,
    List<int>? tagIds,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (character: null, error: '请先登录');
    }

    final resolved = await _resolveRemoteUrl(coverUrl);
    if (resolved.error != null) {
      return (character: null, error: resolved.error);
    }

    final (resp, error) = await apiCallback<CharacterItem>(
      ({ok, fail, eventually}) => character_api.createCharacter(
        body: _toBody(
          workId: workId,
          name: name,
          nameOrig: nameOrig,
          slug: slug,
          gender: gender,
          summary: summary,
          appearance: appearance,
          personality: personality,
          coverUrl: resolved.url,
          avatarImageId: avatarImageId ?? resolved.imageId,
          aliases: aliases,
          styleJson: styleJson,
          visibility: visibility,
          tagIds: tagIds,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return (character: null, error: error);
    if (resp == null) return (character: null, error: '创建失败');

    final entry = _fromDto(resp);
    await CharacterLocalStore.instance.markOwned(entry.id);
    await _linkCoverIfPossible(
      characterId: entry.id,
      imageId: resolved.imageId,
    );
    _items.insert(0, entry);
    _total = _total + 1;
    notifyListeners();
    return (character: entry, error: null);
  }

  Future<({CharacterEntry? character, String? error})> update({
    required int id,
    required int workId,
    required String name,
    String nameOrig = '',
    String slug = '',
    int gender = 0,
    String summary = '',
    String appearance = '',
    String personality = '',
    String coverUrl = '',
    int? avatarImageId,
    List<String> aliases = const [],
    Map<String, dynamic> styleJson = const {},
    int visibility = 1,
    List<int>? tagIds,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (character: null, error: '请先登录');
    }

    final resolved = await _resolveRemoteUrl(coverUrl);
    if (resolved.error != null) {
      return (character: null, error: resolved.error);
    }

    final (resp, error) = await apiCallback<CharacterItem>(
      ({ok, fail, eventually}) => character_api.updateCharacter(
        id,
        body: _toBody(
          workId: workId,
          name: name,
          nameOrig: nameOrig,
          slug: slug,
          gender: gender,
          summary: summary,
          appearance: appearance,
          personality: personality,
          coverUrl: resolved.url,
          avatarImageId: avatarImageId ?? resolved.imageId,
          aliases: aliases,
          styleJson: styleJson,
          visibility: visibility,
          tagIds: tagIds,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return (character: null, error: error);
    if (resp == null) return (character: null, error: '更新失败');

    final entry = _fromDto(resp);
    await _linkCoverIfPossible(
      characterId: entry.id,
      imageId: resolved.imageId,
    );
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = entry;
      notifyListeners();
    }
    return (character: entry, error: null);
  }

  Future<String?> delete(int id) async {
    if (!AuthBridge.isLoggedIn) {
      return '请先登录';
    }

    final (_, error) = await apiCallback<Map<String, dynamic>>(
      ({ok, fail, eventually}) => character_api.deleteCharacter(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return error;

    _items.removeWhere((e) => e.id == id);
    _total = (_total - 1).clamp(0, double.infinity);
    notifyListeners();
    return null;
  }

  Future<({List<CharacterCostumeItem> items, String? error})> listCostumes(
    int characterId,
  ) async {
    final (resp, error) = await apiCallback<List<CostumeItem>>(
      ({ok, fail, eventually}) => character_api.listCostumes(
        characterId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (items: <CharacterCostumeItem>[], error: error);
    return (
      items: (resp ?? []).map(_costumeFromDto).toList(growable: false),
      error: null,
    );
  }

  Future<({CharacterCostumeItem? costume, String? error})> createCostume(
    int characterId, {
    required String name,
    String slug = '',
    String description = '',
    String coverUrl = '',
    bool isDefault = false,
    int sort = 0,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (costume: null, error: '请先登录');
    }
    final resolved = await _resolveRemoteUrl(coverUrl);
    if (resolved.error != null) {
      return (costume: null, error: resolved.error);
    }
    final (resp, error) = await apiCallback<CostumeItem>(
      ({ok, fail, eventually}) => character_api.createCostume(
        characterId,
        body: CostumeWriteBody(
          name: name,
          slug: slug,
          description: description,
          coverUrl: resolved.url,
          coverImageId: resolved.imageId,
          isDefault: isDefault,
          sort: sort,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (costume: null, error: error);
    if (resp == null) return (costume: null, error: '创建服装失败');
    return (costume: _costumeFromDto(resp), error: null);
  }

  Future<({CharacterCostumeItem? costume, String? error})> updateCostume(
    int characterId,
    int costumeId, {
    required String name,
    String slug = '',
    String description = '',
    String coverUrl = '',
    bool isDefault = false,
    int sort = 0,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (costume: null, error: '请先登录');
    }
    final resolved = await _resolveRemoteUrl(coverUrl);
    if (resolved.error != null) {
      return (costume: null, error: resolved.error);
    }
    final (resp, error) = await apiCallback<CostumeItem>(
      ({ok, fail, eventually}) => character_api.updateCostume(
        characterId,
        costumeId,
        body: CostumeWriteBody(
          name: name,
          slug: slug,
          description: description,
          coverUrl: resolved.url,
          coverImageId: resolved.imageId,
          isDefault: isDefault,
          sort: sort,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (costume: null, error: error);
    if (resp == null) return (costume: null, error: '更新服装失败');
    return (costume: _costumeFromDto(resp), error: null);
  }

  Future<String?> deleteCostume(int characterId, int costumeId) async {
    if (!AuthBridge.isLoggedIn) return '请先登录';
    final (_, error) = await apiCallback<Map<String, dynamic>>(
      ({ok, fail, eventually}) => character_api.deleteCostume(
        characterId,
        costumeId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    return error;
  }

  Future<({CharacterCostumeItem? costume, String? error})> setDefaultCostume(
    int characterId,
    int costumeId,
  ) async {
    if (!AuthBridge.isLoggedIn) {
      return (costume: null, error: '请先登录');
    }
    final (resp, error) = await apiCallback<CostumeItem>(
      ({ok, fail, eventually}) => character_api.setDefaultCostume(
        characterId,
        costumeId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (costume: null, error: error);
    if (resp == null) return (costume: null, error: '设置默认服装失败');
    return (costume: _costumeFromDto(resp), error: null);
  }

  Future<({List<CharacterPropItem> items, String? error})> listProps(
    int characterId,
  ) async {
    final (resp, error) = await apiCallback<List<PropItem>>(
      ({ok, fail, eventually}) => character_api.listCharacterProps(
        characterId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (items: <CharacterPropItem>[], error: error);
    return (
      items: (resp ?? []).map(_propFromDto).toList(growable: false),
      error: null,
    );
  }

  Future<({CharacterPropItem? prop, String? error})> createProp(
    int characterId, {
    required String name,
    String description = '',
    String coverUrl = '',
    int sort = 0,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (prop: null, error: '请先登录');
    }
    final resolved = await _resolveRemoteUrl(coverUrl);
    if (resolved.error != null) {
      return (prop: null, error: resolved.error);
    }
    final (resp, error) = await apiCallback<PropItem>(
      ({ok, fail, eventually}) => character_api.createCharacterProp(
        characterId,
        body: PropWriteBody(
          name: name,
          description: description,
          coverUrl: resolved.url,
          coverImageId: resolved.imageId,
          sort: sort,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (prop: null, error: error);
    if (resp == null) return (prop: null, error: '创建道具失败');
    return (prop: _propFromDto(resp), error: null);
  }

  Future<({List<CharacterSceneAffinityItem> items, String? error})>
      listAffinities(int characterId) async {
    final (resp, error) = await apiCallback<List<SceneAffinityItem>>(
      ({ok, fail, eventually}) => character_api.listSceneAffinities(
        characterId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) {
      return (items: <CharacterSceneAffinityItem>[], error: error);
    }
    return (
      items: (resp ?? []).map(_affinityFromDto).toList(growable: false),
      error: null,
    );
  }

  Future<({List<CharacterSceneAffinityItem> items, String? error})>
      replaceAffinities(
    int characterId, {
    required List<SceneAffinityWriteItem> items,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (items: <CharacterSceneAffinityItem>[], error: '请先登录');
    }
    final (resp, error) = await apiCallback<List<SceneAffinityItem>>(
      ({ok, fail, eventually}) => character_api.replaceSceneAffinities(
        characterId,
        items: items,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) {
      return (items: <CharacterSceneAffinityItem>[], error: error);
    }
    return (
      items: (resp ?? []).map(_affinityFromDto).toList(growable: false),
      error: null,
    );
  }

  Future<({List<CharacterWorkItem> items, num total, String? error})>
      listCharacterScreenplays(
    int characterId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final (resp, error) = await apiCallback<ListCharacterScreenplaysResp>(
      ({ok, fail, eventually}) => character_api.listCharacterScreenplays(
        characterId,
        page: page,
        pageSize: pageSize,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) {
      return (items: <CharacterWorkItem>[], total: 0, error: error);
    }
    return (
      items: (resp?.list ?? []).map(_workFromDto).toList(growable: false),
      total: resp?.total ?? 0,
      error: null,
    );
  }

  Future<({List<CastItem> items, String? error})> listScreenplayCast(
    int screenplayId,
  ) async {
    final (resp, error) = await apiCallback<List<CastItem>>(
      ({ok, fail, eventually}) => character_api.listScreenplayCast(
        screenplayId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (items: <CastItem>[], error: error);
    return (items: resp ?? [], error: null);
  }

  Future<({List<CastItem> items, String? error})> replaceScreenplayCast(
    int screenplayId, {
    required List<CastWriteItem> items,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (items: <CastItem>[], error: '请先登录');
    }
    final (resp, error) = await apiCallback<List<CastItem>>(
      ({ok, fail, eventually}) => character_api.replaceScreenplayCast(
        screenplayId,
        items: items,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (items: <CastItem>[], error: error);
    return (items: resp ?? [], error: null);
  }

  /// Best-effort cast sync when a remote screenplay id is available.
  Future<void> syncScreenplayCastBestEffort({
    required int remoteScreenplayId,
    required List<ScreenplayCastLink> links,
  }) async {
    if (remoteScreenplayId <= 0 || !AuthBridge.isLoggedIn) return;
    final items = <CastWriteItem>[];
    for (var i = 0; i < links.length; i++) {
      final link = links[i];
      if (link.characterId <= 0) continue;
      items.add(
        CastWriteItem(
          characterId: link.characterId,
          defaultCostumeId: link.defaultCostumeId,
          billingName: link.billingName,
          sort: i,
        ),
      );
    }
    await replaceScreenplayCast(remoteScreenplayId, items: items);
  }

  Future<({List<CharacterEntry> items, num total, String? error})> _fetchPage({
    required int page,
    required int pageSize,
    int? workId,
    String? q,
    int? tagId,
  }) async {
    final (resp, error) = await apiCallback<ListCharactersResp>(
      ({ok, fail, eventually}) => character_api.listCharacters(
        page: page,
        pageSize: pageSize,
        workId: workId,
        q: q,
        tagId: tagId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (items: <CharacterEntry>[], total: 0, error: error);
    }

    final items = (resp?.list ?? []).map(_fromDto).toList();
    return (items: items, total: resp?.total ?? 0, error: null);
  }
}

class ScreenplayCastLink {
  const ScreenplayCastLink({
    required this.characterId,
    this.billingName = '',
    this.defaultCostumeId,
  });

  final int characterId;
  final String billingName;
  final int? defaultCostumeId;
}
