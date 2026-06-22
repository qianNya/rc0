class Tokens {
  final String accessToken;
  final int accessExpire;
  final String refreshToken;
  final int refreshExpire;
  final int refreshAfter;

  Tokens({
    required this.accessToken,
    required this.accessExpire,
    required this.refreshToken,
    required this.refreshExpire,
    required this.refreshAfter,
  });

  factory Tokens.fromJson(Map<String, dynamic> m) {
    final expiresIn = m['expires_in'] ?? m['access_expire'] ?? 0;
    return Tokens(
      accessToken: m['access_token'] ?? '',
      accessExpire: expiresIn is num ? expiresIn.toInt() : 0,
      refreshToken: m['refresh_token'] ?? '',
      refreshExpire: (m['refresh_expire'] as num?)?.toInt() ?? 0,
      refreshAfter: (m['refresh_after'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'access_expire': accessExpire,
      'refresh_token': refreshToken,
      'refresh_expire': refreshExpire,
      'refresh_after': refreshAfter,
    };
  }
}
