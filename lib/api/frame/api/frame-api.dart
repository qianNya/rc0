import '../../http/api_client.dart';
import '../../screenplay/data/screenplay-api.dart';
import '../data/frame-api.dart';

Future getFrame(
  int frameId, {
  Function(FrameDetailResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/frames/$frameId',
    ok: (data) => ok?.call(FrameDetailResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getFrameDownloadUrl(
  int frameId, {
  Function(FrameDownloadResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/frames/$frameId/download',
    ok: (data) => ok?.call(FrameDownloadResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listSceneFrames(
  int sceneId, {
  Function(ListSceneFramesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/screenplay-scenes/$sceneId/frames',
    ok: (data) => ok?.call(ListSceneFramesResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future applyFramePreset(
  int frameId,
  int presetId, {
  Function(Frame)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/frames/$frameId/apply-preset',
    {'preset_id': presetId},
    ok: (data) => ok?.call(Frame.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
