/// A user-selected image file with its local path.
class UploadImageFile {
  const UploadImageFile({
    required this.path,
    required this.name,
    this.sizeBytes,
  });

  final String path;
  final String name;
  final int? sizeBytes;

  String get displayPath => path;

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
