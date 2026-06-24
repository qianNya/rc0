import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/community/data/community-api.dart';

void main() {
  test('ScreenplayTagItem parses tag fields', () {
    final tag = ScreenplayTagItem.fromJson({
      'id': 4,
      'name': 'Cosplay',
      'slug': 'cosplay',
      'namespace': 'default',
    });

    expect(tag.name, 'Cosplay');
    expect(tag.namespace, 'default');
  });

  test('ListScreenplayTagsResp reads list wrapper', () {
    final resp = ListScreenplayTagsResp.fromJson({
      'tags': [
        {'id': 1, 'name': '人像', 'slug': 'portrait', 'namespace': 'default'},
      ],
    });

    expect(resp.list, hasLength(1));
    expect(resp.list.first.name, '人像');
  });
}
