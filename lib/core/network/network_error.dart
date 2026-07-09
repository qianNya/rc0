import 'dart:async';

import 'package:http/http.dart' as http;

String friendlyNetworkError(Object error) {
  if (error is TimeoutException) {
    return '网络超时，请稍后重试';
  }
  if (error is http.ClientException) {
    final msg = error.message.trim();
    return msg.isEmpty ? '网络连接失败，请检查网络' : '网络连接失败，请检查网络';
  }
  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('Failed to fetch') ||
      text.contains('NetworkError') ||
      text.contains('XMLHttpRequest')) {
    return '网络连接失败，请检查网络';
  }
  return '网络异常，请稍后重试';
}
