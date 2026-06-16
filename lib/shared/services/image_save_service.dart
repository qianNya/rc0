import 'dart:io';

import 'package:path_provider/path_provider.dart';

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

      final ext = _extensionFromPath(localPath);
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

    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/rc0_image_cache');
    await cacheDir.create(recursive: true);

    final ext = _extensionFromUrl(sourcePath);
    final cacheFile = File(
      '${cacheDir.path}/${sourcePath.hashCode.abs()}$ext',
    );
    if (await cacheFile.exists()) return cacheFile.path;

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(sourcePath));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException('下载失败: ${response.statusCode}');
      }
      await response.pipe(cacheFile.openWrite());
      return cacheFile.path;
    } finally {
      client.close();
    }
  }

  Future<Directory> _destinationDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;

    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/Downloads');
  }

  String _extensionFromPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot <= 0 || dot >= path.length - 1) return '.jpg';
    final ext = path.substring(dot).split('?').first.toLowerCase();
    if (ext.length > 6) return '.jpg';
    return ext;
  }

  String _extensionFromUrl(String url) {
    try {
      return _extensionFromPath(Uri.parse(url).path);
    } catch (_) {
      return '.jpg';
    }
  }
}
