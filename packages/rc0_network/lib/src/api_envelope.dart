import 'dart:convert';

import 'api_error_message.dart';

/// Parsed REST envelope `{code, message, data}` (rc0 backend contract).
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final T? data;

  bool get isSuccess => code == 0;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic> data)? parseData,
  }) {
    final codeRaw = json['code'];
    final code = codeRaw is int ? codeRaw : int.tryParse('$codeRaw') ?? -1;
    final message = apiErrorMessage(json);
    Map<String, dynamic>? dataMap;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      dataMap = rawData;
    }
    return ApiEnvelope(
      code: code,
      message: message,
      data: dataMap != null && parseData != null ? parseData(dataMap) : null,
    );
  }
}

Map<String, dynamic>? parseEnvelopeMap(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {}
  return null;
}
