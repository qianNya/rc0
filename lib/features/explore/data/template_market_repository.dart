import 'package:flutter/foundation.dart';

import '../../../api/feed/api/feed-api.dart' as feed_api;
import '../../../api/feed/data/feed-api.dart';
import '../../../api/screenplay/api/screenplay-api.dart' as sp_api;
import '../../../api/screenplay/data/screenplay-api.dart' as sp_dto;
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../screenplay/data/screenplay_api_mapper.dart';
import '../domain/template_feed_query.dart';
import '../domain/template_screenplay_filters.dart' show sortTemplateScreenplays;

class _TabFeedSlot {
  List<Screenplay> rawItems = [];
  bool loading = false;
  bool loadingMore = false;
  String? error;
  int page = 1;
  num total = 0;
  bool featuredMode = false;
  String? loadedForQ;
}

/// Discovery Feed data — GET /feed?kind=2 + featured collections.
class TemplateMarketRepository extends ChangeNotifier {
  TemplateMarketRepository._();

  static final TemplateMarketRepository instance = TemplateMarketRepository._();

  final Map<int, _TabFeedSlot> _slots = {};
  int _pageSize = 20;
  TemplateFeedQuery _query = const TemplateFeedQuery();
  bool _fromFeedApi = true;

  _TabFeedSlot _slotFor(int tabIndex) =>
      _slots.putIfAbsent(tabIndex, _TabFeedSlot.new);

  _TabFeedSlot get _activeSlot => _slotFor(_query.sortTabIndex);

  /// Scripts for a feed tab (each tab keeps its own cache + sort).
  List<Screenplay> scriptsForTab(int tabIndex) {
    final slot = _slots[tabIndex];
    if (slot == null) return const [];
    return sortTemplateScreenplays(slot.rawItems, tabIndex);
  }

  List<Screenplay> get items => scriptsForTab(_query.sortTabIndex);

  bool isTabLoading(int tabIndex) => _slotFor(tabIndex).loading;

  bool isTabLoadingMore(int tabIndex) => _slotFor(tabIndex).loadingMore;

  String? errorForTab(int tabIndex) => _slotFor(tabIndex).error;

  bool hasMoreForTab(int tabIndex) {
    final slot = _slotFor(tabIndex);
    return !slot.featuredMode && slot.rawItems.length < slot.total.toInt();
  }

  bool get loading => _activeSlot.loading;

  bool get loadingMore => _activeSlot.loadingMore;

  String? get error => _activeSlot.error;

  num get total => _activeSlot.total;

  bool get hasMore => hasMoreForTab(_query.sortTabIndex);

  TemplateFeedQuery get query => _query;

  bool get fromFeedApi => _fromFeedApi;

  bool get featuredMode => _activeSlot.featuredMode;

  /// Switch tab without fetching (e.g. 关注 + 未登录).
  void selectTab(TemplateFeedQuery query) {
    _query = query;
    final slot = _activeSlot;
    slot.rawItems = [];
    slot.loading = false;
    slot.loadingMore = false;
    slot.error = null;
    slot.featuredMode = false;
    notifyListeners();
  }

  /// Activate tab and show cached data when available.
  void activateTab(TemplateFeedQuery query) {
    if (_query.sortTabIndex == query.sortTabIndex && _query.q == query.q) {
      return;
    }
    _query = query;
    notifyListeners();
  }

  bool tabHasCache(int tabIndex) {
    final slot = _slots[tabIndex];
    if (slot == null) return false;
    if (slot.loadedForQ != _query.q) return false;
    return slot.rawItems.isNotEmpty || slot.error != null;
  }

  Future<void> loadFirstPage({
    int pageSize = 20,
    String? q,
    TemplateFeedQuery? query,
  }) async {
    if (query != null) {
      _query = query.copyWith(q: q?.trim().isEmpty == true ? null : q?.trim());
    } else if (q != null) {
      _query = _query.copyWith(q: q.trim().isEmpty ? null : q.trim());
    }

    final tabIndex = _query.sortTabIndex;
    final slot = _slotFor(tabIndex);

    slot.loading = true;
    slot.loadingMore = false;
    slot.error = null;
    slot.rawItems = [];
    slot.page = 1;
    slot.featuredMode = false;
    slot.total = 0;
    _pageSize = pageSize;
    notifyListeners();

    final result = await _fetchPage(tabIndex: tabIndex, page: 1, pageSize: pageSize);
    slot.loading = false;
    if (result.error != null) {
      slot.error = result.error;
      slot.loadedForQ = _query.q;
    } else {
      slot.rawItems = result.items;
      slot.total = result.total;
      slot.page = 1;
      slot.featuredMode = result.featuredMode;
      slot.error = null;
      slot.loadedForQ = _query.q;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    final tabIndex = _query.sortTabIndex;
    final slot = _slotFor(tabIndex);
    if (slot.loading || slot.loadingMore || !hasMoreForTab(tabIndex)) return;

    slot.loadingMore = true;
    notifyListeners();

    final nextPage = slot.page + 1;
    final result = await _fetchPage(
      tabIndex: tabIndex,
      page: nextPage,
      pageSize: _pageSize,
    );
    slot.loadingMore = false;
    if (result.error != null) {
      slot.error = result.error;
    } else {
      slot.rawItems.addAll(result.items);
      slot.total = result.total;
      slot.page = nextPage;
    }
    notifyListeners();
  }

  Future<({
    List<Screenplay> items,
    num total,
    String? error,
    bool featuredMode,
  })> _fetchPage({
    required int tabIndex,
    required int page,
    required int pageSize,
  }) async {
    final isFeaturedTab = tabIndex == TemplateFeedQuery.tabFeatured;

    if (isFeaturedTab && page == 1) {
      final featured = await _fetchFeatured();
      if (featured.error == null && featured.items.isNotEmpty) {
        _fromFeedApi = true;
        return (
          items: featured.items,
          total: featured.total,
          error: null,
          featuredMode: true,
        );
      }
    }

    final feedResult = await _fetchFromFeed(
      tabIndex: tabIndex,
      page: page,
      pageSize: pageSize,
    );
    _fromFeedApi = true;
    return (
      items: feedResult.items,
      total: feedResult.total,
      error: feedResult.error,
      featuredMode: false,
    );
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
    required int tabIndex,
    required int page,
    required int pageSize,
  }) async {
    final sort = TemplateFeedQuery.sortTabToFeedSort(tabIndex);
    final (resp, error) = await apiCallback<ListFeedResp>(
      ({ok, fail, eventually}) => feed_api.listFeed(
        page: page,
        pageSize: pageSize,
        sort: sort,
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

    if (tabIndex == TemplateFeedQuery.tabFeatured) {
      final featuredOnly = items.where((s) => s.isFeatured).toList();
      if (featuredOnly.isNotEmpty) {
        items = featuredOnly;
      }
    }

    return (items: items, total: resp?.total ?? 0, error: null);
  }
}
