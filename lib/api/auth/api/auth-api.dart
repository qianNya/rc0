import 'api.dart';
import '../data/auth-api.dart';

/// auth-api

/// --/api/auth/login--
///
/// request: LoginReq
/// response: LoginResp
Future login(
  LoginReq request, {
  Function(LoginResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/auth/login",
    request,
    ok: (data) {
      if (ok != null) ok(LoginResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/auth/register--
///
/// request: RegisterReq
/// response: RegisterResp
Future register(
  RegisterReq request, {
  Function(RegisterResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/auth/register",
    request,
    ok: (data) {
      if (ok != null) ok(RegisterResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/auth/ping--
///
/// request:
/// response: PingResp
Future ping({
  Function(PingResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/auth/ping",
    ok: (data) {
      if (ok != null) ok(PingResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}
