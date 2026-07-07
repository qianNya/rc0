import 'package:rc0_media/rc0_media.dart';

/// Legacy facade — delegates to unified [ImageResolver] in `rc0_media`.
///
/// New code should call [ImageResolver] / [ImageRef] directly.
abstract final class ScreenplayImageResolver {
  static bool isNetworkUrl(String path) => ImageResolver.isNetworkUrl(path);

  static String? displayPath({
    String? localPath,
    String? remoteUrl,
    String? legacyPath,
    bool allowLocal = true,
  }) =>
      ImageResolver.displayPathRaw(
        localPath: localPath,
        remoteUrl: remoteUrl,
        legacyPath: legacyPath,
        allowLocal: allowLocal,
      );

  static String? effectiveDisplayPath({
    String? localPath,
    String? remoteUrl,
    String? legacyPath,
    bool allowLocal = true,
  }) =>
      ImageResolver.effectiveDisplayPathRaw(
        localPath: localPath,
        remoteUrl: remoteUrl,
        legacyPath: legacyPath,
        allowLocal: allowLocal,
      );

  static String? frameEffectivePath(
    Map<String, dynamic> frame, {
    bool allowLocal = true,
  }) =>
      ImageResolver.frameEffectivePath(frame, allowLocal: allowLocal);

  static String? frameThumbPath(
    Map<String, dynamic> frame, {
    bool allowLocal = true,
  }) =>
      ImageResolver.frameThumbPath(frame, allowLocal: allowLocal);

  static String? coverEffectivePath(
    Map<String, dynamic> screenplayMap, {
    bool allowLocal = true,
  }) =>
      ImageResolver.coverEffectivePath(screenplayMap, allowLocal: allowLocal);

  static String? localUploadPath(String? localPath) =>
      ImageResolver.localUploadPath(localPath);

  static String? uploadSourcePath({String? localPath, String? imageUrl}) =>
      ImageResolver.uploadSourcePath(localPath: localPath, imageUrl: imageUrl);

  static bool hasRemoteUrl(String? url) => ImageResolver.hasRemoteUrl(url);

  static String? frameDisplayPath(
    Map<String, dynamic> frame, {
    bool allowLocal = true,
  }) =>
      ImageResolver.frameDisplayPath(frame, allowLocal: allowLocal);

  static String? frameDisplayRemoteUrl(Map<String, dynamic> frame) =>
      ImageResolver.frameDisplayRemoteUrl(frame);

  static String? frameRemoteUrl(Map<String, dynamic> frame) =>
      ImageResolver.frameRemoteUrl(frame);

  static String? frameLocalPath(Map<String, dynamic> frame) =>
      ImageResolver.frameLocalPath(frame);

  static String? coverDisplayPath(
    Map<String, dynamic> screenplayMap, {
    bool allowLocal = true,
  }) =>
      ImageResolver.coverDisplayPath(screenplayMap, allowLocal: allowLocal);

  static String? coverRemoteUrl(Map<String, dynamic> screenplayMap) =>
      ImageResolver.coverRemoteUrl(screenplayMap);

  static String? legacyCoverPath(Map<String, dynamic> screenplayMap) =>
      ImageResolver.legacyCoverPath(screenplayMap);
}
