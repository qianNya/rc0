import 'profile_image_upload_service.dart';

/// Picks an image and uploads it to the gallery for use as a profile background.
class ProfileBackgroundUploadService {
  ProfileBackgroundUploadService._();

  static final instance = ProfileBackgroundUploadService._();

  Future<({String? imageUrl, String? localPreviewPath, String? error})>
      pickAndUpload() {
    return ProfileImageUploadService.instance.pickAndUpload(
      videoErrorMessage: '请选择图片作为背景',
      emptyUrlErrorMessage: '上传成功，但未返回背景图地址',
    );
  }
}
