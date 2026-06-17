import '../../http/api_client.dart';
import '../data/admin-api.dart';

Future<void> getProfile({
  void Function(Profile)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  return apiGet(
    '/api/admin/profile',
    ok: (data) => ok?.call(Profile.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future<void> followUser(
  int userId, {
  void Function()? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  final req = SocialUserIdReq(id: userId);
  return apiPost(
    '/api/admin/social/users/$userId/follow',
    req.toJson(),
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future<void> unfollowUser(
  int userId, {
  void Function()? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  final req = SocialUserIdReq(id: userId);
  return apiDelete(
    '/api/admin/social/users/$userId/follow',
    body: req.toJson(),
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future<void> getPublicUserProfile(
  int userId, {
  void Function(PublicUserProfile)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  return apiGet(
    '/api/admin/social/users/$userId/public',
    ok: (data) => ok?.call(PublicUserProfile.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future<void> listUserScreenplays(
  int userId, {
  int page = 1,
  int pageSize = 20,
  void Function(ListUserScreenplaysResp)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  return apiGet(
    '/api/admin/social/users/$userId/screenplays',
    query: {'page': '$page', 'page_size': '$pageSize'},
    ok: (data) => ok?.call(ListUserScreenplaysResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
