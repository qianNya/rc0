import 'dart:io';

import 'package:flutter/foundation.dart';

import 'screenplay.dart';
import 'screenplay_image_resolver.dart';
import 'script_frame_display.dart';
import '../../utils/media_path_utils.dart';

bool _localFileExists(String path) {
  if (kIsWeb || path.isEmpty) return false;
  return File(path).existsSync();
}

extension ScreenplayDisplay on Screenplay {
  bool get coverIsRemoteUploaded =>
      ScreenplayImageResolver.hasRemoteUrl(coverUrl);

  String? get effectiveCoverImagePath {
    final local = localCoverPath;
    if (local != null &&
        local.isNotEmpty &&
        !ScreenplayImageResolver.isNetworkUrl(local)) {
      if (_localFileExists(local)) return local;
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
            if (thumb != null &&
                thumb.isNotEmpty &&
                _localFileExists(thumb)) {
              return thumb;
            }
          }
        }
      }
    }
    return null;
  }
}
