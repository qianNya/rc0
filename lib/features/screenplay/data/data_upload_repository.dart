import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../api/image/api/image-api.dart' as image_api;
import '../../../api/image/data/image-api.dart';
import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;

class UploadedImage {
  const UploadedImage({
    required this.imageId,
    required this.displayUrl,
    required this.thumbUrl,
    this.displayFileId,
    this.thumbFileId,
  });

  final int imageId;
  final String displayUrl;
  final String thumbUrl;
  final int? displayFileId;
  final int? thumbFileId;
}

class DataUploadRepository {
  DataUploadRepository._();

  static final DataUploadRepository instance = DataUploadRepository._();

  Future<({UploadedImage? object, String? error})> uploadImage(File file) async {
    final upload = await _uploadFile(file);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return _resolveUploadedImage(upload.resp!.id.toInt());
  }

  Future<({UploadedImage? object, String? error})> uploadBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final upload = await _uploadBytes(bytes, filename);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return _resolveUploadedImage(upload.resp!.id.toInt());
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

  Future<({UploadedImage? object, String? error})> _resolveUploadedImage(
    int imageId,
  ) async {
    final completer = Completer<({ImageDetailResp? resp, String? error})>();
    await image_api.getImageDetail(
      imageId,
      ok: (resp) => completer.complete((resp: resp, error: null)),
      fail: (msg) => completer.complete((resp: null, error: msg)),
    );
    final detail = await completer.future;
    if (detail.error != null || detail.resp == null) {
      return (
        object: UploadedImage(
          imageId: imageId,
          displayUrl: '',
          thumbUrl: '',
        ),
        error: null,
      );
    }
    final bundle = detail.resp!.filesBundle;
    return (
      object: UploadedImage(
        imageId: imageId,
        displayUrl: bundle.displayUrl,
        thumbUrl: bundle.thumbUrl,
        displayFileId: bundle.displayFileId,
        thumbFileId: bundle.thumbFileId,
      ),
      error: null,
    );
  }

  Future<({Map<String, UploadedImage>? refToUploaded, String? error})>
      uploadBatchForScreenplay(
    int screenplayId,
    Map<String, File> refToFile, {
    void Function(int done, int total)? onProgress,
  }) async {
    return uploadBatch(refToFile, onProgress: onProgress);
  }

  Future<({Map<String, UploadedImage>? refToUploaded, String? error})>
      uploadBatch(
    Map<String, File> refToFile, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (refToFile.isEmpty) {
      return (refToUploaded: <String, UploadedImage>{}, error: null);
    }

    final refToUploaded = <String, UploadedImage>{};
    var index = 0;
    for (final entry in refToFile.entries) {
      final uploaded = await uploadImage(entry.value);
      if (uploaded.error != null || uploaded.object == null) {
        return (refToUploaded: null, error: uploaded.error);
      }
      refToUploaded[entry.key] = uploaded.object!;
      index++;
      onProgress?.call(index, refToFile.length);
    }

    return (refToUploaded: refToUploaded, error: null);
  }
}
