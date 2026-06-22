import 'image_url_utils.dart';

/// File extensions recognized as video (lowercase, no dot).
const kSupportedVideoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'];

bool isVideoPath(String path) {
  final ext = imageExtensionFromPath(path);
  return ext != null && kSupportedVideoExtensions.contains(ext);
}

/// Display path for a media file: video uses [previewPath] when provided.
String mediaDisplayPath({
  required String path,
  String? previewPath,
}) {
  if (isVideoPath(path)) {
    if (previewPath != null && previewPath.isNotEmpty) return previewPath;
  }
  return path;
}
