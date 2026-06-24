import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/screenplay/data/screenplay-api.dart' as sp_dto;
import 'package:rc0/api/user/data/user-api.dart';
import 'package:rc0/core/domain/screenplay/screenplay.dart';
import 'package:rc0/features/screenplay/data/screenplay_api_mapper.dart';
import 'package:rc0/features/user/data/user_screenplays_fetch.dart';

void main() {
  group('shouldFallbackToUserScreenplays', () {
    test('falls back when creator query succeeds but is empty', () {
      expect(
        shouldFallbackToUserScreenplays(creatorItems: [], creatorError: null),
        isTrue,
      );
    });

    test('does not fall back when creator query failed', () {
      expect(
        shouldFallbackToUserScreenplays(
          creatorItems: [],
          creatorError: 'network error',
        ),
        isFalse,
      );
    });

    test('does not fall back when creator query has items', () {
      expect(
        shouldFallbackToUserScreenplays(
          creatorItems: [
            const Screenplay(id: '1', title: 'A'),
          ],
          creatorError: null,
        ),
        isFalse,
      );
    });
  });

  test('screenplayFromBrief maps visibility', () {
    final brief = ScreenplayBrief.fromJson({
      'screenplay': {
        'id': 14,
        'title': '喵喵喵',
        'cover_url': '',
        'like_count': 0,
        'view_count': 0,
        'visibility': 0,
        'publish_status': 1,
      },
      'author': {'id': 1, 'nickname': '作者'},
    });

    final script = screenplayFromBrief(brief);
    expect(script.remoteScreenplayId, 14);
    expect(script.visibility, 0);
  });

  test('ScreenplayApiMapper.fromListItem maps visibility', () {
    final item = sp_dto.Screenplay.fromJson({
      'id': 14,
      'kind': 1,
      'title': '喵喵喵',
      'subtitle': '',
      'summary': '',
      'cover_url': '',
      'cover_ref': '',
      'publish_status': 1,
      'visibility': 1,
      'published_at': '',
      'act_count': 1,
      'scene_count': 1,
      'frame_count': 3,
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
    });

    final script = ScreenplayApiMapper.fromListItem(item);
    expect(script.visibility, 1);
    expect(script.remoteScreenplayId, 14);
    expect(script.ownerUserId, 1);
    expect(script.author, '用户 1');
  });

  test('ScreenplayApiMapper.fromFeedItem maps nested author', () {
    final item = sp_dto.FeedItemDto.fromJson({
      'item_type': 'screenplay',
      'screenplay': {
        'id': 14,
        'title': '喵喵喵',
        'creator': 1,
        'visibility': 0,
        'publish_status': 1,
        'act_count': 1,
        'scene_count': 1,
        'frame_count': 2,
      },
      'author': {'id': 1, 'nickname': 'Alice', 'avatar': ''},
    });

    final script = ScreenplayApiMapper.fromFeedItem(item);
    expect(script.author, 'Alice');
    expect(script.ownerUserId, 1);
  });
}
