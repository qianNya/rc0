import '../../../core/data/app_catalog.dart';

/// Unified query for template market — feed API + client category/sort.
class TemplateFeedQuery {
  const TemplateFeedQuery({
    this.categoryIndex = 0,
    this.sortTabIndex = 0,
    this.q,
  });

  /// GET /feed kind filter for published templates (forkable screenplays).
  static const int templateFeedKind = 2;

  /// Query param for `/discovery?section=template` (same page as `/discovery`).
  static const String discoverySectionTemplate = 'template';

  final int categoryIndex;
  final int sortTabIndex;
  final String? q;

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
        sortTabIndex >= AppCatalog.communitySortTabs.length) {
      return 'hot';
    }
    return switch (sortTabIndex) {
      0 => 'hot',
      1 => 'latest',
      _ => 'latest',
    };
  }
}
