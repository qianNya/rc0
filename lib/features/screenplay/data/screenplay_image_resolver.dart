import 'dart:io';

/// Resolves local vs remote image paths for screenplay tree frames and covers.
abstract final class ScreenplayImageResolver {
  static bool isNetworkUrl(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  /// UI / edit preview: prefer local file when available.
  static String? displayPath({
    String? localPath,
    String? remoteUrl,
    String? legacyPath,
  }) {
    if (localPath != null && localPath.isNotEmpty && !isNetworkUrl(localPath)) {
      return localPath;
    }
    if (remoteUrl != null && remoteUrl.isNotEmpty) return remoteUrl;
    if (legacyPath != null && legacyPath.isNotEmpty) return legacyPath;
    return null;
  }

  /// UI display with local file existence check; falls back to remote when missing.
  static String? effectiveDisplayPath({
    String? localPath,
    String? remoteUrl,
    String? legacyPath,
  }) {
    if (localPath != null && localPath.isNotEmpty && !isNetworkUrl(localPath)) {
      if (File(localPath).existsSync()) return localPath;
    }
    if (remoteUrl != null && remoteUrl.isNotEmpty) return remoteUrl;
    if (legacyPath != null && legacyPath.isNotEmpty) {
      if (isNetworkUrl(legacyPath)) return legacyPath;
      if (File(legacyPath).existsSync()) return legacyPath;
    }
    return null;
  }

  static String? frameEffectivePath(Map<String, dynamic> frame) =>
      effectiveDisplayPath(
        localPath: frameLocalPath(frame),
        remoteUrl: frameRemoteUrl(frame),
        legacyPath: _legacyFramePath(frame),
      );

  static String? coverEffectivePath(Map<String, dynamic> screenplayMap) =>
      effectiveDisplayPath(
        localPath: screenplayMap['local_cover_path'] as String?,
        remoteUrl: coverRemoteUrl(screenplayMap),
        legacyPath: legacyCoverPath(screenplayMap),
      );

  /// Publish upload source: local file path when available.
  static String? uploadSourcePath({String? localPath, String? imageUrl}) {
    if (localPath != null && localPath.isNotEmpty && !isNetworkUrl(localPath)) {
      return localPath;
    }
    if (imageUrl != null && imageUrl.isNotEmpty && !isNetworkUrl(imageUrl)) {
      return imageUrl;
    }
    return null;
  }

  static String? frameDisplayPath(Map<String, dynamic> frame) => displayPath(
        localPath: frameLocalPath(frame),
        remoteUrl: frameRemoteUrl(frame),
        legacyPath: _legacyFramePath(frame),
      );

  static String? frameRemoteUrl(Map<String, dynamic> frame) {
    final imageUrl = frame['image_url'] as String? ?? '';
    if (imageUrl.isNotEmpty && isNetworkUrl(imageUrl)) return imageUrl;
    final thumb = frame['thumbnail_url'] as String? ?? '';
    if (thumb.isNotEmpty && isNetworkUrl(thumb)) return thumb;
    return null;
  }

  static String? frameLocalPath(Map<String, dynamic> frame) {
    final local = frame['local_image_path'] as String?;
    if (local != null && local.isNotEmpty) return local;
    final thumbLocal = frame['local_thumbnail_path'] as String?;
    if (thumbLocal != null && thumbLocal.isNotEmpty) return thumbLocal;
    return null;
  }

  static String? _legacyFramePath(Map<String, dynamic> frame) {
    final imageUrl = frame['image_url'] as String? ?? '';
    if (imageUrl.isNotEmpty && !isNetworkUrl(imageUrl)) return imageUrl;
    return null;
  }

  static String? coverDisplayPath(Map<String, dynamic> screenplayMap) =>
      displayPath(
        localPath: screenplayMap['local_cover_path'] as String?,
        remoteUrl: coverRemoteUrl(screenplayMap),
        legacyPath: legacyCoverPath(screenplayMap),
      );

  static String? coverRemoteUrl(Map<String, dynamic> screenplayMap) {
    final cover = screenplayMap['cover_url'] as String? ?? '';
    if (cover.isNotEmpty && isNetworkUrl(cover)) return cover;
    return null;
  }

  static String? legacyCoverPath(Map<String, dynamic> screenplayMap) {
    final cover = screenplayMap['cover_url'] as String? ?? '';
    if (cover.isNotEmpty && !isNetworkUrl(cover)) return cover;
    return null;
  }
}
