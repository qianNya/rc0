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
