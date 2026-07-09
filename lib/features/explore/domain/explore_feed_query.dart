import 'template_feed_query.dart';

/// Maps desktop feed tab index to GET /feed query parameters.
class ExploreFeedQuery {
  const ExploreFeedQuery({
    this.sort = 'hot',
    this.kind,
    this.tagId,
  });

  final String sort;
  final int? kind;
  final int? tagId;

  static const desktopTabs = [
    '推荐',
    '社区作品',
    '模板市场',
    '关注',
    '最新',
    '热门',
  ];

  static const int templateMarketTabIndex = 2;

  static ExploreFeedQuery forTab(int index) {
    if (index == templateMarketTabIndex) {
      return ExploreFeedQuery(
        sort: 'latest',
        kind: TemplateFeedQuery.templateFeedKind,
      );
    }
    switch (index) {
      case 0:
        return const ExploreFeedQuery(sort: 'hot');
      case 1:
        return const ExploreFeedQuery(sort: 'latest');
      case 2:
        return ExploreFeedQuery(
          sort: 'latest',
          kind: TemplateFeedQuery.templateFeedKind,
        );
      case 3:
        return const ExploreFeedQuery(sort: 'latest');
      case 4:
        return const ExploreFeedQuery(sort: 'latest');
      case 5:
        return const ExploreFeedQuery(sort: 'hot');
      default:
        return const ExploreFeedQuery(sort: 'hot');
    }
  }
}
