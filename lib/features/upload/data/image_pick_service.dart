import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/image_url_utils.dart';
import '../../../core/utils/media_path_utils.dart';
import '../domain/upload_image_file.dart';
import 'video_thumbnail_service.dart';

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
  static final _videoExtensions = kSupportedVideoExtensions;
  static final _mediaExtensions = [..._imageExtensions, ..._videoExtensions];

  bool get _useGalleryPicker =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Opens the system picker and returns local file paths (no count limit).
  Future<ImagePickResult> pickImages() async {
    if (_useGalleryPicker) {
      return _pickFromGallery(allowVideo: true);
    }
    return _pickFromFileDialog(allowVideo: true);
  }

  /// Picks a single image or video for screenplay cover.
  Future<ImagePickResult> pickCover() async {
    if (_useGalleryPicker) {
      return _pickSingleFromGallery();
    }
    return _pickFromFileDialog(allowVideo: true, single: true);
  }

  Future<ImagePickResult> _pickSingleFromGallery() async {
    final file = await _imagePicker.pickMedia(imageQuality: 100);
    if (file == null) return const ImagePickResult(added: []);

    final upload = await _toUploadFile(file);
    if (upload == null) {
      return const ImagePickResult(added: [], rejectedCount: 1);
    }
    return ImagePickResult(added: [upload]);
  }

  Future<ImagePickResult> _pickFromGallery({required bool allowVideo}) async {
    final List<XFile> files;
    if (allowVideo) {
      files = await _imagePicker.pickMultipleMedia(imageQuality: 100);
    } else {
      files = await _imagePicker.pickMultiImage(imageQuality: 100);
    }

    if (files.isEmpty) {
      return const ImagePickResult(added: []);
    }

    return _mapPickedFiles(files);
  }

  Future<ImagePickResult> _pickFromFileDialog({
    required bool allowVideo,
    bool single = false,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowVideo ? FileType.custom : FileType.image,
      allowedExtensions: allowVideo ? _mediaExtensions : null,
      allowMultiple: !single,
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
      if (!_isMediaName(name)) {
        rejected += 1;
        continue;
      }

      final upload = await _buildUploadFile(
        path: path,
        name: name,
        sizeBytes: file.size,
      );
      if (upload == null) {
        rejected += 1;
        continue;
      }
      added.add(upload);
    }

    return ImagePickResult(added: added, rejectedCount: rejected);
  }

  Future<ImagePickResult> _mapPickedFiles(List<XFile> files) async {
    final added = <UploadImageFile>[];
    var rejected = 0;

    for (final file in files) {
      final upload = await _toUploadFile(file);
      if (upload == null) {
        rejected += 1;
      } else {
        added.add(upload);
      }
    }

    return ImagePickResult(added: added, rejectedCount: rejected);
  }

  Future<UploadImageFile?> _toUploadFile(XFile file) async {
    final path = file.path;
    if (path.isEmpty) return null;
    final name = file.name.isNotEmpty ? file.name : _basename(path);
    final size = await file.length();
    return _buildUploadFile(path: path, name: name, sizeBytes: size);
  }

  Future<UploadImageFile?> _buildUploadFile({
    required String path,
    required String name,
    int? sizeBytes,
  }) async {
    if (isVideoPath(path)) {
      final thumb = await VideoThumbnailService.extractFirstFrame(path);
      if (thumb == null) return null;
      return UploadImageFile(
        path: path,
        name: name,
        sizeBytes: sizeBytes,
        previewPath: thumb,
      );
    }

    if (!_isImageName(name) && !isSupportedImageExtension(path)) {
      return null;
    }

    return UploadImageFile(
      path: path,
      name: name,
      sizeBytes: sizeBytes,
    );
  }

  bool _isImageName(String name) {
    final lower = name.toLowerCase();
    return _imageExtensions.any((ext) => lower.endsWith('.$ext'));
  }

  bool _isMediaName(String name) {
    final lower = name.toLowerCase();
    return _mediaExtensions.any((ext) => lower.endsWith('.$ext'));
  }

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index < 0 ? path : normalized.substring(index + 1);
  }
}
