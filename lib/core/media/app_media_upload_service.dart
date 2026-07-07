import 'dart:io';

import 'package:rc0_media/rc0_media.dart';

import '../../features/screenplay/data/data_upload_repository.dart';

/// App implementation of [MediaUploadService] delegating to legacy repository.
final class AppMediaUploadService implements MediaUploadService {
  const AppMediaUploadService();

  static const AppMediaUploadService instance = AppMediaUploadService();

  @override
  Future<({UploadedMediaResult? result, String? error})> uploadLocalFile(
    String localPath,
  ) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      return (result: null, error: '本地文件不存在');
    }

    final uploaded = await DataUploadRepository.instance.uploadImage(file);
    return _mapUpload(uploaded.object, uploaded.error);
  }

  @override
  Future<({String? coverUrl, String? error})> uploadScreenplayCover({
    required int screenplayId,
    required String localPath,
  }) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      return (coverUrl: null, error: '本地封面不存在');
    }
    return DataUploadRepository.instance.uploadScreenplayCover(
      screenplayId,
      file,
    );
  }

  @override
  Future<({Map<String, UploadedMediaResult>? results, String? error})>
      uploadLocalBatch(
    Map<String, String> refToLocalPath, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (refToLocalPath.isEmpty) {
      return (results: <String, UploadedMediaResult>{}, error: null);
    }

    final refToFile = <String, File>{};
    for (final entry in refToLocalPath.entries) {
      final file = File(entry.value);
      if (!file.existsSync()) {
        return (results: null, error: '本地文件不存在：${entry.key}');
      }
      refToFile[entry.key] = file;
    }

    final batch = await DataUploadRepository.instance.uploadBatch(
      refToFile,
      onProgress: onProgress,
    );
    if (batch.error != null || batch.refToUploaded == null) {
      return (results: null, error: batch.error ?? '上传失败');
    }

    final results = <String, UploadedMediaResult>{};
    for (final entry in batch.refToUploaded!.entries) {
      results[entry.key] = UploadedMediaResult(
        imageId: entry.value.imageId,
        displayUrl: entry.value.displayUrl,
        thumbUrl: entry.value.thumbUrl,
        displayFileId: entry.value.displayFileId,
        thumbFileId: entry.value.thumbFileId,
      );
    }
    return (results: results, error: null);
  }

  ({UploadedMediaResult? result, String? error}) _mapUpload(
    UploadedImage? object,
    String? error,
  ) {
    if (error != null || object == null) {
      return (result: null, error: error ?? '上传失败');
    }
    return (
      result: UploadedMediaResult(
        imageId: object.imageId,
        displayUrl: object.displayUrl,
        thumbUrl: object.thumbUrl,
        displayFileId: object.displayFileId,
        thumbFileId: object.thumbFileId,
      ),
      error: null,
    );
  }
}
