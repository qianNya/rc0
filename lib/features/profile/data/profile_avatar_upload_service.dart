import 'profile_image_upload_service.dart';

/// Picks an image and uploads it to the gallery for use as a profile avatar.
class ProfileAvatarUploadService {
  ProfileAvatarUploadService._();

  static final instance = ProfileAvatarUploadService._();

  Future<({String? imageUrl, String? localPreviewPath, String? error})>
      pickAndUpload() {
    return ProfileImageUploadService.instance.pickAndUpload(
      videoErrorMessage: '请选择图片作为头像',
      emptyUrlErrorMessage: '上传成功，但未返回头像地址',
    );
  }
}
