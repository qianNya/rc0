typedef ApiUnauthorizedHandler = Future<void> Function();

ApiUnauthorizedHandler? onApiUnauthorized;

bool isUnauthorizedError(String? error) {
  final lower = error?.trim().toLowerCase() ?? '';
  if (lower.isEmpty) return false;
  return lower.contains('unauthorized') ||
      lower.contains('unauthenticated') ||
      lower.contains('invalid token');
}

Future<void> notifyApiUnauthorizedIfNeeded(String error) async {
  if (!isUnauthorizedError(error)) return;
  final handler = onApiUnauthorized;
  if (handler != null) await handler();
}
