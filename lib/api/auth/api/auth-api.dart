import '../../http/api_client.dart';
import '../data/auth-api.dart';

Future login(
  LoginReq request, {
  Function(AuthSessionResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/auth/login',
    request.toJson(),
    ok: (data) => ok?.call(AuthSessionResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future register(
  RegisterReq request, {
  Function(RegisterResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/auth/register',
    request.toJson(),
    ok: (data) => ok?.call(RegisterResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future refreshToken(
  RefreshTokenReq request, {
  Function(AuthTokens)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/auth/refresh',
    request.toJson(),
    ok: (data) => ok?.call(AuthTokens.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
