import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../api/image/api/image-api.dart' as image_api;
import '../../../api/image/data/image-api.dart';
import '../../../core/utils/image_url_utils.dart';

class UploadedObject {
  const UploadedObject({
    required this.objectKey,
    required this.bucket,
    required this.downloadUrl,
    required this.imageId,
  });

  final String objectKey;
  final String bucket;
  final String downloadUrl;
  final int imageId;
}

class DataUploadRepository {
  DataUploadRepository._();

  static final DataUploadRepository instance = DataUploadRepository._();

  Future<({UploadedObject? object, String? error})> uploadImage(File file) async {
    final upload = await _uploadFile(file);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return _resolveUploaded(upload.resp!);
  }

  Future<({UploadedObject? object, String? error})> uploadBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final upload = await _uploadBytes(bytes, filename);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return _resolveUploaded(upload.resp!);
  }

  Future<({ImageUploadResp? resp, String? error})> _uploadFile(File file) async {
    final completer = Completer<({ImageUploadResp? resp, String? error})>();
    await image_api.uploadImageFile(
      file,
      ok: (resp) => completer.complete((resp: resp, error: null)),
      fail: (msg) => completer.complete((resp: null, error: msg)),
    );
    return completer.future;
  }

  Future<({ImageUploadResp? resp, String? error})> _uploadBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final completer = Completer<({ImageUploadResp? resp, String? error})>();
    await image_api.uploadImageBytes(
      bytes,
      filename,
      ok: (resp) => completer.complete((resp: resp, error: null)),
      fail: (msg) => completer.complete((resp: null, error: msg)),
    );
    return completer.future;
  }

  Future<({UploadedObject? object, String? error})> _resolveUploaded(
    ImageUploadResp upload,
  ) async {
    final download = await _fetchDownloadUrl(upload.id.toInt());
    if (download.error != null || download.url == null) {
      return (object: null, error: download.error ?? '无法获取下载链接');
    }
    return (
      object: UploadedObject(
        objectKey: 'images/${upload.id}',
        bucket: '',
        downloadUrl: download.url!,
        imageId: upload.id.toInt(),
      ),
      error: null,
    );
  }

  Future<({String? url, String? error})> _fetchDownloadUrl(int imageId) async {
    final completer = Completer<({String? url, String? error})>();
    await image_api.getImageDownloadUrl(
      imageId,
      ok: (resp) {
        final url = resolveNetworkImageUrl(resp.downloadUrl);
        if (url == null || !isValidNetworkImageUrl(url)) {
          completer.complete((url: null, error: '无法获取有效的下载链接'));
        } else {
          completer.complete((url: url, error: null));
        }
      },
      fail: (msg) => completer.complete((url: null, error: msg)),
    );
    return completer.future;
  }

  Future<({String? downloadUrl, String? error})> presignDownloadUrl({
    required int imageId,
  }) async {
    final result = await _fetchDownloadUrl(imageId);
    return (downloadUrl: result.url, error: result.error);
  }

  Future<({Map<String, String>? refToUrl, Map<String, int>? refToImageId, String? error})>
      uploadBatchForScreenplay(
    int screenplayId,
    Map<String, File> refToFile, {
    void Function(int done, int total)? onProgress,
  }) async {
    return uploadBatch(refToFile, onProgress: onProgress);
  }

  Future<({Map<String, String>? refToUrl, Map<String, int>? refToImageId, String? error})>
      uploadBatch(
    Map<String, File> refToFile, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (refToFile.isEmpty) {
      return (
        refToUrl: <String, String>{},
        refToImageId: <String, int>{},
        error: null,
      );
    }

    final refToUrl = <String, String>{};
    final refToImageId = <String, int>{};
    var index = 0;
    for (final entry in refToFile.entries) {
      final uploaded = await uploadImage(entry.value);
      if (uploaded.error != null || uploaded.object == null) {
        return (refToUrl: null, refToImageId: null, error: uploaded.error);
      }
      refToUrl[entry.key] = uploaded.object!.downloadUrl;
      refToImageId[entry.key] = uploaded.object!.imageId;
      index++;
      onProgress?.call(index, refToFile.length);
    }

    return (refToUrl: refToUrl, refToImageId: refToImageId, error: null);
  }
}
