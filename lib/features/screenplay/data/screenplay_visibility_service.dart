import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../core/network/api_callback.dart';

/// Updates screenplay visibility via PUT `/screenplays/{id}`.
class ScreenplayVisibilityService {
  ScreenplayVisibilityService._();

  static final ScreenplayVisibilityService instance =
      ScreenplayVisibilityService._();

  Future<String?> updateVisibility(int remoteId, int visibility) {
    return apiCallbackMutate(
      ({ok, fail, eventually}) => screenplay_api.updateScreenplay(
        remoteId,
        {'visibility': visibility},
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
  }
}
