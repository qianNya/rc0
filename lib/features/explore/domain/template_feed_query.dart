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

  /// Desktop [ExploreFeedQuery.desktopTabs] index for embedded template market.
  static const int desktopTemplateTabIndex = 2;

  /// Mobile discovery feed tab index for template market.
  static const int mobileTemplateTabIndex = 1;

  static const String discoverySectionTemplate = 'template';

  static const mobileTabs = ['推荐', '模板'];

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

  static bool isTemplateDesktopTab(int tabIndex) =>
      tabIndex == desktopTemplateTabIndex;

  static bool isTemplateMobileTab(int tabIndex) =>
      tabIndex == mobileTemplateTabIndex;
}
