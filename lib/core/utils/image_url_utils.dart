/// Helpers for validating and repairing remote image URLs.

bool isNetworkImagePath(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

/// Returns true when [url] can be parsed as http(s) with a valid port.
bool isValidNetworkImageUrl(String url) {
  final text = url.trim();
  if (!isNetworkImagePath(text)) return false;
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  if (uri.hasPort && (uri.port <= 0 || uri.port > 65535)) return false;
  return true;
}

/// Repairs known malformed MinIO URLs, e.g. `:9090idea/` -> `:9090/idea/`.
String? sanitizeLegacyImageUrl(String? raw) {
  if (raw == null) return null;
  var text = raw.trim();
  if (text.isEmpty) return null;

  text = text.replaceAll('your-host', '112.74.176.124');
  text = text.replaceAllMapped(
    RegExp(r':9090idea/'),
    (_) => ':9090/',
  );

  if (!isNetworkImagePath(text)) return text.isEmpty ? null : text;
  return isValidNetworkImageUrl(text) ? text : null;
}

/// Returns a loadable network URL or null when invalid.
String? resolveNetworkImageUrl(String? raw) {
  final sanitized = sanitizeLegacyImageUrl(raw);
  if (sanitized == null || sanitized.isEmpty) return null;
  if (!isNetworkImagePath(sanitized)) return sanitized;
  return isValidNetworkImageUrl(sanitized) ? sanitized : null;
}
