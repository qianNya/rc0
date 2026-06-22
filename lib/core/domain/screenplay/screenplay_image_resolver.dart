import 'dart:io';

import '../../utils/image_url_utils.dart';

/// Resolves local vs remote image paths for screenplay tree frames and covers.
abstract final class ScreenplayImageResolver {
  static bool isNetworkUrl(String path) => isNetworkImagePath(path);

  static String? _safeRemoteUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return resolveNetworkImageUrl(raw);
  }

  /// UI / edit preview: prefer local file when available.
  static String? displayPath({
    String? localPath,
    String? remoteUrl,
    String? legacyPath,
  }) {
    if (localPath != null && localPath.isNotEmpty && !isNetworkUrl(localPath)) {
      return localPath;
    }
    final remote = _safeRemoteUrl(remoteUrl);
    if (remote != null) return remote;
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
    final remote = _safeRemoteUrl(remoteUrl);
    if (remote != null) return remote;
    if (legacyPath != null && legacyPath.isNotEmpty) {
      final legacyRemote = _safeRemoteUrl(legacyPath);
      if (legacyRemote != null && isNetworkUrl(legacyRemote)) return legacyRemote;
      if (!isNetworkUrl(legacyPath) && File(legacyPath).existsSync()) {
        return legacyPath;
      }
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

  /// Local file path eligible for upload (local_* fields only).
  static String? localUploadPath(String? localPath) {
    if (localPath == null || localPath.isEmpty || isNetworkUrl(localPath)) {
      return null;
    }
    if (File(localPath).existsSync()) return localPath;
    return null;
  }

  /// Publish upload reads local_* paths only (legacy image_url fallback via migrate).
  static String? uploadSourcePath({String? localPath, String? imageUrl}) {
    final fromLocal = localUploadPath(localPath);
    if (fromLocal != null) return fromLocal;
    if (imageUrl != null && imageUrl.isNotEmpty && !isNetworkUrl(imageUrl)) {
      return File(imageUrl).existsSync() ? imageUrl : null;
    }
    return null;
  }

  static bool hasRemoteUrl(String? url) =>
      url != null && url.isNotEmpty && isNetworkUrl(url);

  static String? frameDisplayPath(Map<String, dynamic> frame) => displayPath(
        localPath: frameLocalPath(frame),
        remoteUrl: frameRemoteUrl(frame),
        legacyPath: _legacyFramePath(frame),
      );

  static String? frameRemoteUrl(Map<String, dynamic> frame) {
    for (final key in ['image_url', 'thumbnail_url']) {
      final raw = frame[key] as String? ?? '';
      final url = _safeRemoteUrl(raw);
      if (url != null) return url;
    }
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
    return _safeRemoteUrl(cover);
  }

  static String? legacyCoverPath(Map<String, dynamic> screenplayMap) {
    final cover = screenplayMap['cover_url'] as String? ?? '';
    if (cover.isNotEmpty && !isNetworkUrl(cover)) return cover;
    return null;
  }
}
