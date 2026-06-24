import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../api/http/api_client.dart';
import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../api/screenplay/data/screenplay-api.dart' as sp_dto;
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import 'screenplay_api_mapper.dart';
import 'screenplay_tree_document.dart';

class ScreenplayRemoteRepository extends ChangeNotifier {
  ScreenplayRemoteRepository._();

  static final ScreenplayRemoteRepository instance =
      ScreenplayRemoteRepository._();

  final Map<int, Screenplay> _treeCache = {};
  final Map<int, Map<String, dynamic>> _rawTreeCache = {};

  List<Screenplay> _screenplays = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _pageSize = 20;
  num _total = 0;
  String? _query;
  String? _sort;
  int? _visibility;

  List<Screenplay> get screenplays => List.unmodifiable(_screenplays);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  num get total => _total;
  bool get hasMore => _screenplays.length < _total.toInt();

  Map<String, dynamic>? getRawTree(int id) => _rawTreeCache[id];

  Future<void> loadFirstPage({
    int pageSize = 20,
    String? q,
    String? sort,
    int? visibility = 1,
  }) async {
    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    _query = q?.trim().isEmpty == true ? null : q?.trim();
    _sort = sort?.trim().isEmpty == true ? null : sort?.trim();
    _visibility = visibility;
    notifyListeners();

    final result = await fetchScreenplays(
      page: 1,
      pageSize: pageSize,
      q: _query,
      sort: _sort,
      visibility: _visibility,
    );
    _loading = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _screenplays = result.items;
      _total = result.total;
      _page = 1;
      _error = null;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !hasMore) return;

    _loadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final result = await fetchScreenplays(
      page: nextPage,
      pageSize: _pageSize,
      q: _query,
      sort: _sort,
      visibility: _visibility,
    );
    _loadingMore = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _screenplays.addAll(result.items);
      _total = result.total;
      _page = nextPage;
    }
    notifyListeners();
  }

  Future<({List<Screenplay> items, num total, String? error})> fetchScreenplays({
    int page = 1,
    int pageSize = 20,
    String? q,
    String? sort,
    int? visibility,
  }) async {
    final (resp, error) = await apiCallback<sp_dto.ListScreenplaysResp>(
      ({ok, fail, eventually}) => screenplay_api.listScreenplays(
        page: page,
        pageSize: pageSize,
        q: q,
        sort: sort,
        visibility: visibility,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (items: <Screenplay>[], total: 0, error: error);
    }

    final feedItems = resp?.items ?? const <sp_dto.FeedItemDto>[];
    final items = feedItems.isNotEmpty
        ? feedItems.map(ScreenplayApiMapper.fromFeedItem).toList()
        : (resp?.list ?? [])
            .map(ScreenplayApiMapper.fromListItem)
            .toList();

    return (items: items, total: resp?.total ?? 0, error: null);
  }

  Future<({Screenplay? screenplay, String? error})> fetchScreenplayDetail(
    int id,
  ) async {
    final (detail, error) = await apiCallback<sp_dto.Screenplay>(
      ({ok, fail, eventually}) => screenplay_api.getScreenplayDetail(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null || detail == null) {
      return (screenplay: null, error: error ?? 'detail not found');
    }
    return (screenplay: ScreenplayApiMapper.fromListItem(detail), error: null);
  }

  Future<({Screenplay? screenplay, String? error})> fetchScreenplayTree(
    int id, {
    bool useCache = true,
  }) async {
    if (useCache && _treeCache.containsKey(id)) {
      return (screenplay: _treeCache[id], error: null);
    }

    final (tree, error) = await apiCallback<sp_dto.GetScreenplayTreeResp>(
      ({ok, fail, eventually}) => screenplay_api.getScreenplayTree(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (screenplay: null, error: error);
    }
    if (tree == null) {
      return (screenplay: null, error: 'tree not found');
    }

    final raw = ScreenplayApiMapper.treeToJsonMap(tree);
    _rawTreeCache[id] = raw;
    final screenplay = ScreenplayApiMapper.fromTree(tree);
    _treeCache[id] = screenplay;
    return (screenplay: screenplay, error: null);
  }

  Future<({Map<String, dynamic>? tree, String? error})> fetchRawTree(
    int id, {
    bool useCache = true,
  }) async {
    if (useCache && _rawTreeCache.containsKey(id)) {
      return (tree: deepCopyJson(_rawTreeCache[id]!), error: null);
    }

    final result = await fetchScreenplayTree(id, useCache: useCache);
    if (result.error != null) {
      return (tree: null, error: result.error);
    }
    final raw = _rawTreeCache[id];
    if (raw == null) {
      return (tree: null, error: 'tree not found');
    }
    return (tree: deepCopyJson(raw), error: null);
  }

  Future<({sp_dto.GetScreenplayTreeResp? tree, String? error})>
      refreshTreeAfterPublish(int id) async {
    clearTreeCache(id);
    final completer =
        Completer<({sp_dto.GetScreenplayTreeResp? tree, String? error})>();

    await apiGet(
      '/screenplays/$id/tree',
      query: screenplay_api.buildScreenplayTreeQuery(),
      ok: (data) {
        final normalized = sp_dto.normalizeScreenplayTreeJson(
          data as Map<String, dynamic>,
        );
        _rawTreeCache[id] = deepCopyJson(normalized);
        final tree = sp_dto.GetScreenplayTreeResp.fromJson(normalized);
        _treeCache[id] = ScreenplayApiMapper.fromTree(tree);
        completer.complete((tree: tree, error: null));
      },
      fail: (msg) => completer.complete((tree: null, error: msg)),
    );

    return completer.future;
  }

  Map<String, dynamic>? rawTreeAfterRefresh(int id) => _rawTreeCache[id];

  Future<({sp_dto.GetScreenplayTreeResp? tree, String? error})> saveScreenplayTree(
    int id,
    Map<String, dynamic> payload, {
    required bool isInitial,
  }) async {
    final (tree, error) = await apiCallback<sp_dto.GetScreenplayTreeResp>(
      ({ok, fail, eventually}) {
        if (isInitial) {
          return screenplay_api.createScreenplayTree(
            id,
            payload,
            ok: ok,
            fail: fail,
            eventually: eventually,
          );
        }
        return screenplay_api.updateScreenplayTree(
          id,
          payload,
          ok: ok,
          fail: fail,
          eventually: eventually,
        );
      },
    );

    if (error != null) {
      return (tree: null, error: error);
    }
    if (tree == null) {
      return (tree: null, error: 'tree save failed');
    }

    final raw = ScreenplayApiMapper.treeToJsonMap(tree);
    _rawTreeCache[id] = raw;
    _treeCache[id] = ScreenplayApiMapper.fromTree(tree);
    return (tree: tree, error: null);
  }

  void clearTreeCache([int? id]) {
    if (id != null) {
      _treeCache.remove(id);
      _rawTreeCache.remove(id);
    } else {
      _treeCache.clear();
      _rawTreeCache.clear();
    }
  }
}
