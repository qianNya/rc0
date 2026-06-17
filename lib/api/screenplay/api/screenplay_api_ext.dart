import '../../http/api_client.dart';
import '../data/screenplay-api.dart';

Future<void> listPublicScreenplaysPage({
  int page = 1,
  int pageSize = 20,
  void Function(ListScreenplaysResp)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  return apiGet(
    '/api/screenplay/screenplays',
    query: {
      'page': '$page',
      'page_size': '$pageSize',
      'publish_status': '1',
      'visibility': '1',
    },
    ok: (data) => ok?.call(ListScreenplaysResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future<void> likeScreenplay(
  int id, {
  void Function()? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  final req = ScreenplayEngagementReq(id: id);
  return apiPost(
    '/api/screenplay/screenplays/$id/like',
    req.toJson(),
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future<void> unlikeScreenplay(
  int id, {
  void Function()? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  final req = ScreenplayEngagementReq(id: id);
  return apiDelete(
    '/api/screenplay/screenplays/$id/like',
    body: req.toJson(),
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}
