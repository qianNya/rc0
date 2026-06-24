import 'package:flutter/foundation.dart';

import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../api/screenplay/data/screenplay-api.dart' as sp_dto;
import '../../../api/user/api/user-api.dart' as user_api;
import '../../../api/user/data/user-api.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../screenplay/data/screenplay_api_mapper.dart';

/// Whether to call `GET /users/{id}/screenplays` after an empty creator query.
@visibleForTesting
bool shouldFallbackToUserScreenplays({
  required List<Screenplay> creatorItems,
  String? creatorError,
}) =>
    creatorError == null && creatorItems.isEmpty;

/// Fetches a user's screenplays: `GET /screenplays?creator={id}` first,
/// then falls back to `GET /users/{id}/screenplays` when the primary is empty.
Future<({List<Screenplay> items, num total, String? error})>
    fetchUserScreenplaysPage({
  required int userId,
  required int page,
  required int pageSize,
}) async {
  final (creatorResp, creatorError) =
      await apiCallback<sp_dto.ListScreenplaysResp>(
    ({ok, fail, eventually}) => screenplay_api.listScreenplays(
      page: page,
      pageSize: pageSize,
      creator: userId,
      ok: ok,
      fail: fail,
      eventually: eventually,
    ),
  );

  if (creatorError != null) {
    return (items: <Screenplay>[], total: 0, error: creatorError);
  }

  final creatorItems = (creatorResp?.items ?? const <sp_dto.FeedItemDto>[])
          .isNotEmpty
      ? creatorResp!.items.map(ScreenplayApiMapper.fromFeedItem).toList()
      : (creatorResp?.list ?? [])
          .map(ScreenplayApiMapper.fromListItem)
          .toList();
  if (creatorItems.isNotEmpty) {
    return (items: creatorItems, total: creatorResp?.total ?? 0, error: null);
  }

  final (userResp, userError) = await apiCallback<ListUserScreenplaysResp>(
    ({ok, fail, eventually}) => user_api.listUserScreenplays(
      userId,
      page: page,
      pageSize: pageSize,
      ok: ok,
      fail: fail,
      eventually: eventually,
    ),
  );

  if (userError != null) {
    return (items: <Screenplay>[], total: 0, error: userError);
  }

  final items = (userResp?.list ?? []).map(screenplayFromBrief).toList();
  return (items: items, total: userResp?.total ?? 0, error: null);
}

Screenplay screenplayFromBrief(ScreenplayBrief b) {
  return Screenplay(
    id: b.id.toString(),
    title: b.title,
    coverUrl: b.coverUrl.isNotEmpty ? b.coverUrl : null,
    author: b.creatorNickname.isNotEmpty ? b.creatorNickname : '创作者',
    ownerUserId: b.creatorId.toInt(),
    likes: b.likeCount.toInt(),
    views: b.viewCount.toInt(),
    isLocal: false,
    remoteScreenplayId: b.id.toInt(),
    visibility: b.visibility.toInt(),
  );
}
