import 'package:flutter/foundation.dart';

/// A user-selected image or video file with its local path.
///
/// Replaces legacy [UploadImageFile] in `lib/features/upload/domain/`.
/// Migration: `typedef UploadImageFile = LocalMediaFile` at call sites.
@immutable
class LocalMediaFile {
  const LocalMediaFile({
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

  String get sizeLabel {
    final bytes = sizeBytes;
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  bool operator ==(Object other) =>
      other is LocalMediaFile && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
