import 'package:flutter/foundation.dart';

import '../../../api/feed/api/feed-api.dart' as feed_api;
import '../../../api/feed/data/feed-api.dart';
import '../../../api/screenplay/api/screenplay-api.dart' as sp_api;
import '../../../api/screenplay/data/screenplay-api.dart' as sp_dto;
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../screenplay/data/screenplay_api_mapper.dart';
import '../domain/template_feed_query.dart';
import '../domain/template_screenplay_filters.dart';

/// Discovery Feed data — GET /feed?kind=2 + featured collections.
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
  bool _featuredMode = false;

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
  bool get hasMore => !_featuredMode && _rawItems.length < _total.toInt();
  TemplateFeedQuery get query => _query;
  bool get fromFeedApi => _fromFeedApi;
  bool get featuredMode => _featuredMode;

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
    if (_query.isFeaturedTab && page == 1) {
      final featured = await _fetchFeatured();
      if (featured.error == null && featured.items.isNotEmpty) {
        _featuredMode = true;
        _fromFeedApi = true;
        return featured;
      }
      // Fall through to hot feed when collections empty / fail.
    }

    _featuredMode = false;
    final feedResult = await _fetchFromFeed(page: page, pageSize: pageSize);
    _fromFeedApi = true;
    return feedResult;
  }

  Future<({List<Screenplay> items, num total, String? error})>
      _fetchFeatured() async {
    final (collections, colError) =
        await apiCallback<sp_dto.ListFeaturedCollectionsResp>(
      ({ok, fail, eventually}) => sp_api.listFeaturedCollections(
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (colError != null) {
      return (items: <Screenplay>[], total: 0, error: colError);
    }

    final list = collections?.items ?? const [];
    if (list.isEmpty) {
      return (items: <Screenplay>[], total: 0, error: null);
    }

    final merged = <Screenplay>[];
    final seen = <int>{};
    for (final collection in list) {
      final id = collection.id.toInt();
      if (id <= 0) continue;
      final (detail, detailError) =
          await apiCallback<sp_dto.FeaturedCollectionDetailDto>(
        ({ok, fail, eventually}) => sp_api.getFeaturedCollection(
          id,
          ok: ok,
          fail: fail,
          eventually: eventually,
        ),
      );
      if (detailError != null || detail == null) continue;
      for (final sp in detail.templates) {
        final sid = sp.id.toInt();
        if (sid <= 0 || !seen.add(sid)) continue;
        merged.add(
          ScreenplayApiMapper.fromListItem(sp).copyWith(isFeatured: true),
        );
      }
    }

    if (merged.isEmpty) {
      return (items: <Screenplay>[], total: 0, error: null);
    }

    final q = _query.q?.trim();
    var items = merged;
    if (q != null && q.isNotEmpty) {
      final lower = q.toLowerCase();
      items = merged
          .where(
            (s) =>
                s.title.toLowerCase().contains(lower) ||
                s.synopsis.toLowerCase().contains(lower) ||
                s.author.toLowerCase().contains(lower),
          )
          .toList();
    }

    return (items: items, total: items.length, error: null);
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

    var feedItems = resp?.items ?? const [];
    var items = feedItems.map(ScreenplayApiMapper.fromFeedItem).toList();

    // Featured tab fallback: prefer is_featured when using hot feed.
    if (_query.isFeaturedTab) {
      final featuredOnly = items.where((s) => s.isFeatured).toList();
      if (featuredOnly.isNotEmpty) {
        items = featuredOnly;
      }
    }

    return (items: items, total: resp?.total ?? 0, error: null);
  }
}
