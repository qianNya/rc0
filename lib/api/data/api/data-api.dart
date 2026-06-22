import 'api.dart';
import '../data/data-api.dart';

/// data-api

/// --/api/data/ping--
///
/// request:
/// response: PingResp
Future ping({
  Function(PingResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/data/ping",
    ok: (data) {
      if (ok != null) ok(PingResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/data/objects--
///
/// request: DeleteObjectReq
/// response:
Future deleteObject(
  DeleteObjectReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/data/objects",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/data/objects/stat--
///
/// request: StatObjectReq
/// response: StatObjectResp
Future statObject({
  Function(StatObjectResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/data/objects/stat",
    ok: (data) {
      if (ok != null) ok(StatObjectResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/data/presign/download--
///
/// request: PresignDownloadReq
/// response: PresignDownloadResp
Future presignDownload(
  PresignDownloadReq request, {
  Function(PresignDownloadResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/data/presign/download",
    request,
    ok: (data) {
      if (ok != null) ok(PresignDownloadResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/data/upload--
///
/// request:
/// response: UploadResp
Future upload({
  Function(UploadResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/data/upload",
    <String, dynamic>{},
    ok: (data) {
      if (ok != null) ok(UploadResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}
