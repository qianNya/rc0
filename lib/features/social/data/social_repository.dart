import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../api/admin/api/admin_api_ext.dart' as admin_api;
import '../../../api/screenplay/api/screenplay_api_ext.dart' as screenplay_api;
import '../../../core/domain/screenplay/screenplay.dart';
import '../../auth/data/auth_repository.dart';
import '../../user/data/user_profile_repository.dart';

class SocialRepository extends ChangeNotifier {
  SocialRepository._();

  static final SocialRepository instance = SocialRepository._();

  Future<String?> followUser(int userId) async {
    final completer = Completer<String?>();
    await admin_api.followUser(
      userId,
      ok: () {
        UserProfileRepository.instance.updateCachedFollow(userId, isFollowing: true, followerDelta: 1);
        completer.complete(null);
      },
      fail: completer.complete,
    );
    final err = await completer.future;
    if (err == null) notifyListeners();
    return err;
  }

  Future<String?> unfollowUser(int userId) async {
    final completer = Completer<String?>();
    await admin_api.unfollowUser(
      userId,
      ok: () {
        UserProfileRepository.instance.updateCachedFollow(userId, isFollowing: false, followerDelta: -1);
        completer.complete(null);
      },
      fail: completer.complete,
    );
    final err = await completer.future;
    if (err == null) notifyListeners();
    return err;
  }

  Future<Screenplay?> toggleLikeScreenplay(Screenplay screenplay) async {
    final remoteId = screenplay.remoteScreenplayId ?? int.tryParse(screenplay.id);
    if (remoteId == null || remoteId <= 0) return null;

    final completer = Completer<String?>();
    if (screenplay.isLiked) {
      await screenplay_api.unlikeScreenplay(remoteId, ok: () => completer.complete(null), fail: completer.complete);
    } else {
      await screenplay_api.likeScreenplay(remoteId, ok: () => completer.complete(null), fail: completer.complete);
    }
    if (await completer.future != null) return null;

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
