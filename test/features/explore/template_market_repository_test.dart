import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/explore/domain/template_feed_query.dart';
import 'package:rc0/features/explore/domain/template_screenplay_filters.dart';
import 'package:rc0/core/domain/screenplay/screenplay.dart';

Screenplay _script({
  required String id,
  List<String> tags = const [],
  int likes = 0,
  double hotScore = 0,
  bool isFeatured = false,
}) {
  return Screenplay(
    id: id,
    title: id,
    author: 'author',
    tags: tags,
    likes: likes,
    hotScore: hotScore,
    isFeatured: isFeatured,
  );
}

void main() {
  test('TemplateFeedQuery maps discovery feed tabs to feed sort', () {
    expect(
      TemplateFeedQuery.sortTabToFeedSort(TemplateFeedQuery.tabFeatured),
      'hot',
    );
    expect(
      TemplateFeedQuery.sortTabToFeedSort(TemplateFeedQuery.tabFollowing),
      'recommend',
    );
    expect(
      TemplateFeedQuery.sortTabToFeedSort(TemplateFeedQuery.tabHot),
      'hot',
    );
    expect(
      TemplateFeedQuery.sortTabToFeedSort(TemplateFeedQuery.tabLatest),
      'latest',
    );
    expect(TemplateFeedQuery.discoverySectionTemplate, 'template');
  });

  test('filter and sort template screenplays', () {
    final items = [
      _script(id: 'a', tags: ['构图'], likes: 10, hotScore: 1),
      _script(id: 'b', tags: ['场景'], likes: 30, hotScore: 5),
    ];
    final filtered = filterTemplateScreenplays(items, 4);
    expect(filtered.map((s) => s.id), ['b']);

    final sortedHot = sortTemplateScreenplays(items, TemplateFeedQuery.tabHot);
    expect(sortedHot.first.id, 'b');

    final featured = sortTemplateScreenplays(
      [
        _script(id: 'x', isFeatured: false, hotScore: 9),
        _script(id: 'y', isFeatured: true, hotScore: 1),
      ],
      TemplateFeedQuery.tabFeatured,
    );
    expect(featured.first.id, 'y');
  });
}
