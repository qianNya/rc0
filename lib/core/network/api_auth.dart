typedef ApiUnauthorizedHandler = Future<void> Function();

ApiUnauthorizedHandler? onApiUnauthorized;

/// Returns true when [message] indicates the user must log in again.
bool isUnauthorizedError(String? message) {
  if (message == null || message.trim().isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('unauthorized') ||
      lower.contains('unauthenticated') ||
      lower.contains('invalid token') ||
      message.contains('登录已过期');
}
