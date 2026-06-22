import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../core/utils/media_path_utils.dart';

/// Extracts the first frame of a local video as a JPEG thumbnail file.
abstract final class VideoThumbnailService {
  static Future<String?> extractFirstFrame(
    String videoPath, {
    String? destDir,
  }) async {
    if (kIsWeb || !isVideoPath(videoPath)) return null;

    final dir = destDir ?? (await getTemporaryDirectory()).path;
    try {
      return await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: dir,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 720,
        quality: 85,
        timeMs: 0,
      );
    } catch (_) {
      return null;
    }
  }
}
