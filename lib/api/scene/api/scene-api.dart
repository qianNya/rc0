import '../../http/api_client.dart';
import '../data/scene-api.dart';

Future listScenes({
  int page = 1,
  int pageSize = 20,
  String? category,
  String? q,
  Function(ListScenesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final query = <String, String>{
    'page': '$page',
    'page_size': '$pageSize',
  };
  if (category != null && category.trim().isNotEmpty) {
    query['category'] = category.trim();
  }
  if (q != null && q.trim().isNotEmpty) query['q'] = q.trim();

  await apiGet(
    '/scenes',
    query: query,
    ok: (data) => ok?.call(ListScenesResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getScene(
  int sceneId, {
  Function(SceneItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/scenes/$sceneId',
    ok: (data) => ok?.call(SceneItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createScene({
  required SceneWriteBody body,
  Function(SceneItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/scenes',
    body.toJson(),
    ok: (data) => ok?.call(SceneItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateScene(
  int sceneId, {
  required SceneWriteBody body,
  Function(SceneItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/scenes/$sceneId',
    body.toJson(),
    ok: (data) => ok?.call(SceneItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteScene(
  int sceneId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/scenes/$sceneId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future listImageScenes(
  int imageId, {
  Function(List<SceneItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/images/$imageId/scenes',
    ok: (data) {
      final raw = data['items'] ?? data['list'] ?? [];
      final items = (raw as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SceneItem.fromJson)
          .toList();
      ok?.call(items);
    },
    fail: fail,
    eventually: eventually,
  );
}

Future linkImageScene(
  int imageId, {
  required int sceneId,
  int relationType = 0,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/images/$imageId/scenes',
    {
      'scene_id': sceneId,
      'relation_type': relationType,
    },
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future unlinkImageScene(
  int imageId,
  int sceneId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/images/$imageId/scenes/$sceneId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}
