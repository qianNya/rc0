import 'dart:io';

String friendlyNetworkError(Object error) {
  if (error is SocketException) {
    final msg = error.message.trim();
    return msg.isEmpty ? 'network error' : 'network error: $msg';
  }
  if (error is HttpException) return error.message;
  return error.toString();
}
