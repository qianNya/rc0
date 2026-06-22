import '../../http/api_client.dart';
import '../data/community-api.dart';

Future toggleLike(
  int screenplayId, {
  Function(ToggleEngagementResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/likes/$screenplayId',
    const {},
    ok: (data) => ok?.call(ToggleEngagementResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future toggleFavorite(
  int screenplayId, {
  Function(ToggleEngagementResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/favorites/$screenplayId',
    const {},
    ok: (data) => ok?.call(ToggleEngagementResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
