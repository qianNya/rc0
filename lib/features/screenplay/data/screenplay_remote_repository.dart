import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../core/domain/screenplay/screenplay.dart';
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
    final completer = Completer<({List<Screenplay> items, String? error})>();

    await screenplay_api.listPublicScreenplaysPage(
      page: page,
      pageSize: pageSize,
      ok: (resp) {
        final items =
            resp.list.map(ScreenplayApiMapper.fromListItem).toList();
        completer.complete((items: items, error: null));
      },
      fail: (msg) => completer.complete((items: <Screenplay>[], error: msg)),
    );

    return completer.future;
  }

  Future<({Screenplay? screenplay, String? error})> fetchScreenplayTree(
    int id, {
    bool useCache = true,
  }) async {
    if (useCache && _treeCache.containsKey(id)) {
      return (screenplay: _treeCache[id], error: null);
    }

    final completer = Completer<({Screenplay? screenplay, String? error})>();

    await screenplay_api.getScreenplayTree(
      id,
      ok: (tree) {
        final raw = ScreenplayApiMapper.treeToJsonMap(tree);
        _rawTreeCache[id] = raw;
        final screenplay = ScreenplayApiMapper.fromTree(tree);
        _treeCache[id] = screenplay;
        completer.complete((screenplay: screenplay, error: null));
      },
      fail: (msg) => completer.complete((screenplay: null, error: msg)),
    );

    return completer.future;
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
