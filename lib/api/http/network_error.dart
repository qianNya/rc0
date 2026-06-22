import 'dart:io';

String friendlyNetworkError(Object error) {
  if (error is SocketException) {
    final message = error.message.trim();
    return message.isEmpty ? 'network error' : 'network error: $message';
  }
  return error.toString();
}
