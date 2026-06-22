import 'dart:io';

import 'screenplay.dart';
import 'screenplay_image_resolver.dart';
import 'script_frame_display.dart';
import '../../utils/media_path_utils.dart';

extension ScreenplayDisplay on Screenplay {
  bool get coverIsRemoteUploaded =>
      ScreenplayImageResolver.hasRemoteUrl(coverUrl);

  String? get effectiveCoverImagePath {
    final local = localCoverPath;
    if (local != null &&
        local.isNotEmpty &&
        !ScreenplayImageResolver.isNetworkUrl(local)) {
      if (File(local).existsSync()) return local;
    }
    if (coverUrl != null && coverUrl!.isNotEmpty) return coverUrl;
    for (final act in acts) {
      for (final scene in act.scenes) {
        for (final frame in scene.frames) {
          final path = frame.effectiveDisplayPath;
          if (path.isNotEmpty) return path;
          final local = frame.localImagePath;
          if (local != null && local.isNotEmpty && isVideoPath(local)) {
            final thumb = frame.localThumbnailPath;
            if (thumb != null && thumb.isNotEmpty && File(thumb).existsSync()) {
              return thumb;
            }
          }
        }
      }
    }
    return null;
  }
}
