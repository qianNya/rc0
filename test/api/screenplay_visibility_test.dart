import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/screenplay/api/screenplay-api.dart' as screenplay_api;
import 'package:rc0/api/user/data/user-api.dart';

void main() {
  test('buildScreenplayListQuery includes visibility when set', () {
    final query = screenplay_api.buildScreenplayListQuery(
      page: 1,
      pageSize: 20,
      visibility: 1,
    );
    expect(query['visibility'], '1');
    expect(query['page'], '1');
    expect(query['page_size'], '20');
  });

  test('buildScreenplayListQuery omits visibility when null', () {
    final query = screenplay_api.buildScreenplayListQuery(
      page: 2,
      pageSize: 10,
    );
    expect(query.containsKey('visibility'), isFalse);
  });

  test('ScreenplayBrief parses visibility from nested screenplay', () {
    final brief = ScreenplayBrief.fromJson({
      'screenplay': {
        'id': 14,
        'title': '喵喵喵',
        'cover_url': '',
        'like_count': 0,
        'view_count': 0,
        'publish_status': 1,
        'visibility': 0,
        'create_at': '2026-01-01',
      },
      'author': {'id': 1, 'nickname': '作者'},
    });
    expect(brief.id, 14);
    expect(brief.publishStatus, 1);
    expect(brief.visibility, 0);
  });
}
