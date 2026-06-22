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
