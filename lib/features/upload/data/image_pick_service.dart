import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/image_url_utils.dart';
import '../domain/upload_image_file.dart';

class ImagePickResult {
  const ImagePickResult({required this.added, this.rejectedCount = 0});

  final List<UploadImageFile> added;
  final int rejectedCount;

  bool get hasRejected => rejectedCount > 0;
}

class ImagePickService {
  ImagePickService() : _imagePicker = ImagePicker();

  final ImagePicker _imagePicker;

  static final _imageExtensions = kSupportedImageExtensions;

  bool get _useGalleryPicker =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Opens the system picker and returns local file paths (no count limit).
  Future<ImagePickResult> pickImages() async {
    if (_useGalleryPicker) {
      return _pickFromGallery();
    }
    return _pickFromFileDialog();
  }

  /// Android / iOS — uses the system gallery picker (more reliable than file_picker).
  Future<ImagePickResult> _pickFromGallery() async {
    final files = await _imagePicker.pickMultiImage(imageQuality: 100);

    if (files.isEmpty) {
      return const ImagePickResult(added: []);
    }

    final added = <UploadImageFile>[];
    var rejected = 0;

    for (final file in files) {
      final path = file.path;
      if (path.isEmpty) {
        rejected += 1;
        continue;
      }

      final name = file.name.isNotEmpty ? file.name : _basename(path);
      added.add(
        UploadImageFile(
          path: path,
          name: name,
          sizeBytes: await file.length(),
        ),
      );
    }

    return ImagePickResult(added: added, rejectedCount: rejected);
  }

  /// Windows / macOS / Linux — uses the native file dialog.
  Future<ImagePickResult> _pickFromFileDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: false,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) {
      return const ImagePickResult(added: []);
    }

    final added = <UploadImageFile>[];
    var rejected = 0;

    for (final file in result.files) {
      final path = file.path;
      if (path == null || path.isEmpty) {
        rejected += 1;
        continue;
      }

      final name = file.name.isNotEmpty ? file.name : _basename(path);
      if (!_isImageName(name)) {
        rejected += 1;
        continue;
      }

      added.add(
        UploadImageFile(
          path: path,
          name: name,
          sizeBytes: file.size,
        ),
      );
    }

    return ImagePickResult(added: added, rejectedCount: rejected);
  }

  bool _isImageName(String name) {
    final lower = name.toLowerCase();
    return _imageExtensions.any((ext) => lower.endsWith('.$ext'));
  }

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index < 0 ? path : normalized.substring(index + 1);
  }
}
