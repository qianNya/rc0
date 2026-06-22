import 'dart:convert';
import 'dart:io';

import '../auth/vars/kv.dart';
import '../auth/vars/vars.dart';
import 'api_auth_error.dart';
import 'api_headers.dart';
import 'network_error.dart';

Future<void> apiPost(
  String path,
  dynamic data, {
  Map<String, String>? header,
  void Function(Map<String, dynamic>)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  return _apiRequest(
    'POST',
    path,
    data,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future<void> apiGet(
  String path, {
  Map<String, String>? header,
  Map<String, String>? query,
  void Function(Map<String, dynamic>)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  return _apiRequest(
    'GET',
    path,
    null,
    header: header,
    query: query,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future<void> apiDelete(
  String path, {
  dynamic body,
  Map<String, String>? header,
  Map<String, String>? query,
  void Function(Map<String, dynamic>)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) {
  return _apiRequest(
    'DELETE',
    path,
    body,
    header: header,
    query: query,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future<void> _apiRequest(
  String method,
  String path,
  dynamic data, {
  Map<String, String>? header,
  Map<String, String>? query,
  void Function(Map<String, dynamic>)? ok,
  void Function(String)? fail,
  void Function()? eventually,
}) async {
  final tokens = await getTokens();
  final client = HttpClient();

  try {
    final uri = _buildUri(path, query);
    final request = await switch (method) {
      'POST' => client.postUrl(uri),
      'DELETE' => client.deleteUrl(uri),
      _ => client.getUrl(uri),
    };

    var bodyText = '';
    if (data != null) {
      bodyText = jsonEncode(data);
    }
    if (method == 'POST' || method == 'DELETE') {
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      if (bodyText.isNotEmpty) {
        request.headers.set('Content-Length', utf8.encode(bodyText).length);
      }
    }
    if (tokens != null && tokens.accessToken.trim().isNotEmpty) {
      request.headers.set(
        'Authorization',
        authorizationHeader(tokens.accessToken),
      );
    }
    header?.forEach(request.headers.set);

    if (bodyText.isNotEmpty) {
      request.write(bodyText);
    }

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 404) {
      final message = '404 not found';
      if (fail != null) fail(message);
      return;
    }

    final base = jsonDecode(responseBody) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      if (base['code'] != 0) {
        final message = apiErrorMessage(base);
        await notifyApiUnauthorizedIfNeeded(message);
        if (fail != null) fail(message);
      } else {
        ok?.call((base['data'] as Map<String, dynamic>?) ?? <String, dynamic>{});
      }
      return;
    }

    final message = apiErrorMessage(base);
    await notifyApiUnauthorizedIfNeeded(message);
    if (fail != null) fail(message);
  } catch (e) {
    if (fail != null) fail(friendlyNetworkError(e));
  } finally {
    client.close();
    eventually?.call();
  }
}

Uri _buildUri(String path, Map<String, String>? query) {
  final uri = Uri.parse('$serverHost$path');
  if (query == null || query.isEmpty) return uri;
  return uri.replace(
    queryParameters: {...uri.queryParameters, ...query},
  );
}
