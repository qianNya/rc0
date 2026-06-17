import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../api/admin/api/admin_api_ext.dart' as admin_api;
import '../../../api/admin/data/admin-api.dart';
import '../../auth/data/auth_repository.dart';

class UserProfileRepository extends ChangeNotifier {
  UserProfileRepository._();

  static final UserProfileRepository instance = UserProfileRepository._();

  final Map<int, PublicUserProfile> _cache = {};

  PublicUserProfile? cached(int userId) => _cache[userId];

  Future<void> refreshMyStats() async {
    await AuthRepository.instance.refreshProfile();
    notifyListeners();
  }

  Future<PublicUserProfile?> fetchPublicProfile(int userId) async {
    final completer = Completer<PublicUserProfile?>();
    await admin_api.getPublicUserProfile(
      userId,
      ok: (profile) {
        _cache[userId] = profile;
        completer.complete(profile);
      },
      fail: (msg) => completer.completeError(msg),
    );
    try {
      final profile = await completer.future;
      notifyListeners();
      return profile;
    } catch (_) {
      return null;
    }
  }

  void updateCachedFollow(int userId, {required bool isFollowing, int followerDelta = 0}) {
    final existing = _cache[userId];
    if (existing == null) return;
    _cache[userId] = PublicUserProfile(
      id: existing.id,
      username: existing.username,
      nickname: existing.nickname,
      avatar: existing.avatar,
      bio: existing.bio,
      level: existing.level,
      followerCount: existing.followerCount + followerDelta,
      followingCount: existing.followingCount,
      totalLikes: existing.totalLikes,
      screenplayCount: existing.screenplayCount,
      isFollowing: isFollowing,
    );
    notifyListeners();
  }
}
