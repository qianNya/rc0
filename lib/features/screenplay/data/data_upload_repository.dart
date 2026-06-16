import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../api/data/api/data-api.dart' as data_api;
import '../../../api/data/api/upload.dart' as upload_api;
import '../../../api/data/data/data-api.dart';
import '../../../core/config/app_update_config.dart';

class UploadedObject {
  const UploadedObject({
    required this.objectKey,
    required this.bucket,
    required this.downloadUrl,
  });

  final String objectKey;
  final String bucket;
  final String downloadUrl;
}

/// Wraps object storage upload + presigned download URL.
class DataUploadRepository {
  DataUploadRepository._();

  static final DataUploadRepository instance = DataUploadRepository._();

  static const _presignExpireSec = 86400 * 7;

  Future<({UploadedObject? object, String? error})> uploadImage(File file) async {
    final upload = await upload_api.uploadFile(file);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return _presignUploaded(upload.resp!);
  }

  Future<({UploadedObject? object, String? error})> uploadBytes(
    Uint8List bytes,
    String filename,
  ) async {
    final upload = await upload_api.uploadBytes(bytes, filename);
    if (upload.error != null || upload.resp == null) {
      return (object: null, error: upload.error ?? '上传失败');
    }
    return _presignUploaded(upload.resp!);
  }

  Future<({UploadedObject? object, String? error})> _presignUploaded(
    UploadResp upload,
  ) async {
    final completer = Completer<({UploadedObject? object, String? error})>();

    await data_api.presignDownload(
      PresignDownloadReq(
        bucket: upload.bucket,
        objectKey: upload.objectKey,
        expireSec: _presignExpireSec,
      ),
      ok: (resp) {
        completer.complete((
          object: UploadedObject(
            objectKey: upload.objectKey,
            bucket: upload.bucket,
            downloadUrl: resp.downloadUrl,
          ),
          error: null,
        ));
      },
      fail: (msg) => completer.complete((object: null, error: msg)),
    );

    return completer.future;
  }

  Future<({String? downloadUrl, String? error})> presignDownloadUrl({
    required String bucket,
    required String objectKey,
    int expireSec = AppUpdateConfig.presignExpireSec,
  }) async {
    final completer = Completer<({String? downloadUrl, String? error})>();

    await data_api.presignDownload(
      PresignDownloadReq(
        bucket: bucket,
        objectKey: objectKey,
        expireSec: expireSec,
      ),
      ok: (resp) {
        final url = resp.downloadUrl.trim();
        if (url.isEmpty) {
          completer.complete((downloadUrl: null, error: '无法获取下载链接'));
        } else {
          completer.complete((downloadUrl: url, error: null));
        }
      },
      fail: (msg) => completer.complete((downloadUrl: null, error: msg)),
    );

    return completer.future;
  }
}
