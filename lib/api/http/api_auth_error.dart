bool isUnauthorizedError(String? message) {
  if (message == null) return false;
  final m = message.toLowerCase();
  return m.contains('401') ||
      m.contains('invalid token') ||
      m.contains('未登录') ||
      m.contains('请先登录');
}

String apiErrorMessage(Map<String, dynamic> base, int statusCode) {
  return base['msg'] as String? ??
      base['desc'] as String? ??
      'HTTP $statusCode';
}

bool isUnauthorizedResponse(Map<String, dynamic> base, int statusCode) {
  final code = base['code'];
  if (statusCode == 401 || code == 401) return true;
  return isUnauthorizedError(apiErrorMessage(base, statusCode));
}
