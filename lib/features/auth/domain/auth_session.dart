import 'package:flutter/foundation.dart';

import '../../../api/user/data/user-api.dart';

/// Immutable auth snapshot for Riverpod consumers (migration from ChangeNotifier).
@immutable
class AuthSession {
  const AuthSession({
    required this.profile,
    required this.hasToken,
  });

  final Profile? profile;
  final bool hasToken;

  bool get isLoggedIn => profile != null || hasToken;

  String? get displayName =>
      profile?.nickname.trim().isNotEmpty == true
          ? profile!.nickname
          : profile?.username;

  AuthSession copyWith({Profile? profile, bool? hasToken}) => AuthSession(
        profile: profile ?? this.profile,
        hasToken: hasToken ?? this.hasToken,
      );
}
