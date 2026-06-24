/// Returns true when the global unauthorized snackbar should be suppressed
/// (session recovered, or user was never logged in).
typedef ApiUnauthorizedHandler = Future<bool> Function();

ApiUnauthorizedHandler? onApiUnauthorized;

/// Returns true when [message] indicates the user must log in again.
bool isUnauthorizedError(String? message) {
  if (message == null || message.trim().isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('unauthorized') ||
      lower.contains('unauthenticated') ||
      lower.contains('invalid token') ||
      message.contains('登录已过期') ||
      message.contains('请先登录');
}

/// Returns true when [message] indicates planned server maintenance.
bool isMaintenanceError(String? message) {
  if (message == null || message.trim().isEmpty) return false;
  final lower = message.toLowerCase();
  return message.contains('维护') ||
      lower.contains('maintenance') ||
      message.contains('系统维护中');
}

/// Returns true when [message] indicates a connectivity problem.
bool isNetworkError(String? message) {
  if (message == null || message.trim().isEmpty) return false;
  return message.contains('网络连接失败') ||
      message.contains('网络异常') ||
      message.contains('Connection') ||
      message.contains('SocketException');
}

/// Returns true when [message] indicates a server-side failure.
bool isServerError(String? message) {
  if (message == null || message.trim().isEmpty) return false;
  return message.contains('服务器异常') ||
      message.contains('服务响应异常') ||
      isMaintenanceError(message);
}
