import 'dart:io';

import 'package:rc0_core/rc0_core.dart';

import 'image_cache_port.dart';
import 'image_url_utils.dart';

/// Unified image path resolver (replaces scattered ScreenplayImageResolver logic).
abstract final class ImageResolver {
  static ImageCachePort cachePort = const NullImageCachePort();

  static bool isNetworkUrl(String path) => isNetworkImagePath(path);

  static String? _safeRemoteUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return resolveNetworkImageUrl(raw);
  }

  /// UI / edit preview: prefer local file when [allowLocal] and available.
  static String? displayPath({
    required ImageRef ref,
    String? legacyPath,
    bool allowLocal = true,
  }) =>
      displayPathRaw(
        localPath: ref.localPath,
        remoteUrl: ref.remoteUrl,
        legacyPath: legacyPath,
        allowLocal: allowLocal,
      );

  static String? displayPathRaw({
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
    required ImageRef ref,
    String? legacyPath,
    bool allowLocal = true,
  }) =>
      effectiveDisplayPathRaw(
        localPath: ref.localPath,
        remoteUrl: ref.remoteUrl,
        legacyPath: legacyPath,
        allowLocal: allowLocal,
      );

  static String? effectiveDisplayPathRaw({
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
      final cached = cachePort.cachedPathSync(remote);
      if (cached != null) return cached;
      return remote;
    }
    if (legacyPath != null && legacyPath.isNotEmpty) {
      final legacyRemote = _safeRemoteUrl(legacyPath);
      if (legacyRemote != null && isNetworkUrl(legacyRemote)) {
        final cached = cachePort.cachedPathSync(legacyRemote);
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
  }) {
    final ref = ImageRef.fromFrameMap(frame);
    return effectiveDisplayPath(
      ref: ref,
      legacyPath: _legacyFramePath(frame),
      allowLocal: allowLocal,
    );
  }

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
      final cached = cachePort.cachedPathSync(thumbRemote);
      return cached ?? thumbRemote;
    }
    return frameEffectivePath(frame, allowLocal: allowLocal);
  }

  static String? coverEffectivePath(
    Map<String, dynamic> screenplayMap, {
    bool allowLocal = true,
  }) {
    final ref = ImageRef.fromCoverMap(screenplayMap);
    return effectiveDisplayPath(
      ref: ref,
      legacyPath: legacyCoverPath(screenplayMap),
      allowLocal: allowLocal,
    );
  }

  /// Local file path eligible for upload (local paths only).
  static String? localUploadPath(String? localPath) {
    if (localPath == null || localPath.isEmpty || isNetworkUrl(localPath)) {
      return null;
    }
    if (File(localPath).existsSync()) return localPath;
    return null;
  }

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
  }) {
    final ref = ImageRef.fromFrameMap(frame);
    return displayPath(
      ref: ref,
      legacyPath: _legacyFramePath(frame),
      allowLocal: allowLocal,
    );
  }

  static String? frameDisplayRemoteUrl(Map<String, dynamic> frame) {
    final imageUrl = _safeRemoteUrl(frame['image_url'] as String?);
    if (imageUrl != null) return imageUrl;
    return _safeRemoteUrl(frame['thumbnail_url'] as String?);
  }

  static String? frameRemoteUrl(Map<String, dynamic> frame) =>
      frameDisplayRemoteUrl(frame);

  static String? frameLocalPath(Map<String, dynamic> frame) {
    final ref = ImageRef.fromFrameMap(frame);
    return ref.localPath;
  }

  static String? _legacyFramePath(Map<String, dynamic> frame) {
    final imageUrl = frame['image_url'] as String? ?? '';
    if (imageUrl.isNotEmpty && !isNetworkUrl(imageUrl)) return imageUrl;
    return null;
  }

  static String? coverDisplayPath(
    Map<String, dynamic> screenplayMap, {
    bool allowLocal = true,
  }) {
    final ref = ImageRef.fromCoverMap(screenplayMap);
    return displayPath(
      ref: ref,
      legacyPath: legacyCoverPath(screenplayMap),
      allowLocal: allowLocal,
    );
  }

  static String? coverRemoteUrl(Map<String, dynamic> screenplayMap) {
    final ref = ImageRef.fromCoverMap(screenplayMap);
    return _safeRemoteUrl(ref.remoteUrl);
  }

  static String? legacyCoverPath(Map<String, dynamic> screenplayMap) {
    final cover = screenplayMap['cover_url'] as String? ?? '';
    if (cover.isNotEmpty && !isNetworkUrl(cover)) return cover;
    return null;
  }
}
