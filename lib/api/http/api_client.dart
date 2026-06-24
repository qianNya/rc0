import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../core/config/api_config.dart';
import '../../core/network/api_auth.dart';
import '../../core/network/api_error_presenter.dart';
import '../../core/network/api_headers.dart';
import '../../core/network/api_response_interceptor.dart';
import '../../core/network/network_error.dart';
import '../auth/vars/kv.dart';

const serverHost = ApiConfig.serverHost;
const _requestTimeout = Duration(seconds: 8);

Future apiGet(
  String path, {
  Map<String, String>? query,
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  var uri = Uri.parse(serverHost + path);
  if (query != null && query.isNotEmpty) {
    uri = uri.replace(queryParameters: query);
  }
  await _apiRequest(
    'GET',
    uri,
    null,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

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
    Uri.parse(serverHost + path),
    data,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

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
    Uri.parse(serverHost + path),
    data,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future apiDelete(
  String path, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await _apiRequest(
    'DELETE',
    Uri.parse(serverHost + path),
    null,
    header: header,
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future apiMultipart(
  String path, {
  required String fileField,
  required Uint8List bytes,
  required String filename,
  Map<String, String> fields = const {},
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  try {
    final tokens = await getTokens();
    final client = HttpClient()..connectionTimeout = _requestTimeout;
    final request = await client.postUrl(Uri.parse(serverHost + path));

    final boundary = '----Rc0Upload${DateTime.now().millisecondsSinceEpoch}';
    request.headers.set(
      'Content-Type',
      'multipart/form-data; boundary=$boundary',
    );
    if (tokens != null && tokens.accessToken.trim().isNotEmpty) {
      request.headers.set(
        'Authorization',
        authorizationHeader(tokens.accessToken),
      );
    }
    header?.forEach((k, v) => request.headers.set(k, v));

    final body = <int>[];
    void write(String s) => body.addAll(utf8.encode(s));

    for (final entry in fields.entries) {
      write('--$boundary\r\n');
      write('Content-Disposition: form-data; name="${entry.key}"\r\n\r\n');
      write('${entry.value}\r\n');
    }

    write('--$boundary\r\n');
    write(
      'Content-Disposition: form-data; name="$fileField"; filename="$filename"\r\n',
    );
    write('Content-Type: application/octet-stream\r\n\r\n');
    body.addAll(bytes);
    write('\r\n--$boundary--\r\n');

    request.contentLength = body.length;
    request.add(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    await _handleResponse(response.statusCode, responseBody, ok: ok, fail: fail);
  } catch (e) {
    _handleNetworkError(e, fail: fail);
  }
  eventually?.call();
}

Future _apiRequest(
  String method,
  Uri uri,
  dynamic data, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final tokens = await getTokens();
  try {
    final client = HttpClient()..connectionTimeout = _requestTimeout;
    late final HttpClientRequest request;
    switch (method) {
      case 'POST':
        request = await client.postUrl(uri);
      case 'PUT':
        request = await client.putUrl(uri);
      case 'DELETE':
        request = await client.deleteUrl(uri);
      default:
        request = await client.getUrl(uri);
    }

    var strData = '';
    if (data != null) {
      strData = jsonEncode(data);
    }
    if (method == 'POST' || method == 'PUT') {
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Content-Length', utf8.encode(strData).length);
    }
    if (tokens != null && tokens.accessToken.trim().isNotEmpty) {
      request.headers.set(
        'Authorization',
        authorizationHeader(tokens.accessToken),
      );
    }
    header?.forEach((k, v) => request.headers.set(k, v));

    if (strData.isNotEmpty) {
      request.write(strData);
    }

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    await _handleResponse(response.statusCode, body, ok: ok, fail: fail);
  } catch (e) {
    _handleNetworkError(e, fail: fail);
  }
  eventually?.call();
}

void _handleNetworkError(Object error, {Function(String)? fail}) {
  final message = friendlyNetworkError(error);
  final result = ApiResponseInterceptor.network(message);
  fail?.call(message);
  ApiErrorPresenter.presentIfNeeded(result);
}

Future<void> _handleInterceptResultAsync(
  ApiInterceptResult result, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
}) async {
  if (result.isSuccess) {
    ok?.call(result.data ?? const {});
    return;
  }

  var suppressUnauthorized = true;
  if (result.isUnauthorized) {
    suppressUnauthorized = await onApiUnauthorized?.call() ?? true;
  }

  fail?.call(result.message ?? 'request failed');

  if (result.isUnauthorized) {
    if (!suppressUnauthorized) {
      ApiErrorPresenter.presentIfNeeded(result);
    }
    return;
  }

  ApiErrorPresenter.presentIfNeeded(result);
}

Future<void> _handleResponse(
  int statusCode,
  String body, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
}) async {
  final result = ApiResponseInterceptor.intercept(statusCode, body);
  await _handleInterceptResultAsync(result, ok: ok, fail: fail);
}
