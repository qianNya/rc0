import 'dart:io';
import 'dart:convert';
import '../../http/api_auth_error.dart';
import '../../http/network_error.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../vars/kv.dart';
import '../vars/vars.dart';

/// send request with post method
Future apiPost(
  String path,
  dynamic data, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await _apiRequest(
    'POST',
    path,
    data,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

/// send request with get method
Future apiGet(
  String path, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await _apiRequest(
    'GET',
    path,
    null,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

/// send request with put method
Future apiPut(
  String path,
  dynamic data, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await _apiRequest(
    'PUT',
    path,
    data,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

/// send request with delete method
Future apiDelete(
  String path,
  dynamic data, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await _apiRequest(
    'DELETE',
    path,
    data,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

String _encodeBody(dynamic data) {
  if (data == null) return '';
  if (data is Map) return jsonEncode(data);
  return jsonEncode((data as dynamic).toJson());
}

Future _apiRequest(
  String method,
  String path,
  dynamic data, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  var tokens = await getTokens();
  try {
    final client = HttpClient();
    final uri = Uri.parse(serverHost + path);
    final HttpClientRequest r;
    switch (method) {
      case 'POST':
        r = await client.postUrl(uri);
        break;
      case 'PUT':
        r = await client.putUrl(uri);
        break;
      case 'DELETE':
        r = await client.deleteUrl(uri);
        break;
      default:
        r = await client.getUrl(uri);
    }

    final strData = _encodeBody(data);
    if (method != 'GET' && strData.isNotEmpty) {
      r.headers.set('Content-Type', 'application/json; charset=utf-8');
      r.headers.set('Content-Length', utf8.encode(strData).length);
    }
    if (tokens != null) {
      r.headers.set('Authorization', 'Bearer ${tokens.accessToken}');
    }
    if (header != null) {
      header.forEach((k, v) {
        r.headers.set(k, v);
      });
    }

    if (strData.isNotEmpty) {
      r.write(strData);
    }
    final rp = await r.close();
    final body = await rp.transform(utf8.decoder).join();
    print('${rp.statusCode} - $path');
    print('-- request --');
    print(strData);
    print('-- response --');
    print('$body \n');

    if (rp.statusCode == 404) {
      if (fail != null) fail('404 not found');
      return;
    }

    if (body.trim().isEmpty) {
      if (rp.statusCode >= 200 && rp.statusCode < 300) {
        if (ok != null) ok({});
      } else {
        if (rp.statusCode == 401) {
          await AuthRepository.instance.handleUnauthorized();
        }
        if (fail != null) fail('HTTP ${rp.statusCode}');
      }
      return;
    }

    final base = jsonDecode(body) as Map<String, dynamic>;
    if (rp.statusCode == 200) {
      if (base['code'] != 0) {
        final message = apiErrorMessage(base, rp.statusCode);
        if (isUnauthorizedResponse(base, rp.statusCode)) {
          await AuthRepository.instance.handleUnauthorized();
        }
        if (fail != null) fail(message);
      } else {
        if (ok != null) ok(base['data'] as Map<String, dynamic>? ?? {});
      }
    } else {
      final message = apiErrorMessage(base, rp.statusCode);
      if (isUnauthorizedResponse(base, rp.statusCode)) {
        await AuthRepository.instance.handleUnauthorized();
      }
      if (fail != null) fail(message);
    }
  } catch (e) {
    if (fail != null) fail(friendlyNetworkError(e));
  } finally {
    if (eventually != null) eventually();
  }
}
