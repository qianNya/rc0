import '../../http/api_client.dart';
import '../data/user-api.dart';

Future getProfile({
  Function(Profile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/users/me',
    ok: (data) => ok?.call(Profile.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateProfile(
  UpdateProfileReq request, {
  Function(Profile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/users/me',
    request.toJson(),
    ok: (data) => ok?.call(Profile.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getPublicUserProfile(
  int userId, {
  Function(PublicUserProfile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/users/$userId/profile',
    ok: (data) => ok?.call(PublicUserProfile.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

const _defaultPublishStatus = 1;

Future listUserScreenplays(
  int userId, {
  int page = 1,
  int pageSize = 20,
  int? kind,
  int? publishStatus,
  Function(ListUserScreenplaysResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final query = <String, String>{
    'page': '$page',
    'page_size': '$pageSize',
  };
  if (kind != null) query['kind'] = '$kind';
  if (publishStatus != null && publishStatus != _defaultPublishStatus) {
    query['publish_status'] = '$publishStatus';
  }
  await apiGet(
    '/users/$userId/screenplays',
    query: query,
    ok: (data) => ok?.call(ListUserScreenplaysResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listUserFavorites(
  int userId, {
  int page = 1,
  int pageSize = 20,
  Function(ListSpFavoritesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/users/$userId/favorites',
    query: {'page': '$page', 'page_size': '$pageSize'},
    ok: (data) => ok?.call(ListSpFavoritesResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listUserLikes(
  int userId, {
  int page = 1,
  int pageSize = 20,
  Function(ListSpLikesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/users/$userId/likes',
    query: {'page': '$page', 'page_size': '$pageSize'},
    ok: (data) => ok?.call(ListSpLikesResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future followUser(
  int userId, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/users/$userId/follow',
    const {},
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future unfollowUser(
  int userId, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/users/$userId/follow',
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}
