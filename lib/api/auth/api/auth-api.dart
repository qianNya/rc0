import 'api.dart';
import '../data/auth-api.dart';

/// auth-api

/// --/api/auth/login--
///
/// request: LoginReq
/// response: LoginResp
Future login(
  LoginReq request, {
  Function(LoginResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/auth/login",
    request,
    ok: (data) {
      if (ok != null) ok(LoginResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/auth/profile--
///
/// request:
/// response: Profile
Future getProfile({
  Function(Profile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/auth/profile",
    ok: (data) {
      if (ok != null) ok(Profile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/auth/profile--
///
/// request: UpdateProfileReq
/// response: Profile
Future updateProfile(
  UpdateProfileReq request, {
  Function(Profile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/auth/profile",
    request,
    ok: (data) {
      if (ok != null) ok(Profile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/auth/register--
///
/// request: RegisterReq
/// response: RegisterResp
Future register(
  RegisterReq request, {
  Function(RegisterResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/auth/register",
    request,
    ok: (data) {
      if (ok != null) ok(RegisterResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/auth/ping--
///
/// request:
/// response: PingResp
Future ping({
  Function(PingResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/auth/ping",
    ok: (data) {
      if (ok != null) ok(PingResp.fromJson(data));
    },
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
    '/api/auth/users/$userId/public',
    ok: (data) {
      if (ok != null) ok(PublicUserProfile.fromJson(data));
    },
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
    '/api/auth/users/$userId/follow',
    const {},
    ok: (_) {
      if (ok != null) ok();
    },
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
    '/api/auth/users/$userId/follow',
    const {},
    ok: (_) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

class UserScreenplayBrief {
  final num id;
  final String title;
  final String coverUrl;
  final num likeCount;
  final num viewCount;
  final num creatorId;
  final String creatorNickname;

  UserScreenplayBrief({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.likeCount,
    required this.viewCount,
    required this.creatorId,
    required this.creatorNickname,
  });

  factory UserScreenplayBrief.fromJson(Map<String, dynamic> m) {
    return UserScreenplayBrief(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      coverUrl: m['cover_url'] ?? '',
      likeCount: m['like_count'] ?? 0,
      viewCount: m['view_count'] ?? 0,
      creatorId: m['creator_id'] ?? 0,
      creatorNickname: m['creator_nickname'] ?? '',
    );
  }
}

Future listUserScreenplays(
  int userId, {
  int page = 1,
  int pageSize = 20,
  Function(List<UserScreenplayBrief> list, int total)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/api/auth/users/$userId/screenplays?page=$page&page_size=$pageSize',
    ok: (data) {
      if (ok == null) return;
      final list = ((data['list'] ?? []) as List<dynamic>)
          .map((e) => UserScreenplayBrief.fromJson(e as Map<String, dynamic>))
          .toList();
      ok(list, (data['total'] as num?)?.toInt() ?? list.length);
    },
    fail: fail,
    eventually: eventually,
  );
}
