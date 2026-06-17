import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../api/auth/api/auth-api.dart' as auth_api;
import '../../../api/auth/data/auth-api.dart';
import '../../../api/http/api_headers.dart';
import '../../../api/admin/api/admin_api_ext.dart' as admin_api;
import '../../../api/admin/data/admin-api.dart';
import '../../../api/auth/data/tokens.dart';
import '../../../api/auth/vars/kv.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  Profile? _profile;
  bool _initialized = false;

  Profile? get profile => _profile;

  bool get isLoggedIn => _profile != null || _hasToken;

  bool _hasToken = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final tokens = await getTokens();
    _hasToken = tokens != null;
    if (tokens != null) {
      await _fetchProfile();
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
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await setTokens(
          Tokens(
            accessToken: authorizationHeader(resp.accessToken),
            accessExpire: now + resp.expiresIn.toInt(),
            refreshToken: '',
            refreshExpire: 0,
            refreshAfter: 0,
          ),
        );
        _hasToken = true;
        await _fetchProfile();
        completer.complete(null);
      },
      fail: (msg) => completer.complete(msg),
    );

    final error = await completer.future;
    if (error == null) notifyListeners();
    return error;
  }

  Future<String?> register({
    required String username,
    required String password,
    required String nickname,
    required String email,
    required String phone,
  }) async {
    final completer = Completer<String?>();

    await auth_api.register(
      RegisterReq(
        username: username,
        password: password,
        nickname: nickname,
        email: email,
        phone: phone,
      ),
      ok: (_) => completer.complete(null),
      fail: (msg) => completer.complete(msg),
    );

    return completer.future;
  }

  Future<void> logout() async {
    await removeTokens();
    _profile = null;
    _hasToken = false;
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    if (!_hasToken && _profile == null) return;
    await removeTokens();
    _profile = null;
    _hasToken = false;
    notifyListeners();
  }

  Future<void> refreshProfile() => _fetchProfile();

  Future<void> _fetchProfile() async {
    final completer = Completer<void>();

    await admin_api.getProfile(
      ok: (p) {
        _profile = p;
        completer.complete();
      },
      fail: (_) => completer.complete(),
    );

    await completer.future;
    notifyListeners();
  }
}
