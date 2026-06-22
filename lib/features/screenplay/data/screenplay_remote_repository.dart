import 'package:flutter/foundation.dart';

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
  String? _error;

  List<Screenplay> get screenplays => List.unmodifiable(_screenplays);
  bool get loading => _loading;
  String? get error => _error;

  Map<String, dynamic>? getRawTree(int id) => _rawTreeCache[id];

  Future<void> loadFirstPage({int pageSize = 20}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await fetchScreenplays(page: 1, pageSize: pageSize);
    _loading = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _screenplays = result.items;
      _error = null;
    }
    notifyListeners();
  }

  Future<({List<Screenplay> items, String? error})> fetchScreenplays({
    int page = 1,
    int pageSize = 20,
  }) async {
    final (resp, error) = await apiCallback<sp_dto.ListScreenplaysResp>(
      ({ok, fail, eventually}) => screenplay_api.listScreenplays(
        page: page,
        pageSize: pageSize,
        publishStatus: 1,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (items: <Screenplay>[], error: error);
    }

    final items = (resp?.list ?? [])
        .where(
          (item) =>
              item.publishStatus.toInt() == 1 && item.visibility.toInt() == 1,
        )
        .map(ScreenplayApiMapper.fromListItem)
        .toList();

    return (items: items, error: null);
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
    final (tree, error) = await apiCallback<sp_dto.GetScreenplayTreeResp>(
      ({ok, fail, eventually}) => screenplay_api.getScreenplayTree(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null || tree == null) {
      return (tree: null, error: error ?? 'tree not found');
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
