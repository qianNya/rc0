import 'package:flutter/foundation.dart';

import '../../../api/feed/api/feed-api.dart' as feed_api;
import '../../../api/feed/data/feed-api.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../screenplay/data/screenplay_api_mapper.dart';
import '../domain/explore_feed_query.dart';

class FeedRepository extends ChangeNotifier {
  FeedRepository._();

  static final FeedRepository instance = FeedRepository._();

  List<Screenplay> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _pageSize = 20;
  num _total = 0;
  String? _query;
  ExploreFeedQuery _feedQuery = const ExploreFeedQuery();

  List<Screenplay> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  num get total => _total;
  bool get hasMore => _items.length < _total.toInt();
  ExploreFeedQuery get feedQuery => _feedQuery;

  Future<void> loadFirstPage({
    int pageSize = 20,
    String? q,
    ExploreFeedQuery? feedQuery,
  }) async {
    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    _query = q?.trim().isEmpty == true ? null : q?.trim();
    if (feedQuery != null) _feedQuery = feedQuery;
    notifyListeners();

    final result = await _fetchPage(page: 1, pageSize: pageSize);
    _loading = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items = result.items;
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
    final result = await _fetchPage(page: nextPage, pageSize: _pageSize);
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

  Future<({List<Screenplay> items, num total, String? error})> _fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final (resp, error) = await apiCallback<ListFeedResp>(
      ({ok, fail, eventually}) => feed_api.listFeed(
        page: page,
        pageSize: pageSize,
        sort: _feedQuery.sort,
        q: _query,
        tagId: _feedQuery.tagId,
        kind: _feedQuery.kind,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (items: <Screenplay>[], total: 0, error: error);
    }

    final feedItems = resp?.items ?? const [];
    final items = feedItems.map(ScreenplayApiMapper.fromFeedItem).toList();
    return (items: items, total: resp?.total ?? 0, error: null);
  }
}
