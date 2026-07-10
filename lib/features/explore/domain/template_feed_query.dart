import '../../../core/data/app_catalog.dart';

/// Unified query for Discovery Feed — feed API + client category filter.
class TemplateFeedQuery {
  const TemplateFeedQuery({
    this.categoryIndex = 0,
    this.sortTabIndex = 2,
    this.q,
  });

  /// GET /feed kind filter for published templates (forkable screenplays).
  static const int templateFeedKind = 2;

  /// Query param for `/discovery?section=template` (same page as `/discovery`).
  static const String discoverySectionTemplate = 'template';

  /// Tab indices for [AppCatalog.discoveryFeedTabs].
  static const int tabFeatured = 0;
  static const int tabFollowing = 1;
  static const int tabHot = 2;
  static const int tabLatest = 3;

  final int categoryIndex;
  final int sortTabIndex;
  final String? q;

  bool get isFeaturedTab => sortTabIndex == tabFeatured;
  bool get isFollowingTab => sortTabIndex == tabFollowing;

  /// Server `sort` for non-featured tabs. Featured uses collections API.
  String get feedSort => sortTabToFeedSort(sortTabIndex);

  TemplateFeedQuery copyWith({
    int? categoryIndex,
    int? sortTabIndex,
    String? q,
  }) {
    return TemplateFeedQuery(
      categoryIndex: categoryIndex ?? this.categoryIndex,
      sortTabIndex: sortTabIndex ?? this.sortTabIndex,
      q: q ?? this.q,
    );
  }

  static String sortTabToFeedSort(int sortTabIndex) {
    if (sortTabIndex < 0 ||
        sortTabIndex >= AppCatalog.discoveryFeedTabs.length) {
      return 'hot';
    }
    return switch (sortTabIndex) {
      tabFeatured => 'hot',
      tabFollowing => 'recommend',
      tabHot => 'hot',
      tabLatest => 'latest',
      _ => 'hot',
    };
  }
}
