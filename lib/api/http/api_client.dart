import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/network/api_auth.dart';
import '../../core/network/api_error_presenter.dart';
import '../../core/network/api_headers.dart';
import '../../core/network/api_response_interceptor.dart';
import '../../core/network/network_error.dart';
import '../auth/vars/kv.dart';

String get serverHost => ApiConfig.serverHost;
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

Future apiPatch(
  String path,
  dynamic data, {
  Map<String, String>? header,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await _apiRequest(
    'PATCH',
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
    final uri = Uri.parse(serverHost + path);
    final request = http.MultipartRequest('POST', uri);
    if (tokens != null && tokens.accessToken.trim().isNotEmpty) {
      request.headers['Authorization'] =
          authorizationHeader(tokens.accessToken);
    }
    header?.forEach((k, v) => request.headers[k] = v);
    request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes(fileField, bytes, filename: filename),
    );

    final streamed = await request.send().timeout(_requestTimeout);
    final response = await http.Response.fromStream(streamed)
        .timeout(_requestTimeout);
    await _handleResponse(response.statusCode, response.body, ok: ok, fail: fail);
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
    final headers = <String, String>{};
    if (tokens != null && tokens.accessToken.trim().isNotEmpty) {
      headers['Authorization'] = authorizationHeader(tokens.accessToken);
    }
    header?.forEach((k, v) => headers[k] = v);

    String? body;
    if (data != null) {
      body = jsonEncode(data);
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }

    late final http.Response response;
    switch (method) {
      case 'POST':
        response = await http
            .post(uri, headers: headers, body: body)
            .timeout(_requestTimeout);
      case 'PUT':
        response = await http
            .put(uri, headers: headers, body: body)
            .timeout(_requestTimeout);
      case 'PATCH':
        response = await http
            .patch(uri, headers: headers, body: body)
            .timeout(_requestTimeout);
      case 'DELETE':
        response = await http
            .delete(uri, headers: headers, body: body)
            .timeout(_requestTimeout);
      default:
        response =
            await http.get(uri, headers: headers).timeout(_requestTimeout);
    }

    await _handleResponse(response.statusCode, response.body, ok: ok, fail: fail);
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
