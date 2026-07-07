import 'package:flutter/foundation.dart';

import '../../api/user/data/user-api.dart';
import '../../features/auth/data/auth_repository.dart';

/// Non-UI auth access during Riverpod migration.
///
/// Repositories and services use this instead of [AuthRepository.instance]
/// so call sites can later switch to injected session without wide refactors.
abstract final class AuthBridge {
  static AuthRepository get repository => AuthRepository.instance;

  static bool get isLoggedIn => repository.isLoggedIn;

  static bool get hasAuthToken => repository.hasAuthToken;

  static Profile? get profile => repository.profile;

  static void addListener(VoidCallback listener) =>
      repository.addListener(listener);

  static void removeListener(VoidCallback listener) =>
      repository.removeListener(listener);
}
