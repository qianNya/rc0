import 'api.dart';
import '../data/screenplay-api.dart';

/// screenplay-api

/// --/api/screenplay/ping--
///
/// request:
/// response: PingResp
Future ping({
  Function(PingResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/ping",
    ok: (data) {
      if (ok != null) ok(PingResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays--
///
/// request: CreateScreenplayReq
/// response: Screenplay
Future createScreenplay(
  CreateScreenplayReq request, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/screenplay/screenplays",
    request,
    ok: (data) {
      if (ok != null) ok(Screenplay.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays--
///
/// request: ListScreenplaysReq
/// response: ListScreenplaysResp
Future listScreenplays({
  Function(ListScreenplaysResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays",
    ok: (data) {
      if (ok != null) ok(ListScreenplaysResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// Hand-written: paginated list (generated listScreenplays omits query params).
Future listScreenplaysPage({
  int page = 1,
  int pageSize = 20,
  Function(ListScreenplaysResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/api/screenplay/screenplays?page=$page&page_size=$pageSize',
    ok: (data) {
      if (ok != null) ok(ListScreenplaysResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// Public community browse: published + public visibility.
Future listPublicScreenplaysPage({
  int page = 1,
  int pageSize = 20,
  int? creatorId,
  Function(ListScreenplaysResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  var url =
      '/api/screenplay/screenplays?page=$page&page_size=$pageSize&publish_status=1&visibility=1';
  if (creatorId != null && creatorId > 0) {
    url += '&creator=$creatorId';
  }
  await apiGet(
    url,
    ok: (data) {
      if (ok != null) ok(ListScreenplaysResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id--
///
/// request: GetScreenplayReq
/// response: Screenplay
Future getScreenplay(
  int id, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}",
    ok: (data) {
      if (ok != null) ok(Screenplay.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id--
///
/// request: UpdateScreenplayReq
/// response: Screenplay
Future updateScreenplay(
  int id,
  UpdateScreenplayReq request, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    "/api/screenplay/screenplays/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(Screenplay.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id--
///
/// request: DeleteScreenplayReq
/// response:
Future deleteScreenplay(
  int id,
  DeleteScreenplayReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    "/api/screenplay/screenplays/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts--
///
/// request: CreateActReq
/// response: Act
Future createAct(
  int id,
  CreateActReq request, {
  Function(Act)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/screenplay/screenplays/${id}/acts",
    request,
    ok: (data) {
      if (ok != null) ok(Act.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts--
///
/// request: ListActsReq
/// response: ListActsResp
Future listActs(
  int id, {
  Function(ListActsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}/acts",
    ok: (data) {
      if (ok != null) ok(ListActsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId--
///
/// request: GetActReq
/// response: Act
Future getAct(
  int id,
  int actId, {
  Function(Act)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}/acts/${actId}",
    ok: (data) {
      if (ok != null) ok(Act.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId--
///
/// request: UpdateActReq
/// response: Act
Future updateAct(
  int id,
  int actId,
  UpdateActReq request, {
  Function(Act)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    "/api/screenplay/screenplays/${id}/acts/${actId}",
    request,
    ok: (data) {
      if (ok != null) ok(Act.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId--
///
/// request: DeleteActReq
/// response:
Future deleteAct(
  int id,
  int actId,
  DeleteActReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    "/api/screenplay/screenplays/${id}/acts/${actId}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes--
///
/// request: CreateSceneReq
/// response: Scene
Future createScene(
  int id,
  int actId,
  CreateSceneReq request, {
  Function(Scene)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes",
    request,
    ok: (data) {
      if (ok != null) ok(Scene.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes--
///
/// request: ListScenesReq
/// response: ListScenesResp
Future listScenes(
  int id,
  int actId, {
  Function(ListScenesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes",
    ok: (data) {
      if (ok != null) ok(ListScenesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId--
///
/// request: GetSceneReq
/// response: Scene
Future getScene(
  int id,
  int actId,
  int sceneId, {
  Function(Scene)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}",
    ok: (data) {
      if (ok != null) ok(Scene.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId--
///
/// request: UpdateSceneReq
/// response: Scene
Future updateScene(
  int id,
  int actId,
  int sceneId,
  UpdateSceneReq request, {
  Function(Scene)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}",
    request,
    ok: (data) {
      if (ok != null) ok(Scene.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId--
///
/// request: DeleteSceneReq
/// response:
Future deleteScene(
  int id,
  int actId,
  int sceneId,
  DeleteSceneReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId/frames--
///
/// request: CreateFrameReq
/// response: Frame
Future createFrame(
  int id,
  int actId,
  int sceneId,
  CreateFrameReq request, {
  Function(Frame)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}/frames",
    request,
    ok: (data) {
      if (ok != null) ok(Frame.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId/frames--
///
/// request: ListFramesReq
/// response: ListFramesResp
Future listFrames(
  int id,
  int actId,
  int sceneId, {
  Function(ListFramesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}/frames",
    ok: (data) {
      if (ok != null) ok(ListFramesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId/frames/:frameId--
///
/// request: GetFrameReq
/// response: Frame
Future getFrame(
  int id,
  int actId,
  int sceneId,
  int frameId, {
  Function(Frame)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}/frames/${frameId}",
    ok: (data) {
      if (ok != null) ok(Frame.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId/frames/:frameId--
///
/// request: UpdateFrameReq
/// response: Frame
Future updateFrame(
  int id,
  int actId,
  int sceneId,
  int frameId,
  UpdateFrameReq request, {
  Function(Frame)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}/frames/${frameId}",
    request,
    ok: (data) {
      if (ok != null) ok(Frame.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId/frames/:frameId--
///
/// request: DeleteFrameReq
/// response:
Future deleteFrame(
  int id,
  int actId,
  int sceneId,
  int frameId,
  DeleteFrameReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}/frames/${frameId}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/:sceneId/frames/reorder--
///
/// request: ReorderFramesReq
/// response:
Future reorderFrames(
  int id,
  int actId,
  int sceneId,
  ReorderFramesReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/${sceneId}/frames/reorder",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/:actId/scenes/reorder--
///
/// request: ReorderScenesReq
/// response:
Future reorderScenes(
  int id,
  int actId,
  ReorderScenesReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    "/api/screenplay/screenplays/${id}/acts/${actId}/scenes/reorder",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/acts/reorder--
///
/// request: ReorderActsReq
/// response:
Future reorderActs(
  int id,
  ReorderActsReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    "/api/screenplay/screenplays/${id}/acts/reorder",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/screenplay/screenplays/:id/tree--
///
/// request: GetScreenplayTreeReq
/// response: GetScreenplayTreeResp
Future getScreenplayTree(
  int id, {
  Function(GetScreenplayTreeResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/screenplay/screenplays/${id}/tree",
    ok: (data) {
      if (ok != null) ok(GetScreenplayTreeResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

Future likeScreenplay(
  int id, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/api/screenplay/screenplays/$id/like',
    const {},
    ok: (_) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

Future unlikeScreenplay(
  int id, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/api/screenplay/screenplays/$id/like',
    const {},
    ok: (_) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

Future favoriteScreenplay(
  int id, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/api/screenplay/screenplays/$id/favorite',
    const {},
    ok: (_) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

Future unfavoriteScreenplay(
  int id, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/api/screenplay/screenplays/$id/favorite',
    const {},
    ok: (_) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}
