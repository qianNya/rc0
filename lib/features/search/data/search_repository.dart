import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../api/feed/api/feed-api.dart' as feed_api;
import '../../../api/feed/data/feed-api.dart';
import '../../../core/network/api_callback.dart';

class SearchRepository extends ChangeNotifier {
  SearchRepository._();

  static final SearchRepository instance = SearchRepository._();

  static const types = ['screenplay', 'character', 'image', 'user'];

  String _query = '';
  int _tabIndex = 0;
  bool _loading = false;
  String? _error;
  final Map<String, List<SearchResultItem>> _cache = {};

  String get query => _query;
  int get tabIndex => _tabIndex;
  bool get loading => _loading;
  String? get error => _error;
  String get currentType => types[_tabIndex.clamp(0, types.length - 1)];

  List<SearchResultItem> get results => _cache[currentType] ?? const [];

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
    if (_query.trim().isNotEmpty) {
      unawaited(search(_query));
    }
  }

  Future<void> search(String q) async {
    final trimmed = q.trim();
    _query = trimmed;
    if (trimmed.isEmpty) {
      _cache.clear();
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    final type = currentType;
    final (resp, err) = await apiCallback<SearchResp>(
      ({ok, fail, eventually}) => feed_api.search(
        q: trimmed,
        type: type,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    _loading = false;
    if (err != null) {
      _error = err;
    } else {
      _cache[type] = resp?.list ?? const [];
      _error = null;
    }
    notifyListeners();
  }
}
