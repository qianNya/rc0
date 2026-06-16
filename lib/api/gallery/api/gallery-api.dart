import 'api.dart';
import '../data/gallery-api.dart';

/// gallery-api

/// --/api/gallery/image-analyses--
///
/// request: CreateAcgnImageAnalysisReq
/// response: AcgnImageAnalysis
Future createAcgnImageAnalysis(
  CreateAcgnImageAnalysisReq request, {
  Function(AcgnImageAnalysis)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-analyses",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageAnalysis.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-analyses--
///
/// request: ListAcgnImageAnalysesReq
/// response: ListAcgnImageAnalysesResp
Future listAcgnImageAnalyses({
  Function(ListAcgnImageAnalysesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-analyses",
    ok: (data) {
      if (ok != null) ok(ListAcgnImageAnalysesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-analyses/:id--
///
/// request: GetAcgnImageAnalysisReq
/// response: AcgnImageAnalysis
Future getAcgnImageAnalysis(
  int id, {
  Function(AcgnImageAnalysis)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-analyses/${id}",
    ok: (data) {
      if (ok != null) ok(AcgnImageAnalysis.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-analyses/:id--
///
/// request: UpdateAcgnImageAnalysisReq
/// response: AcgnImageAnalysis
Future updateAcgnImageAnalysis(
  int id,
  UpdateAcgnImageAnalysisReq request, {
  Function(AcgnImageAnalysis)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-analyses/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageAnalysis.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-analyses/:id--
///
/// request: DeleteAcgnImageAnalysisReq
/// response:
Future deleteAcgnImageAnalysis(
  int id,
  DeleteAcgnImageAnalysisReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-analyses/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-files--
///
/// request: CreateAcgnImageFileReq
/// response: AcgnImageFile
Future createAcgnImageFile(
  CreateAcgnImageFileReq request, {
  Function(AcgnImageFile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-files",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageFile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-files--
///
/// request: ListAcgnImageFilesReq
/// response: ListAcgnImageFilesResp
Future listAcgnImageFiles({
  Function(ListAcgnImageFilesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-files",
    ok: (data) {
      if (ok != null) ok(ListAcgnImageFilesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-files/:id--
///
/// request: GetAcgnImageFileReq
/// response: AcgnImageFile
Future getAcgnImageFile(
  int id, {
  Function(AcgnImageFile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-files/${id}",
    ok: (data) {
      if (ok != null) ok(AcgnImageFile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-files/:id--
///
/// request: UpdateAcgnImageFileReq
/// response: AcgnImageFile
Future updateAcgnImageFile(
  int id,
  UpdateAcgnImageFileReq request, {
  Function(AcgnImageFile)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-files/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageFile.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-files/:id--
///
/// request: DeleteAcgnImageFileReq
/// response:
Future deleteAcgnImageFile(
  int id,
  DeleteAcgnImageFileReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-files/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-metrics--
///
/// request: CreateAcgnImageMetricsReq
/// response: AcgnImageMetrics
Future createAcgnImageMetrics(
  CreateAcgnImageMetricsReq request, {
  Function(AcgnImageMetrics)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-metrics",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageMetrics.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-metrics--
///
/// request: ListAcgnImageMetricsReq
/// response: ListAcgnImageMetricsResp
Future listAcgnImageMetrics({
  Function(ListAcgnImageMetricsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-metrics",
    ok: (data) {
      if (ok != null) ok(ListAcgnImageMetricsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-metrics/:image_id--
///
/// request: GetAcgnImageMetricsReq
/// response: AcgnImageMetrics
Future getAcgnImageMetrics(
  int image_id, {
  Function(AcgnImageMetrics)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-metrics/${image_id}",
    ok: (data) {
      if (ok != null) ok(AcgnImageMetrics.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-metrics/:image_id--
///
/// request: UpdateAcgnImageMetricsReq
/// response: AcgnImageMetrics
Future updateAcgnImageMetrics(
  int image_id,
  UpdateAcgnImageMetricsReq request, {
  Function(AcgnImageMetrics)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-metrics/${image_id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageMetrics.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-metrics/:image_id--
///
/// request: DeleteAcgnImageMetricsReq
/// response:
Future deleteAcgnImageMetrics(
  int image_id,
  DeleteAcgnImageMetricsReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-metrics/${image_id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-tags--
///
/// request: CreateAcgnImageTagReq
/// response: AcgnImageTag
Future createAcgnImageTag(
  CreateAcgnImageTagReq request, {
  Function(AcgnImageTag)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-tags",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageTag.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-tags--
///
/// request: ListAcgnImageTagsReq
/// response: ListAcgnImageTagsResp
Future listAcgnImageTags({
  Function(ListAcgnImageTagsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-tags",
    ok: (data) {
      if (ok != null) ok(ListAcgnImageTagsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-tags/:id--
///
/// request: GetAcgnImageTagReq
/// response: AcgnImageTag
Future getAcgnImageTag(
  int id, {
  Function(AcgnImageTag)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-tags/${id}",
    ok: (data) {
      if (ok != null) ok(AcgnImageTag.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-tags/:id--
///
/// request: UpdateAcgnImageTagReq
/// response: AcgnImageTag
Future updateAcgnImageTag(
  int id,
  UpdateAcgnImageTagReq request, {
  Function(AcgnImageTag)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-tags/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageTag.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-tags/:id--
///
/// request: DeleteAcgnImageTagReq
/// response:
Future deleteAcgnImageTag(
  int id,
  DeleteAcgnImageTagReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-tags/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-works--
///
/// request: CreateAcgnImageWorkReq
/// response: AcgnImageWork
Future createAcgnImageWork(
  CreateAcgnImageWorkReq request, {
  Function(AcgnImageWork)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-works",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageWork.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-works--
///
/// request: ListAcgnImageWorksReq
/// response: ListAcgnImageWorksResp
Future listAcgnImageWorks({
  Function(ListAcgnImageWorksResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-works",
    ok: (data) {
      if (ok != null) ok(ListAcgnImageWorksResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-works/:id--
///
/// request: GetAcgnImageWorkReq
/// response: AcgnImageWork
Future getAcgnImageWork(
  int id, {
  Function(AcgnImageWork)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/image-works/${id}",
    ok: (data) {
      if (ok != null) ok(AcgnImageWork.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-works/:id--
///
/// request: UpdateAcgnImageWorkReq
/// response: AcgnImageWork
Future updateAcgnImageWork(
  int id,
  UpdateAcgnImageWorkReq request, {
  Function(AcgnImageWork)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-works/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImageWork.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/image-works/:id--
///
/// request: DeleteAcgnImageWorkReq
/// response:
Future deleteAcgnImageWork(
  int id,
  DeleteAcgnImageWorkReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/image-works/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/images--
///
/// request: CreateAcgnImageReq
/// response: AcgnImage
Future createAcgnImage(
  CreateAcgnImageReq request, {
  Function(AcgnImage)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/images",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImage.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/images--
///
/// request: ListAcgnImagesReq
/// response: ListAcgnImagesResp
Future listAcgnImages({
  Function(ListAcgnImagesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/images",
    ok: (data) {
      if (ok != null) ok(ListAcgnImagesResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/images/:id--
///
/// request: GetAcgnImageReq
/// response: AcgnImage
Future getAcgnImage(
  int id, {
  Function(AcgnImage)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/images/${id}",
    ok: (data) {
      if (ok != null) ok(AcgnImage.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/images/:id--
///
/// request: UpdateAcgnImageReq
/// response: AcgnImage
Future updateAcgnImage(
  int id,
  UpdateAcgnImageReq request, {
  Function(AcgnImage)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/images/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnImage.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/images/:id--
///
/// request: DeleteAcgnImageReq
/// response:
Future deleteAcgnImage(
  int id,
  DeleteAcgnImageReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/images/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/tags--
///
/// request: CreateAcgnTagReq
/// response: AcgnTag
Future createAcgnTag(
  CreateAcgnTagReq request, {
  Function(AcgnTag)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/tags",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnTag.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/tags--
///
/// request: ListAcgnTagsReq
/// response: ListAcgnTagsResp
Future listAcgnTags({
  Function(ListAcgnTagsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/tags",
    ok: (data) {
      if (ok != null) ok(ListAcgnTagsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/tags/:id--
///
/// request: GetAcgnTagReq
/// response: AcgnTag
Future getAcgnTag(
  int id, {
  Function(AcgnTag)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/tags/${id}",
    ok: (data) {
      if (ok != null) ok(AcgnTag.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/tags/:id--
///
/// request: UpdateAcgnTagReq
/// response: AcgnTag
Future updateAcgnTag(
  int id,
  UpdateAcgnTagReq request, {
  Function(AcgnTag)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/tags/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnTag.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/tags/:id--
///
/// request: DeleteAcgnTagReq
/// response:
Future deleteAcgnTag(
  int id,
  DeleteAcgnTagReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/tags/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/works--
///
/// request: CreateAcgnWorkReq
/// response: AcgnWork
Future createAcgnWork(
  CreateAcgnWorkReq request, {
  Function(AcgnWork)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/works",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnWork.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/works--
///
/// request: ListAcgnWorksReq
/// response: ListAcgnWorksResp
Future listAcgnWorks({
  Function(ListAcgnWorksResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/works",
    ok: (data) {
      if (ok != null) ok(ListAcgnWorksResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/works/:id--
///
/// request: GetAcgnWorkReq
/// response: AcgnWork
Future getAcgnWork(
  int id, {
  Function(AcgnWork)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/works/${id}",
    ok: (data) {
      if (ok != null) ok(AcgnWork.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/works/:id--
///
/// request: UpdateAcgnWorkReq
/// response: AcgnWork
Future updateAcgnWork(
  int id,
  UpdateAcgnWorkReq request, {
  Function(AcgnWork)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/works/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(AcgnWork.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/works/:id--
///
/// request: DeleteAcgnWorkReq
/// response:
Future deleteAcgnWork(
  int id,
  DeleteAcgnWorkReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/gallery/works/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/gallery/ping--
///
/// request:
/// response: PingResp
Future ping({
  Function(PingResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/gallery/ping",
    ok: (data) {
      if (ok != null) ok(PingResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}
