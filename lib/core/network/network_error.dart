import 'dart:io';

String friendlyNetworkError(Object error) {
  if (error is SocketException) {
    return '网络连接失败，请检查网络';
  }
  if (error is HttpException) {
    final msg = error.message.trim();
    return msg.isEmpty ? '网络异常，请稍后重试' : msg;
  }
  return '网络异常，请稍后重试';
}
