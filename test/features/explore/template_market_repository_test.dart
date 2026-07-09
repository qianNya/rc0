import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/explore/domain/template_feed_query.dart';
import 'package:rc0/features/explore/domain/template_screenplay_filters.dart';
import 'package:rc0/core/domain/screenplay/screenplay.dart';

Screenplay _script({
  required String id,
  List<String> tags = const [],
  int likes = 0,
}) {
  return Screenplay(
    id: id,
    title: id,
    author: 'author',
    tags: tags,
    likes: likes,
  );
}

void main() {
  test('TemplateFeedQuery maps sort tabs to feed sort', () {
    expect(TemplateFeedQuery.sortTabToFeedSort(0), 'hot');
    expect(TemplateFeedQuery.sortTabToFeedSort(1), 'latest');
    expect(TemplateFeedQuery.discoverySectionTemplate, 'template');
  });

  test('filter and sort template screenplays', () {
    final items = [
      _script(id: 'a', tags: ['构图'], likes: 10),
      _script(id: 'b', tags: ['场景'], likes: 30),
    ];
    final filtered = filterTemplateScreenplays(items, 4);
    expect(filtered.map((s) => s.id), ['b']);

    final sorted = sortTemplateScreenplays(items, 0);
    expect(sorted.first.id, 'b');
  });
}
