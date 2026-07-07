import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/user/data/user-api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_session.dart';

/// Bridges legacy [AuthRepository] singleton during Riverpod migration.
final authRepositoryProvider = ChangeNotifierProvider<AuthRepository>((ref) {
  return AuthRepository.instance;
});

/// Immutable session snapshot; rebuilds when [AuthRepository] notifies.
final authSessionProvider = Provider<AuthSession>((ref) {
  ref.watch(authRepositoryProvider);
  final repo = AuthRepository.instance;
  return AuthSession(
    profile: repo.profile,
    hasToken: repo.hasAuthToken,
  );
});

final authProfileProvider = Provider<Profile?>((ref) {
  return ref.watch(authSessionProvider).profile;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider).isLoggedIn;
});
