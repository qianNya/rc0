// Helpers for validating and repairing remote image URLs.

/// File extensions recognized as previewable images (lowercase, no dot).
const kSupportedImageExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'];

bool isNetworkImagePath(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

/// Lowercase extension without dot, e.g. `webp`; null when absent.
String? imageExtensionFromPath(String path) {
  final base = path.split('?').first.split('#').first;
  final dot = base.lastIndexOf('.');
  if (dot <= 0 || dot >= base.length - 1) return null;
  return base.substring(dot + 1).toLowerCase();
}

bool isWebpImagePath(String path) => imageExtensionFromPath(path) == 'webp';

bool isSupportedImageExtension(String path) {
  final ext = imageExtensionFromPath(path);
  return ext != null && kSupportedImageExtensions.contains(ext);
}

/// Normalized `.<ext>` for saving downloaded images; defaults to `.jpg`.
String imageFileExtensionFromPath(String path) {
  final ext = imageExtensionFromPath(path);
  if (ext == null || ext.isEmpty || ext.length > 5) return '.jpg';
  return '.$ext';
}

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
