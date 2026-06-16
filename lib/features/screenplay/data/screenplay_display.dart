import 'dart:io';

import '../../../../core/domain/screenplay/screenplay.dart';
import 'screenplay_image_resolver.dart';
import 'script_frame_display.dart';

extension ScreenplayDisplay on Screenplay {
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
        }
      }
    }
    return null;
  }
}
