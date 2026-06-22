import 'api_headers.dart';

typedef ApiUnauthorizedHandler = Future<void> Function();

ApiUnauthorizedHandler? onApiUnauthorized;

/// Returns true when [message] indicates the user must log in again.
bool isUnauthorizedError(String? message) {
  if (message == null || message.trim().isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('unauthorized') ||
      lower.contains('unauthenticated') ||
      lower.contains('invalid token');
}

/// Parses backend envelope and triggers [onApiUnauthorized] for 401-style codes.
String apiErrorMessageWithAuth(Map<String, dynamic> base) {
  final code = base['code'];
  if (code == 401) {
    onApiUnauthorized?.call();
  }
  return apiErrorMessage(base);
}
