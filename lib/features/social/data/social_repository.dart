import 'package:flutter/foundation.dart';

import '../../../api/community/api/community-api.dart' as community_api;
import '../../../api/user/api/user-api.dart' as user_api;
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../auth/data/auth_repository.dart';
import '../../user/data/user_profile_repository.dart';

class SocialRepository extends ChangeNotifier {
  SocialRepository._();

  static final SocialRepository instance = SocialRepository._();

  Future<String?> followUser(int userId) async {
    final err = await apiCallbackVoid(
      ({ok, fail, eventually}) => user_api.followUser(
        userId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (err == null) {
      UserProfileRepository.instance.updateCachedFollow(
        userId,
        isFollowing: true,
        followerDelta: 1,
      );
      notifyListeners();
    }
    return err;
  }

  Future<String?> unfollowUser(int userId) async {
    final err = await apiCallbackVoid(
      ({ok, fail, eventually}) => user_api.unfollowUser(
        userId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (err == null) {
      UserProfileRepository.instance.updateCachedFollow(
        userId,
        isFollowing: false,
        followerDelta: -1,
      );
      notifyListeners();
    }
    return err;
  }

  Future<Screenplay?> toggleLikeScreenplay(Screenplay screenplay) async {
    final remoteId = screenplay.remoteScreenplayId ?? int.tryParse(screenplay.id);
    if (remoteId == null || remoteId <= 0) return null;

    final err = await apiCallbackVoid(
      ({ok, fail, eventually}) => community_api.toggleLike(
        remoteId,
        ok: (_) => ok?.call(),
        fail: fail,
        eventually: eventually,
      ),
    );

    if (err != null) return null;

    final nextLiked = !screenplay.isLiked;
    final delta = nextLiked ? 1 : -1;
    return screenplay.copyWith(
      isLiked: nextLiked,
      likes: (screenplay.likes + delta).clamp(0, 1 << 30),
    );
  }

  bool isCurrentUserOwner(Screenplay screenplay) {
    final profile = AuthRepository.instance.profile;
    if (profile == null) return screenplay.isLocal;
    if (screenplay.isLocal) return true;
    final ownerId = screenplay.ownerUserId;
    if (ownerId == null || ownerId <= 0) return false;
    return ownerId == profile.id.toInt();
  }
}
