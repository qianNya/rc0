import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/services/network_image_cache_service.dart';
import '../../core/utils/image_url_utils.dart';
import '../widgets/image_preview.dart';

class ImageSaveResult {
  const ImageSaveResult({this.path, this.error});

  final String? path;
  final String? error;

  bool get success => path != null;
}

class ImageSaveService {
  ImageSaveService._();

  static final ImageSaveService instance = ImageSaveService._();

  Future<ImageSaveResult> saveImageToDownloads(String sourcePath) async {
    try {
      final localPath = await resolveLocalImagePath(sourcePath);
      if (localPath == null) {
        return const ImageSaveResult(error: '无法获取图片文件');
      }

      final source = File(localPath);
      if (!await source.exists()) {
        return const ImageSaveResult(error: '图片文件不存在');
      }

      final destDir = await _destinationDirectory();
      await destDir.create(recursive: true);

      final ext = imageFileExtensionFromPath(localPath);
      final fileName =
          'rc0_${DateTime.now().millisecondsSinceEpoch}$ext';
      final dest = File('${destDir.path}/$fileName');
      await source.copy(dest.path);

      return ImageSaveResult(path: dest.path);
    } catch (e) {
      return ImageSaveResult(error: '保存失败：$e');
    }
  }

  /// Returns a local file path for sharing or saving (downloads network images).
  Future<String?> resolveLocalImagePath(String sourcePath) async {
    if (!isPreviewableImagePath(sourcePath)) return null;

    if (!isNetworkImagePath(sourcePath)) {
      return sourcePath;
    }

    return NetworkImageCacheService.instance.downloadIfNeeded(sourcePath);
  }

  Future<Directory> _destinationDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;

    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/Downloads');
  }
}
