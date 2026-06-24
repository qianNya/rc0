class Profile {
  final num id;
  final String username;
  final String nickname;
  final String email;
  final String phone;
  final String avatar;
  final String bio;
  final num level;
  final num followerCount;
  final num followingCount;
  final num totalLikes;
  final num screenplayCount;

  Profile({
    required this.id,
    required this.username,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.bio,
    required this.level,
    required this.followerCount,
    required this.followingCount,
    required this.totalLikes,
    required this.screenplayCount,
  });

  factory Profile.fromJson(Map<String, dynamic> m) {
    return Profile(
      id: m['id'] ?? 0,
      username: m['username'] ?? '',
      nickname: m['nickname'] ?? '',
      email: m['email'] ?? '',
      phone: m['phone'] ?? '',
      avatar: m['avatar'] ?? '',
      bio: m['bio'] ?? '',
      level: m['level'] ?? 0,
      followerCount: m['follower_count'] ?? 0,
      followingCount: m['following_count'] ?? 0,
      totalLikes: m['total_likes'] ?? 0,
      screenplayCount: m['screenplay_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'nickname': nickname,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'bio': bio,
        'level': level,
        'follower_count': followerCount,
        'following_count': followingCount,
        'total_likes': totalLikes,
        'screenplay_count': screenplayCount,
      };
}

class UpdateProfileReq {
  final String nickname;
  final String email;
  final String phone;
  final String avatar;
  final String bio;

  UpdateProfileReq({
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.bio,
  });

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{};
    if (nickname.isNotEmpty) payload['nickname'] = nickname;
    if (email.isNotEmpty) payload['email'] = email;
    if (phone.isNotEmpty) payload['phone'] = phone;
    if (avatar.isNotEmpty) payload['avatar'] = avatar;
    if (bio.isNotEmpty) payload['bio'] = bio;
    return payload;
  }
}

class PublicUserProfile {
  final num id;
  final String username;
  final String nickname;
  final String avatar;
  final String bio;
  final num level;
  final num followerCount;
  final num followingCount;
  final num totalLikes;
  final num screenplayCount;
  final bool isFollowing;

  PublicUserProfile({
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

  factory PublicUserProfile.fromJson(Map<String, dynamic> m) {
    return PublicUserProfile(
      id: m['id'] ?? 0,
      username: m['username'] ?? '',
      nickname: m['nickname'] ?? '',
      avatar: m['avatar'] ?? '',
      bio: m['bio'] ?? '',
      level: m['level'] ?? 0,
      followerCount: m['follower_count'] ?? 0,
      followingCount: m['following_count'] ?? 0,
      totalLikes: m['total_likes'] ?? 0,
      screenplayCount: m['screenplay_count'] ?? 0,
      isFollowing: m['is_following'] ?? false,
    );
  }
}

class ScreenplayBrief {
  final num id;
  final String title;
  final String coverUrl;
  final num likeCount;
  final num viewCount;
  final num creatorId;
  final String creatorNickname;
  final String createAt;
  final num publishStatus;
  final num visibility;

  ScreenplayBrief({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.likeCount,
    required this.viewCount,
    required this.creatorId,
    required this.creatorNickname,
    required this.createAt,
    required this.publishStatus,
    required this.visibility,
  });

  factory ScreenplayBrief.fromJson(Map<String, dynamic> m) {
    final source = m['screenplay'] is Map<String, dynamic>
        ? m['screenplay'] as Map<String, dynamic>
        : m;
    final author = m['author'];
    var creatorId = source['creator_id'] ?? source['creator'] ?? 0;
    var creatorNickname = source['creator_nickname'] ?? '';
    if (author is Map<String, dynamic>) {
      creatorId = author['id'] ?? creatorId;
      creatorNickname = author['nickname'] ?? creatorNickname;
    }
    return ScreenplayBrief(
      id: source['id'] ?? 0,
      title: source['title'] ?? '',
      coverUrl: source['cover_url'] ?? '',
      likeCount: source['like_count'] ?? 0,
      viewCount: source['view_count'] ?? 0,
      creatorId: creatorId,
      creatorNickname: creatorNickname,
      createAt: source['create_at'] ?? source['created_at'] ?? '',
      publishStatus: source['publish_status'] ?? 1,
      visibility: source['visibility'] ?? 0,
    );
  }
}

class ListUserScreenplaysResp {
  final List<ScreenplayBrief> list;
  final num total;
  final num page;
  final num pageSize;

  ListUserScreenplaysResp({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ListUserScreenplaysResp.fromJson(Map<String, dynamic> m) {
    final rawItems = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    return ListUserScreenplaysResp(
      list: rawItems
          .map((i) => ScreenplayBrief.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: m['total'] ?? 0,
      page: m['page'] ?? 1,
      pageSize: m['page_size'] ?? 20,
    );
  }
}

class SpFavorite {
  final num id;
  final num screenplayId;
  final num userId;
  final num status;
  final String createAt;
  final String updateAt;

  SpFavorite({
    required this.id,
    required this.screenplayId,
    required this.userId,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });

  factory SpFavorite.fromJson(Map<String, dynamic> m) {
    return SpFavorite(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? m['id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? '',
      updateAt: m['update_at'] ?? '',
    );
  }
}

class SpLike {
  final num id;
  final num screenplayId;
  final num userId;
  final num status;
  final String createAt;
  final String updateAt;

  SpLike({
    required this.id,
    required this.screenplayId,
    required this.userId,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });

  factory SpLike.fromJson(Map<String, dynamic> m) {
    return SpLike(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? m['id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? '',
      updateAt: m['update_at'] ?? '',
    );
  }
}

class ListSpFavoritesResp {
  final List<SpFavorite> list;
  final num total;

  ListSpFavoritesResp({required this.list, required this.total});

  factory ListSpFavoritesResp.fromJson(Map<String, dynamic> m) {
    return ListSpFavoritesResp(
      list: ((m['list'] ?? []) as List<dynamic>).map((item) {
        if (item is Map<String, dynamic> && item.containsKey('screenplay_id')) {
          return SpFavorite.fromJson(item);
        }
        return SpFavorite.fromJson({
          'screenplay_id': (item as Map<String, dynamic>)['id'],
          'create_at': item['create_at'],
        });
      }).toList(),
      total: m['total'] ?? 0,
    );
  }
}

class ListSpLikesResp {
  final List<SpLike> list;
  final num total;

  ListSpLikesResp({required this.list, required this.total});

  factory ListSpLikesResp.fromJson(Map<String, dynamic> m) {
    return ListSpLikesResp(
      list: ((m['list'] ?? []) as List<dynamic>).map((item) {
        if (item is Map<String, dynamic> && item.containsKey('screenplay_id')) {
          return SpLike.fromJson(item);
        }
        return SpLike.fromJson({
          'screenplay_id': (item as Map<String, dynamic>)['id'],
          'create_at': item['create_at'],
        });
      }).toList(),
      total: m['total'] ?? 0,
    );
  }
}
