import 'script_frame.dart';
import 'screenplay_image_resolver.dart';
import '../../utils/media_path_utils.dart';

extension ScriptFrameDisplay on ScriptFrame {
  String displayPathFor({bool allowLocal = true}) {
    final thumb = localThumbnailPath;
    if (allowLocal && thumb != null && thumb.isNotEmpty) {
      final resolved = ScreenplayImageResolver.effectiveDisplayPath(
        localPath: thumb,
        remoteUrl: null,
        legacyPath: null,
        allowLocal: true,
      );
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }
    final local = localImagePath;
    if (allowLocal && local != null && local.isNotEmpty && isVideoPath(local)) {
      return '';
    }
    return ScreenplayImageResolver.effectiveDisplayPath(
          localPath: localImagePath,
          remoteUrl: remoteImageUrl,
          legacyPath: imagePath,
          allowLocal: allowLocal,
        ) ??
        '';
  }

  String get effectiveDisplayPath => displayPathFor(allowLocal: true);

  bool get isRemoteUploaded =>
      ScreenplayImageResolver.hasRemoteUrl(remoteImageUrl);
}
