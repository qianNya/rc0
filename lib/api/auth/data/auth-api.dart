// --C:\Users\qianlNya\GolandProjects\rc0-go\service\auth\api\auth--

class LoginReq {
  final String username;

  final String password;
  LoginReq({required this.username, required this.password});
  factory LoginReq.fromJson(Map<String, dynamic> m) {
    return LoginReq(
      username: m['username'] ?? "",
      password: m['password'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class LoginResp {
  final String accessToken;

  final num expiresIn;

  final String tokenType;
  LoginResp({
    required this.accessToken,
    required this.expiresIn,
    required this.tokenType,
  });
  factory LoginResp.fromJson(Map<String, dynamic> m) {
    return LoginResp(
      accessToken: m['access_token'] ?? "",
      expiresIn: m['expires_in'] ?? 0,
      tokenType: m['token_type'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
    };
  }
}

class PingResp {
  final String pong;
  PingResp({required this.pong});
  factory PingResp.fromJson(Map<String, dynamic> m) {
    return PingResp(pong: m['pong'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'pong': pong};
  }
}

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
    this.bio = '',
    this.level = 1,
    this.followerCount = 0,
    this.followingCount = 0,
    this.totalLikes = 0,
    this.screenplayCount = 0,
  });
  factory Profile.fromJson(Map<String, dynamic> m) {
    return Profile(
      id: m['id'] ?? 0,
      username: m['username'] ?? "",
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      avatar: m['avatar'] ?? "",
      bio: m['bio'] ?? '',
      level: m['level'] ?? 1,
      followerCount: m['follower_count'] ?? 0,
      followingCount: m['following_count'] ?? 0,
      totalLikes: m['total_likes'] ?? 0,
      screenplayCount: m['screenplay_count'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
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
    this.bio = '',
    this.level = 1,
    this.followerCount = 0,
    this.followingCount = 0,
    this.totalLikes = 0,
    this.screenplayCount = 0,
    this.isFollowing = false,
  });

  factory PublicUserProfile.fromJson(Map<String, dynamic> m) {
    return PublicUserProfile(
      id: m['id'] ?? 0,
      username: m['username'] ?? '',
      nickname: m['nickname'] ?? '',
      avatar: m['avatar'] ?? '',
      bio: m['bio'] ?? '',
      level: m['level'] ?? 1,
      followerCount: m['follower_count'] ?? 0,
      followingCount: m['following_count'] ?? 0,
      totalLikes: m['total_likes'] ?? 0,
      screenplayCount: m['screenplay_count'] ?? 0,
      isFollowing: m['is_following'] == true,
    );
  }
}

class RegisterReq {
  final String username;

  final String password;

  final String nickname;

  final String email;

  final String phone;
  RegisterReq({
    required this.username,
    required this.password,
    required this.nickname,
    required this.email,
    required this.phone,
  });
  factory RegisterReq.fromJson(Map<String, dynamic> m) {
    return RegisterReq(
      username: m['username'] ?? "",
      password: m['password'] ?? "",
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'nickname': nickname,
      'email': email,
      'phone': phone,
    };
  }
}

class RegisterResp {
  final num id;

  final String username;
  RegisterResp({required this.id, required this.username});
  factory RegisterResp.fromJson(Map<String, dynamic> m) {
    return RegisterResp(id: m['id'] ?? 0, username: m['username'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username};
  }
}

class UpdateProfileReq {
  final String nickname;

  final String email;

  final String phone;

  final String avatar;

  final String password;
  UpdateProfileReq({
    required this.nickname,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.password,
  });
  factory UpdateProfileReq.fromJson(Map<String, dynamic> m) {
    return UpdateProfileReq(
      nickname: m['nickname'] ?? "",
      email: m['email'] ?? "",
      phone: m['phone'] ?? "",
      avatar: m['avatar'] ?? "",
      password: m['password'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'password': password,
    };
  }
}
