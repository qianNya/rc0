import 'dart:io';

import '../../gallery/data/image_gallery_repository.dart';
import '../../upload/data/image_pick_service.dart';

/// Picks an image from the gallery and uploads it for profile media (avatar / background).
class ProfileImageUploadService {
  ProfileImageUploadService._();

  static final instance = ProfileImageUploadService._();

  final _picker = ImagePickService();

  Future<({String? imageUrl, String? localPreviewPath, String? error})>
      pickAndUpload({
    String videoErrorMessage = '请选择图片',
    String emptyUrlErrorMessage = '上传成功，但未返回图片地址',
  }) async {
    final picked = await _picker.pickCover();
    if (picked.added.isEmpty) {
      return (imageUrl: null, localPreviewPath: null, error: null);
    }

    final file = picked.added.first;
    if (file.isVideo) {
      return (
        imageUrl: null,
        localPreviewPath: null,
        error: videoErrorMessage,
      );
    }

    final localPreviewPath = file.displayPath;
    final uploaded = await ImageGalleryRepository.instance.uploadStandalone(
      File(file.path),
    );

    if (uploaded.error != null) {
      return (
        imageUrl: null,
        localPreviewPath: localPreviewPath,
        error: uploaded.error,
      );
    }

    final image = uploaded.image;
    final imageUrl = image == null
        ? ''
        : (image.imageUrl.isNotEmpty
            ? image.imageUrl
            : image.thumbnailUrl);

    if (imageUrl.isEmpty) {
      return (
        imageUrl: null,
        localPreviewPath: localPreviewPath,
        error: emptyUrlErrorMessage,
      );
    }

    return (imageUrl: imageUrl, localPreviewPath: null, error: null);
  }
}
