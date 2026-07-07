import 'package:rc0_media/rc0_media.dart';

import '../../features/screenplay/data/data_upload_repository.dart';

UploadedImage uploadedImageFromMediaResult(UploadedMediaResult result) {
  return UploadedImage(
    imageId: result.imageId,
    displayUrl: result.displayUrl,
    thumbUrl: result.thumbUrl,
    displayFileId: result.displayFileId,
    thumbFileId: result.thumbFileId,
  );
}

Map<String, UploadedImage> uploadedImagesFromMediaBatch(
  Map<String, UploadedMediaResult> results,
) {
  return results.map(
    (key, value) => MapEntry(key, uploadedImageFromMediaResult(value)),
  );
}
