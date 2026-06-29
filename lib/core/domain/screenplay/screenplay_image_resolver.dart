import 'dart:io';

import '../../services/network_image_cache_service.dart';
import '../../utils/image_url_utils.dart';

/// Resolves local vs remote image paths for screenplay tree frames and covers.
abstract final class ScreenplayImageResolver {
  static bool isNetworkUrl(String path) => isNetworkImagePath(path);

  static String? _safeRemoteUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return resolveNetworkImageUrl(raw);
  }

  /// UI / edit preview: prefer local file when [allowLocal] and available.
  static String? displayPath({
    String? localPath,
    String? remoteUrl,
    String? legacyPath,
    bool allowLocal = true,
  }) {
    if (allowLocal &&
        localPath != null &&
        localPath.isNotEmpty &&
        !isNetworkUrl(localPath)) {
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
    bool allowLocal = true,
  }) {
    if (allowLocal &&
        localPath != null &&
        localPath.isNotEmpty &&
        !isNetworkUrl(localPath)) {
      if (File(localPath).existsSync()) return localPath;
    }
    final remote = _safeRemoteUrl(remoteUrl);
    if (remote != null) {
      final cached = NetworkImageCacheService.instance.cachedPathSync(remote);
      if (cached != null) return cached;
      return remote;
    }
    if (legacyPath != null && legacyPath.isNotEmpty) {
      final legacyRemote = _safeRemoteUrl(legacyPath);
      if (legacyRemote != null && isNetworkUrl(legacyRemote)) {
        final cached =
            NetworkImageCacheService.instance.cachedPathSync(legacyRemote);
        if (cached != null) return cached;
        return legacyRemote;
      }
      if (allowLocal &&
          !isNetworkUrl(legacyPath) &&
          File(legacyPath).existsSync()) {
        return legacyPath;
      }
    }
    return null;
  }

  static String? frameEffectivePath(
    Map<String, dynamic> frame, {
    bool allowLocal = true,
  }) =>
      effectiveDisplayPath(
        localPath: frameLocalPath(frame),
        remoteUrl: frameDisplayRemoteUrl(frame),
        legacyPath: _legacyFramePath(frame),
        allowLocal: allowLocal,
      );

  static String? frameThumbPath(
    Map<String, dynamic> frame, {
    bool allowLocal = true,
  }) {
    final thumbLocal = frame['local_thumbnail_path'] as String?;
    if (allowLocal &&
        thumbLocal != null &&
        thumbLocal.isNotEmpty &&
        !isNetworkUrl(thumbLocal) &&
        File(thumbLocal).existsSync()) {
      return thumbLocal;
    }
    final thumbRemote = _safeRemoteUrl(frame['thumbnail_url'] as String?);
    if (thumbRemote != null) {
      final cached =
          NetworkImageCacheService.instance.cachedPathSync(thumbRemote);
      return cached ?? thumbRemote;
    }
    return frameEffectivePath(frame, allowLocal: allowLocal);
  }

  static String? coverEffectivePath(
    Map<String, dynamic> screenplayMap, {
    bool allowLocal = true,
  }) =>
      effectiveDisplayPath(
        localPath: screenplayMap['local_cover_path'] as String?,
        remoteUrl: coverRemoteUrl(screenplayMap),
        legacyPath: legacyCoverPath(screenplayMap),
        allowLocal: allowLocal,
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

  static String? frameDisplayPath(
    Map<String, dynamic> frame, {
    bool allowLocal = true,
  }) =>
      displayPath(
        localPath: frameLocalPath(frame),
        remoteUrl: frameDisplayRemoteUrl(frame),
        legacyPath: _legacyFramePath(frame),
        allowLocal: allowLocal,
      );

  static String? frameDisplayRemoteUrl(Map<String, dynamic> frame) {
    final imageUrl = _safeRemoteUrl(frame['image_url'] as String?);
    if (imageUrl != null) return imageUrl;
    return _safeRemoteUrl(frame['thumbnail_url'] as String?);
  }

  static String? frameRemoteUrl(Map<String, dynamic> frame) =>
      frameDisplayRemoteUrl(frame);

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

  static String? coverDisplayPath(
    Map<String, dynamic> screenplayMap, {
    bool allowLocal = true,
  }) =>
      displayPath(
        localPath: screenplayMap['local_cover_path'] as String?,
        remoteUrl: coverRemoteUrl(screenplayMap),
        legacyPath: legacyCoverPath(screenplayMap),
        allowLocal: allowLocal,
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
