import '../../../core/domain/screenplay/screenplay.dart';
import 'template_feed_query.dart';

/// Client-side category filter (discovery no longer shows category chips).
List<Screenplay> filterTemplateScreenplays(
  List<Screenplay> source,
  int categoryIndex,
) {
  return List<Screenplay>.from(source);
}

/// Client-side polish after server sort. Featured prefers `isFeatured`.
List<Screenplay> sortTemplateScreenplays(
  List<Screenplay> source,
  int sortIndex,
) {
  final list = List<Screenplay>.from(source);
  switch (sortIndex) {
    case TemplateFeedQuery.tabLatest:
      list.sort((a, b) => _sortDate(b).compareTo(_sortDate(a)));
      break;
    case TemplateFeedQuery.tabFeatured:
      list.sort((a, b) {
        final featured = (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0);
        if (featured != 0) return featured;
        return b.hotScore.compareTo(a.hotScore);
      });
      break;
    case TemplateFeedQuery.tabFollowing:
    case TemplateFeedQuery.tabHot:
    default:
      list.sort((a, b) {
        final score = b.hotScore.compareTo(a.hotScore);
        if (score != 0) return score;
        return b.likes.compareTo(a.likes);
      });
      break;
  }
  return list;
}

DateTime _sortDate(Screenplay screenplay) {
  return screenplay.publishedAt ??
      screenplay.createdAt ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
