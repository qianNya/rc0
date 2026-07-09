import 'package:flutter/foundation.dart';

import '../../../api/feed/api/feed-api.dart' as feed_api;
import '../../../api/feed/data/feed-api.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../screenplay/data/screenplay_api_mapper.dart';
import '../domain/template_feed_query.dart';
import '../domain/template_screenplay_filters.dart';

/// Template market data — sole source is GET /feed?kind=2 (D5).
class TemplateMarketRepository extends ChangeNotifier {
  TemplateMarketRepository._();

  static final TemplateMarketRepository instance = TemplateMarketRepository._();

  List<Screenplay> _rawItems = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _pageSize = 20;
  num _total = 0;
  TemplateFeedQuery _query = const TemplateFeedQuery();
  bool _fromFeedApi = true;

  List<Screenplay> get items {
    final filtered = filterTemplateScreenplays(
      _rawItems,
      _query.categoryIndex,
    );
    return sortTemplateScreenplays(filtered, _query.sortTabIndex);
  }

  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  num get total => _total;
  bool get hasMore => _rawItems.length < _total.toInt();
  TemplateFeedQuery get query => _query;
  bool get fromFeedApi => _fromFeedApi;

  Future<void> loadFirstPage({
    int pageSize = 20,
    String? q,
    TemplateFeedQuery? query,
  }) async {
    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    if (query != null) {
      _query = query.copyWith(q: q?.trim().isEmpty == true ? null : q?.trim());
    } else if (q != null) {
      _query = _query.copyWith(q: q.trim().isEmpty ? null : q.trim());
    }
    notifyListeners();

    final result = await _fetchPage(page: 1, pageSize: pageSize);
    _loading = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _rawItems = result.items;
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
      _rawItems.addAll(result.items);
      _total = result.total;
      _page = nextPage;
    }
    notifyListeners();
  }

  void updateFilters({
    int? categoryIndex,
    int? sortTabIndex,
  }) {
    var changed = false;
    if (categoryIndex != null && categoryIndex != _query.categoryIndex) {
      _query = _query.copyWith(categoryIndex: categoryIndex);
      changed = true;
    }
    if (sortTabIndex != null && sortTabIndex != _query.sortTabIndex) {
      _query = _query.copyWith(sortTabIndex: sortTabIndex);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<({List<Screenplay> items, num total, String? error})> _fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final feedResult = await _fetchFromFeed(page: page, pageSize: pageSize);
    _fromFeedApi = true;
    return feedResult;
  }

  Future<({List<Screenplay> items, num total, String? error})> _fetchFromFeed({
    required int page,
    required int pageSize,
  }) async {
    final (resp, error) = await apiCallback<ListFeedResp>(
      ({ok, fail, eventually}) => feed_api.listFeed(
        page: page,
        pageSize: pageSize,
        sort: _query.feedSort,
        q: _query.q,
        kind: TemplateFeedQuery.templateFeedKind,
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
