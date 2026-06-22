import 'dart:io';

import '../../http/api_client.dart';
import '../data/screenplay-api.dart';

const _defaultPublishStatus = 1;

Map<String, String> _buildScreenplayListQuery({
  required int page,
  required int pageSize,
  int? kind,
  int? publishStatus,
  String? sort,
  String? q,
  int? tagId,
  int? creator,
}) {
  final query = <String, String>{
    'page': '$page',
    'page_size': '$pageSize',
  };
  if (kind != null) query['kind'] = '$kind';
  if (publishStatus != null && publishStatus != _defaultPublishStatus) {
    query['publish_status'] = '$publishStatus';
  }
  final trimmedSort = sort?.trim();
  if (trimmedSort != null && trimmedSort.isNotEmpty) {
    query['sort'] = trimmedSort;
  }
  final trimmedQ = q?.trim();
  if (trimmedQ != null && trimmedQ.isNotEmpty) {
    query['q'] = trimmedQ;
  }
  if (tagId != null) query['tag_id'] = '$tagId';
  if (creator != null) query['creator'] = '$creator';
  return query;
}

Future listScreenplays({
  int page = 1,
  int pageSize = 20,
  int? kind,
  int? publishStatus,
  String? sort,
  String? q,
  int? tagId,
  int? creator,
  Function(ListScreenplaysResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/screenplays',
    query: _buildScreenplayListQuery(
      page: page,
      pageSize: pageSize,
      kind: kind,
      publishStatus: publishStatus,
      sort: sort,
      q: q,
      tagId: tagId,
      creator: creator,
    ),
    ok: (data) => ok?.call(ListScreenplaysResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createScreenplay(
  CreateScreenplayReq request, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/screenplays',
    request.toJson(),
    ok: (data) => ok?.call(Screenplay.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateScreenplay(
  int id,
  Map<String, dynamic> body, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/screenplays/$id',
    body,
    ok: (data) => ok?.call(Screenplay.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getScreenplayTree(
  int id, {
  Function(GetScreenplayTreeResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/screenplays/$id/tree',
    ok: (data) => ok?.call(GetScreenplayTreeResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getScreenplayDetail(
  int id, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/screenplays/$id/detail',
    ok: (data) => ok?.call(Screenplay.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future uploadScreenplayCover(
  int id,
  File file, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final bytes = await file.readAsBytes();
  final name = file.path.split(Platform.pathSeparator).last;
  await apiMultipart(
    '/screenplays/$id/cover',
    fileField: 'file',
    bytes: bytes,
    filename: name.isNotEmpty ? name : 'cover.jpg',
    ok: (data) => ok?.call(Screenplay.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future publishScreenplay(
  int id, {
  Function(Screenplay)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/screenplays/$id/publish',
    const {},
    ok: (data) => ok?.call(Screenplay.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createAct(
  int screenplayId,
  Map<String, dynamic> body, {
  Function(Act)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/screenplays/$screenplayId/acts',
    body,
    ok: (data) => ok?.call(Act.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateAct(
  int screenplayId,
  int actId,
  Map<String, dynamic> body, {
  Function(Act)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/screenplays/$screenplayId/acts/$actId',
    body,
    ok: (data) => ok?.call(Act.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteAct(
  int screenplayId,
  int actId, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/screenplays/$screenplayId/acts/$actId',
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future createScene(
  int screenplayId,
  int actId,
  Map<String, dynamic> body, {
  Function(Scene)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/screenplays/$screenplayId/acts/$actId/scenes',
    body,
    ok: (data) => ok?.call(Scene.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateScene(
  int screenplayId,
  int actId,
  int sceneId,
  Map<String, dynamic> body, {
  Function(Scene)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/screenplays/$screenplayId/acts/$actId/scenes/$sceneId',
    body,
    ok: (data) => ok?.call(Scene.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteScene(
  int screenplayId,
  int actId,
  int sceneId, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/screenplays/$screenplayId/acts/$actId/scenes/$sceneId',
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future createFrame(
  int screenplayId,
  int actId,
  int sceneId,
  Map<String, dynamic> body, {
  Function(Frame)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/screenplays/$screenplayId/acts/$actId/scenes/$sceneId/frames',
    body,
    ok: (data) => ok?.call(Frame.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateFrame(
  int screenplayId,
  int actId,
  int sceneId,
  int frameId,
  Map<String, dynamic> body, {
  Function(Frame)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/screenplays/$screenplayId/acts/$actId/scenes/$sceneId/frames/$frameId',
    body,
    ok: (data) => ok?.call(Frame.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteFrame(
  int screenplayId,
  int actId,
  int sceneId,
  int frameId, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/screenplays/$screenplayId/acts/$actId/scenes/$sceneId/frames/$frameId',
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteScreenplay(
  int id, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/screenplays/$id',
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}
