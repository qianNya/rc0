import 'package:rc0_core/rc0_core.dart';

/// Result of a successful image upload (maps to backend `acgn_image` + files).
class UploadedMediaResult {
  const UploadedMediaResult({
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

  ImageRef toImageRef({String? localPath}) => ImageRef(
        imageId: imageId.toString(),
        fileId: displayFileId?.toString(),
        remoteUrl: displayUrl.isNotEmpty ? displayUrl : null,
        localPath: localPath,
      );

  /// Dual-write legacy frame/cover map fields alongside unified [ImageRef].
  Map<String, dynamic> applyToFrameMap(Map<String, dynamic> frame) {
    return toImageRef(localPath: frame['local_image_path'] as String?)
        .applyToFrameMap(frame);
  }

  Map<String, dynamic> applyToCoverMap(Map<String, dynamic> screenplay) {
    return toImageRef(localPath: screenplay['local_cover_path'] as String?)
        .copyWith(remoteUrl: displayUrl.isNotEmpty ? displayUrl : null)
        .applyToCoverMap(screenplay);
  }
}

/// Unified upload contract (PRD §3.8). App layer provides HTTP implementation.
abstract interface class MediaUploadService {
  Future<({UploadedMediaResult? result, String? error})> uploadLocalFile(
    String localPath,
  );

  Future<({String? coverUrl, String? error})> uploadScreenplayCover({
    required int screenplayId,
    required String localPath,
  });

  Future<({Map<String, UploadedMediaResult>? results, String? error})>
      uploadLocalBatch(
    Map<String, String> refToLocalPath, {
    void Function(int done, int total)? onProgress,
  });
}
