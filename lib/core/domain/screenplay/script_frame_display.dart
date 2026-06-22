import 'script_frame.dart';
import 'screenplay_image_resolver.dart';
import '../../utils/media_path_utils.dart';

extension ScriptFrameDisplay on ScriptFrame {
  String get effectiveDisplayPath {
    final thumb = localThumbnailPath;
    if (thumb != null && thumb.isNotEmpty) {
      final resolved = ScreenplayImageResolver.effectiveDisplayPath(
        localPath: thumb,
        remoteUrl: null,
        legacyPath: null,
      );
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }
    final local = localImagePath;
    if (local != null && local.isNotEmpty && isVideoPath(local)) {
      return '';
    }
    return ScreenplayImageResolver.effectiveDisplayPath(
        localPath: localImagePath,
        remoteUrl: remoteImageUrl,
        legacyPath: imagePath,
      ) ??
      '';
  }

  bool get isRemoteUploaded =>
      ScreenplayImageResolver.hasRemoteUrl(remoteImageUrl);
}
