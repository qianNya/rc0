import '../../../core/utils/media_path_utils.dart';

/// A user-selected image or video file with its local path.
class UploadImageFile {
  const UploadImageFile({
    required this.path,
    required this.name,
    this.sizeBytes,
    this.previewPath,
  });

  final String path;
  final String name;
  final int? sizeBytes;

  /// JPEG thumbnail for video; null for images.
  final String? previewPath;

  bool get isVideo => isVideoPath(path);

  String get displayPath => mediaDisplayPath(path: path, previewPath: previewPath);

  @override
  bool operator ==(Object other) =>
      other is UploadImageFile && other.path == path;

  @override
  int get hashCode => path.hashCode;

  String get sizeLabel {
    final bytes = sizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
