import 'package:rc0_core/rc0_core.dart';

import '../../../core/utils/media_path_utils.dart';

/// App-layer extension of [LocalMediaFile] with video/display helpers.
///
/// Migration target: use [LocalMediaFile] from `rc0_core` directly once
/// [media_path_utils] moves into `rc0_media`.
class UploadImageFile extends LocalMediaFile {
  const UploadImageFile({
    required super.path,
    required super.name,
    super.sizeBytes,
    super.previewPath,
  });

  bool get isVideo => isVideoPath(path);

  String get displayPath =>
      mediaDisplayPath(path: path, previewPath: previewPath);
}
