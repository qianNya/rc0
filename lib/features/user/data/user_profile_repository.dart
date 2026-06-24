import 'package:flutter/foundation.dart';

import '../../../api/user/api/user-api.dart' as user_api;
import '../../../api/user/data/user-api.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../auth/data/auth_repository.dart';
import 'user_screenplays_fetch.dart';

class UserProfileSummary {
  const UserProfileSummary({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.bio,
    required this.level,
    required this.followerCount,
    required this.followingCount,
    required this.totalLikes,
    required this.screenplayCount,
    required this.isFollowing,
  });

  final int id;
  final String username;
  final String nickname;
  final String avatar;
  final String bio;
  final int level;
  final int followerCount;
  final int followingCount;
  final int totalLikes;
  final int screenplayCount;
  final bool isFollowing;

  UserProfileSummary copyWith({
    int? followerDelta,
    bool? isFollowing,
  }) {
    return UserProfileSummary(
      id: id,
      username: username,
      nickname: nickname,
      avatar: avatar,
      bio: bio,
      level: level,
      followerCount: followerCount + (followerDelta ?? 0),
      followingCount: followingCount,
      totalLikes: totalLikes,
      screenplayCount: screenplayCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

UserProfileSummary _toSummary(PublicUserProfile profile) {
  return UserProfileSummary(
    id: profile.id.toInt(),
    username: profile.username,
    nickname: profile.nickname,
    avatar: profile.avatar,
    bio: profile.bio,
    level: profile.level.toInt(),
    followerCount: profile.followerCount.toInt(),
    followingCount: profile.followingCount.toInt(),
    totalLikes: profile.totalLikes.toInt(),
    screenplayCount: profile.screenplayCount.toInt(),
    isFollowing: profile.isFollowing,
  );
}

class UserProfileRepository extends ChangeNotifier {
  UserProfileRepository._();

  static final UserProfileRepository instance = UserProfileRepository._();

  final Map<int, UserProfileSummary> _cache = {};

  UserProfileSummary? cached(int userId) => _cache[userId];

  Future<void> refreshMyStats() async {
    await AuthRepository.instance.refreshProfile();
    notifyListeners();
  }

  Future<UserProfileSummary?> fetchPublicProfile(int userId) async {
    final (profile, error) = await apiCallback<PublicUserProfile>(
      ({ok, fail, eventually}) => user_api.getPublicUserProfile(
        userId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return null;
    if (profile != null) {
      _cache[userId] = _toSummary(profile);
      notifyListeners();
    }
    return _cache[userId];
  }

  Future<({List<Screenplay> items, String? error})> listUserScreenplays(
    int userId,
  ) async {
    final result = await fetchUserScreenplaysPage(
      userId: userId,
      page: 1,
      pageSize: 20,
    );
    return (items: result.items, error: result.error);
  }

  void updateCachedFollow(
    int userId, {
    required bool isFollowing,
    int followerDelta = 0,
  }) {
    final existing = _cache[userId];
    if (existing == null) return;
    _cache[userId] = existing.copyWith(
      followerDelta: followerDelta,
      isFollowing: isFollowing,
    );
    notifyListeners();
  }
}

