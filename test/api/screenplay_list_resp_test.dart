import 'package:flutter_test/flutter_test.dart';

import 'package:rc0/api/screenplay/data/screenplay-api.dart';
import 'package:rc0/api/user/data/user-api.dart';

void main() {
  test('ListScreenplaysResp parses Rust PageData with FeedItemDto', () {
    final resp = ListScreenplaysResp.fromJson({
      'items': [
        {
          'item_type': 'screenplay',
          'screenplay': {
            'id': 1,
            'kind': 1,
            'title': 'Test',
            'subtitle': '',
            'summary': '',
            'cover_url': '',
            'cover_ref': '',
            'publish_status': 1,
            'visibility': 1,
            'published_at': '',
            'act_count': 0,
            'scene_count': 0,
            'frame_count': 0,
            'status': 1,
            'create_at': '',
            'update_at': '',
            'creator': 4,
            'updater': 4,
            'view_count': 0,
            'like_count': 0,
            'favorite_count': 0,
            'comment_count': 0,
            'fork_count': 0,
            'is_liked': false,
            'is_favorited': false,
          },
          'author': {
            'id': 4,
            'nickname': 'Alice',
            'avatar': '',
          },
        },
      ],
      'total': 1,
      'page': 1,
      'page_size': 20,
    });

    expect(resp.list, hasLength(1));
    expect(resp.list.first.title, 'Test');
    expect(resp.items.first.author?.nickname, 'Alice');
    expect(resp.page, 1);
    expect(resp.pageSize, 20);
  });

  test('ListScreenplaysResp falls back to legacy list field', () {
    final resp = ListScreenplaysResp.fromJson({
      'list': [
        {
          'id': 2,
          'kind': 1,
          'title': 'Legacy',
          'subtitle': '',
          'summary': '',
          'cover_url': '',
          'cover_ref': '',
          'publish_status': 1,
          'visibility': 1,
          'published_at': '',
          'act_count': 0,
          'scene_count': 0,
          'frame_count': 0,
          'status': 1,
          'create_at': '',
          'update_at': '',
          'creator': 1,
          'updater': 1,
          'view_count': 0,
          'like_count': 0,
          'favorite_count': 0,
          'comment_count': 0,
          'fork_count': 0,
          'is_liked': false,
          'is_favorited': false,
        },
      ],
      'total': 1,
    });

    expect(resp.list.single.title, 'Legacy');
  });

  test('ListUserScreenplaysResp parses nested screenplay items', () {
    final resp = ListUserScreenplaysResp.fromJson({
      'items': [
        {
          'item_type': 'screenplay',
          'screenplay': {
            'id': 3,
            'title': 'User work',
            'cover_url': '',
            'like_count': 2,
            'view_count': 10,
            'create_at': '2026-01-01T00:00:00Z',
          },
          'author': {
            'id': 5,
            'nickname': 'Bob',
          },
        },
      ],
      'total': 1,
      'page': 1,
      'page_size': 20,
    });

    expect(resp.list.single.title, 'User work');
    expect(resp.list.single.creatorNickname, 'Bob');
    expect(resp.page, 1);
  });
}
