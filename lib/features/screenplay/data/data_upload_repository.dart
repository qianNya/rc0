import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../api/image/api/image-api.dart' as image_api;
import '../../../api/image/data/image-api.dart';
import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;

class UploadedImage {
  const UploadedImage({required this.imageId});

  final int imageId;
}

class DataUploadRepository {
  DataUploadRepository._();

  static final DataUploadRepository instance = DataUploadRepository._();

  Future<({UploadedImage? object, String? error})> uploadImage(File file) async {
    final upload = await _uploadFile(file);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return (
      object: UploadedImage(imageId: upload.resp!.id.toInt()),
      error: null,
    );
  }

  Future<({UploadedImage? object, String? error})> uploadBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final upload = await _uploadBytes(bytes, filename);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return (
      object: UploadedImage(imageId: upload.resp!.id.toInt()),
      error: null,
    );
  }

  Future<({String? coverUrl, String? error})> uploadScreenplayCover(
    int screenplayId,
    File file,
  ) async {
    final completer = Completer<({String? coverUrl, String? error})>();
    await screenplay_api.uploadScreenplayCover(
      screenplayId,
      file,
      ok: (sp) => completer.complete((
        coverUrl: sp.coverUrl.isNotEmpty ? sp.coverUrl : null,
        error: null,
      )),
      fail: (msg) => completer.complete((coverUrl: null, error: msg)),
    );
    return completer.future;
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

  Future<({Map<String, int>? refToImageId, String? error})> uploadBatchForScreenplay(
    int screenplayId,
    Map<String, File> refToFile, {
    void Function(int done, int total)? onProgress,
  }) async {
    return uploadBatch(refToFile, onProgress: onProgress);
  }

  Future<({Map<String, int>? refToImageId, String? error})> uploadBatch(
    Map<String, File> refToFile, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (refToFile.isEmpty) {
      return (refToImageId: <String, int>{}, error: null);
    }

    final refToImageId = <String, int>{};
    var index = 0;
    for (final entry in refToFile.entries) {
      final uploaded = await uploadImage(entry.value);
      if (uploaded.error != null || uploaded.object == null) {
        return (refToImageId: null, error: uploaded.error);
      }
      refToImageId[entry.key] = uploaded.object!.imageId;
      index++;
      onProgress?.call(index, refToFile.length);
    }

    return (refToImageId: refToImageId, error: null);
  }
}
