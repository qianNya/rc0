import 'dart:async';



import 'package:flutter/foundation.dart';



import '../../../api/auth/api/auth-api.dart' as auth_api;

import '../../../api/auth/data/auth-api.dart';

import '../../../api/auth/vars/kv.dart';

import '../../../api/user/api/user-api.dart' as user_api;

import '../../../api/user/data/user-api.dart';

import '../../../core/network/api_callback.dart';



class AuthRepository extends ChangeNotifier {

  AuthRepository._();



  static final AuthRepository instance = AuthRepository._();



  Profile? _profile;

  bool _initialized = false;



  Profile? get profile => _profile;



  bool get isLoggedIn => _profile != null || _hasToken;

  /// True when persisted tokens exist (session may still be loading profile).
  bool get hasAuthToken => _hasToken;



  bool _hasToken = false;

  bool _recoveringSession = false;

  Future<bool>? _handleUnauthorizedFuture;



  Future<void> initialize() async {

    if (_initialized) return;

    _initialized = true;



    final tokens = await getTokens();

    _hasToken = tokens != null;

    if (tokens != null) {
      // Do not block runApp on profile fetch — network can hang on cold start.
      unawaited(
        _fetchProfile().timeout(
          const Duration(seconds: 8),
          onTimeout: () {},
        ),
      );
    }

    notifyListeners();

  }



  Future<String?> login({

    required String username,

    required String password,

  }) async {

    final completer = Completer<String?>();



    await auth_api.login(

      LoginReq(username: username, password: password),

      ok: (resp) async {

        await setTokens(toStoredTokens(resp.tokens));

        _hasToken = true;

        await _fetchProfile();

        completer.complete(null);

      },

      fail: completer.complete,

    );



    final error = await completer.future;

    if (error == null) notifyListeners();

    return error;

  }



  Future<String?> register({

    required String username,

    required String password,

    String? email,

  }) async {

    final resolvedEmail = (email?.trim().isNotEmpty ?? false)

        ? email!.trim()

        : '$username@local.rc0';

    final (_, error) = await apiCallback<RegisterResp>(

      ({ok, fail, eventually}) => auth_api.register(

        RegisterReq(

          username: username,

          password: password,

          nickname: username,

          email: resolvedEmail,

        ),

        ok: ok,

        fail: fail,

        eventually: eventually,

      ),

    );

    return error;

  }



  Future<String?> registerAndLogin({

    required String username,

    required String password,

    String? email,

  }) async {

    final registerError = await register(

      username: username,

      password: password,

      email: email,

    );

    if (registerError != null) return registerError;

    return login(username: username, password: password);

  }



  Future<bool> tryRefreshToken() async {

    final tokens = await getTokens();

    if (tokens == null || tokens.refreshToken.trim().isEmpty) {

      return false;

    }



    final (refreshed, error) = await apiCallback<AuthTokens>(

      ({ok, fail, eventually}) => auth_api.refreshToken(

        RefreshTokenReq(refreshToken: tokens.refreshToken),

        ok: ok,

        fail: fail,

        eventually: eventually,

      ),

    );

    if (error != null || refreshed == null) return false;



    await setTokens(toStoredTokens(refreshed));

    _hasToken = true;

    notifyListeners();

    return true;

  }



  Future<void> logout() async {

    await removeTokens();

    _profile = null;

    _hasToken = false;

    notifyListeners();

  }



  /// Handles HTTP 401: tries refresh first, clears session if needed.
  /// Returns true when the global "登录已过期" snackbar should be suppressed.
  Future<bool> handleUnauthorized() async {
    final inFlight = _handleUnauthorizedFuture;
    if (inFlight != null) return inFlight;

    final future = _handleUnauthorizedImpl();
    _handleUnauthorizedFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_handleUnauthorizedFuture, future)) {
        _handleUnauthorizedFuture = null;
      }
    }
  }

  Future<bool> _handleUnauthorizedImpl() async {
    if (!_recoveringSession) {
      _recoveringSession = true;
      try {
        if (await tryRefreshToken()) return true;
      } finally {
        _recoveringSession = false;
      }
    }

    final hadSession = _hasToken || _profile != null;
    if (!hadSession) return true;

    await removeTokens();
    _profile = null;
    _hasToken = false;
    notifyListeners();
    return false;
  }



  Future<void> refreshProfile() => _fetchProfile();



  Future<String?> updateProfile(UpdateProfileReq request) async {

    final (profile, error) = await apiCallback<Profile>(

      ({ok, fail, eventually}) => user_api.updateProfile(

        request,

        ok: ok,

        fail: fail,

        eventually: eventually,

      ),

    );

    if (error != null) return error;

    if (profile != null) {

      _profile = profile;

      notifyListeners();

    }

    return null;

  }



  Future<String?> updateProfileFields({

    required String nickname,

    required String bio,

    required String email,

    required String phone,

    required String avatar,

    required String backgroundUrl,

  }) {

    return updateProfile(

      UpdateProfileReq(

        nickname: nickname,

        bio: bio,

        email: email,

        phone: phone,

        avatar: avatar,

        backgroundUrl: backgroundUrl,

      ),

    );

  }



  Future<void> _fetchProfile() async {

    _profile = await apiCallbackOptional(user_api.getProfile);

    notifyListeners();

  }

}


