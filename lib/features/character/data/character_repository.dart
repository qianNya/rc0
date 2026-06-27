import 'package:flutter/foundation.dart';

import '../../../api/character/api/character-api.dart' as character_api;
import '../../../api/character/data/character-api.dart';
import '../../../core/network/api_callback.dart';
import '../../auth/data/auth_repository.dart';
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
  String _searchQuery = '';

  List<CharacterEntry> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  num get total => _total;
  int? get filterWorkId => _filterWorkId;
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
      aliases: List<String>.from(dto.aliases),
      sort: dto.sort.toInt(),
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
    List<String> aliases = const [],
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
      aliases: aliases,
      sort: sort,
    );
  }

  Future<void> loadFirstPage({
    int pageSize = 20,
    int? workId,
    String? q,
  }) async {
    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    _filterWorkId = workId;
    _searchQuery = q?.trim() ?? '';
    notifyListeners();

    final result = await _fetchPage(
      page: 1,
      pageSize: pageSize,
      workId: workId,
      q: _searchQuery.isEmpty ? null : _searchQuery,
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
    List<String> aliases = const [],
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (character: null, error: '请先登录');
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
          aliases: aliases,
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
    List<String> aliases = const [],
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (character: null, error: '请先登录');
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
          aliases: aliases,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return (character: null, error: error);
    if (resp == null) return (character: null, error: '更新失败');

    final entry = _fromDto(resp);
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = entry;
      notifyListeners();
    }
    return (character: entry, error: null);
  }

  Future<String?> delete(int id) async {
    if (!AuthRepository.instance.isLoggedIn) {
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

  Future<({List<CharacterEntry> items, num total, String? error})> _fetchPage({
    required int page,
    required int pageSize,
    int? workId,
    String? q,
  }) async {
    final (resp, error) = await apiCallback<ListCharactersResp>(
      ({ok, fail, eventually}) => character_api.listCharacters(
        page: page,
        pageSize: pageSize,
        workId: workId,
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
}
