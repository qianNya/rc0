import '../data/tokens.dart';

class LoginReq {
  final String username;
  final String password;

  LoginReq({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class RegisterReq {
  final String username;
  final String password;
  final String email;
  final String nickname;

  RegisterReq({
    required this.username,
    required this.password,
    required this.email,
    required this.nickname,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'email': email,
        'nickname': nickname,
      };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final num expiresIn;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> m) {
    return AuthTokens(
      accessToken: m['access_token'] ?? '',
      refreshToken: m['refresh_token'] ?? '',
      tokenType: m['token_type'] ?? 'Bearer',
      expiresIn: m['expires_in'] ?? 0,
    );
  }
}

class AuthSessionResp {
  final AuthTokens tokens;

  AuthSessionResp({required this.tokens});

  factory AuthSessionResp.fromJson(Map<String, dynamic> m) {
    return AuthSessionResp(tokens: AuthTokens.fromJson(m['tokens'] ?? m));
  }
}

class RegisterResp {
  final num id;
  final String username;

  RegisterResp({required this.id, required this.username});

  factory RegisterResp.fromJson(Map<String, dynamic> m) {
    final user = m['user'];
    if (user is Map<String, dynamic>) {
      return RegisterResp(
        id: user['id'] ?? 0,
        username: user['username'] ?? '',
      );
    }
    return RegisterResp(id: m['id'] ?? 0, username: m['username'] ?? '');
  }
}

class RefreshTokenReq {
  final String refreshToken;

  RefreshTokenReq({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

Tokens toStoredTokens(AuthTokens tokens) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return Tokens(
    accessToken: tokens.accessToken,
    accessExpire: now + tokens.expiresIn.toInt(),
    refreshToken: tokens.refreshToken,
    refreshExpire: 0,
    refreshAfter: 0,
  );
}
