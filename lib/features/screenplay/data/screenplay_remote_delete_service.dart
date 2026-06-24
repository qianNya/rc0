import 'dart:async';

import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import 'screenplay_delete_options.dart';

class RemoteDeleteResult {
  const RemoteDeleteResult({
    required this.success,
    this.error,
    this.warning,
  });

  final bool success;
  final String? error;
  final String? warning;

  static const successResult = RemoteDeleteResult(success: true);
}

class ScreenplayRemoteDeleteService {
  ScreenplayRemoteDeleteService._();

  static final ScreenplayRemoteDeleteService instance =
      ScreenplayRemoteDeleteService._();

  Future<RemoteDeleteResult> deleteScreenplay(int remoteId) async {
    final completer = Completer<RemoteDeleteResult>();

    await screenplay_api.deleteScreenplay(
      remoteId,
      ok: () => completer.complete(RemoteDeleteResult.successResult),
      fail: (msg) {
        if (isRemoteNotFoundError(msg)) {
          completer.complete(
            const RemoteDeleteResult(
              success: true,
              warning: '云端副本已不存在',
            ),
          );
        } else {
          completer.complete(RemoteDeleteResult(success: false, error: msg));
        }
      },
    );

    return completer.future;
  }

  Future<String?> deleteScreenplayLegacy(int remoteId) async {
    final result = await deleteScreenplay(remoteId);
    return result.success ? result.warning : result.error;
  }

  Future<String?> deleteAct(int remoteId, int actId) async {
    final completer = Completer<String?>();

    await screenplay_api.deleteAct(
      remoteId,
      actId,
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
      ok: () => completer.complete(null),
      fail: completer.complete,
    );

    return completer.future;
  }
}
