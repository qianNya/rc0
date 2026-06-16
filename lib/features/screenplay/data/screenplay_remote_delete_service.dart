import 'dart:async';

import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../api/screenplay/data/screenplay-api.dart' as api;

class ScreenplayRemoteDeleteService {
  ScreenplayRemoteDeleteService._();

  static final ScreenplayRemoteDeleteService instance =
      ScreenplayRemoteDeleteService._();

  Future<String?> deleteScreenplay(int remoteId) async {
    final completer = Completer<String?>();

    await screenplay_api.deleteScreenplay(
      remoteId,
      api.DeleteScreenplayReq(id: remoteId),
      ok: () => completer.complete(null),
      fail: completer.complete,
    );

    return completer.future;
  }

  Future<String?> deleteAct(int remoteId, int actId) async {
    final completer = Completer<String?>();

    await screenplay_api.deleteAct(
      remoteId,
      actId,
      api.DeleteActReq(screenplayId: remoteId, actId: actId),
      ok: () => completer.complete(null),
      fail: completer.complete,
    );

    return completer.future;
  }

  Future<String?> deleteScene(
    int remoteId,
    int actId,
    int sceneId,
  ) async {
    final completer = Completer<String?>();

    await screenplay_api.deleteScene(
      remoteId,
      actId,
      sceneId,
      api.DeleteSceneReq(
        screenplayId: remoteId,
        actId: actId,
        sceneId: sceneId,
      ),
      ok: () => completer.complete(null),
      fail: completer.complete,
    );

    return completer.future;
  }

  Future<String?> deleteFrame(
    int remoteId,
    int actId,
    int sceneId,
    int frameId,
  ) async {
    final completer = Completer<String?>();

    await screenplay_api.deleteFrame(
      remoteId,
      actId,
      sceneId,
      frameId,
      api.DeleteFrameReq(
        screenplayId: remoteId,
        actId: actId,
        sceneId: sceneId,
        frameId: frameId,
      ),
      ok: () => completer.complete(null),
      fail: completer.complete,
    );

    return completer.future;
  }
}
