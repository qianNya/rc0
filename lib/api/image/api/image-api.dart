import 'dart:io';
import 'dart:typed_data';

import '../../http/api_client.dart';
import '../data/image-api.dart';

Future uploadImageBytes(
  Uint8List bytes,
  String filename, {
  String title = '',
  String description = '',
  Function(ImageUploadResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final fields = <String, String>{};
  if (title.isNotEmpty) fields['title'] = title;
  if (description.isNotEmpty) fields['description'] = description;

  await apiMultipart(
    '/images',
    fileField: 'file',
    bytes: bytes,
    filename: filename,
    fields: fields,
    ok: (data) => ok?.call(ImageUploadResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future uploadImageFile(
  File file, {
  Function(ImageUploadResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final bytes = await file.readAsBytes();
  final name = file.path.split(Platform.pathSeparator).last;
  return uploadImageBytes(
    bytes,
    name.isNotEmpty ? name : 'upload.bin',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future listImages({
  int page = 1,
  int pageSize = 20,
  Function(ListImagesResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/images',
    query: {'page': '$page', 'page_size': '$pageSize'},
    ok: (data) => ok?.call(ListImagesResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getImageDetail(
  int imageId, {
  Function(ImageDetailResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/images/$imageId',
    ok: (data) => ok?.call(ImageDetailResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getImageDownloadUrl(
  int imageId, {
  Function(ImageDownloadResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/images/$imageId/download',
    ok: (data) => ok?.call(ImageDownloadResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listImageTags({
  String namespace = 'general',
  Function(ListImageTagsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/image-tags',
    query: {'namespace': namespace},
    ok: (data) => ok?.call(ListImageTagsResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createImageTag({
  required String name,
  String namespace = 'general',
  String? slug,
  Function(ImageTagItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final body = <String, dynamic>{
    'namespace': namespace,
    'name': name,
    'slug': slug ?? _slugify(name),
  };
  await apiPost(
    '/image-tags',
    body,
    ok: (data) => ok?.call(ImageTagItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future tagImage(
  int imageId, {
  required int tagId,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/images/$imageId/tags',
    {'tag_id': tagId},
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future untagImage(
  int imageId,
  int tagId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/images/$imageId/tags/$tagId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future linkImageWork(
  int imageId, {
  required int workId,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/images/$imageId/works',
    {'work_id': workId},
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future unlinkImageWork(
  int imageId,
  int workId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/images/$imageId/works/$workId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future getImageAnalysis(
  int imageId, {
  Function(ImageAnalysisResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/images/$imageId/analysis',
    ok: (data) => ok?.call(ImageAnalysisResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future retryImageAnalysis(
  int imageId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/images/$imageId/retry-analysis',
    const {},
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

String _slugify(String name) {
  final trimmed = name.trim().toLowerCase();
  if (trimmed.isEmpty) return 'tag';
  return trimmed.replaceAll(RegExp(r'\s+'), '-');
}
