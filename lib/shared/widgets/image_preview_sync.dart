import '../../api/image/data/image-api.dart';
import '../../features/gallery/domain/gallery_image.dart';

enum ImageSyncStatus {
  localOnly,
  uploaded,
  remoteOnly,
  localAndRemote,
  uploading,
  failed,
}

class ImagePreviewSyncInfo {
  const ImagePreviewSyncInfo({
    required this.status,
    this.serverImageId,
    this.statusMessage,
  });

  final ImageSyncStatus status;
  final int? serverImageId;
  final String? statusMessage;

  ImagePreviewSyncInfo copyWith({
    ImageSyncStatus? status,
    int? serverImageId,
    String? statusMessage,
  }) {
    return ImagePreviewSyncInfo(
      status: status ?? this.status,
      serverImageId: serverImageId ?? this.serverImageId,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  String get label {
    if (statusMessage != null && statusMessage!.isNotEmpty) {
      return statusMessage!;
    }
    return switch (status) {
      ImageSyncStatus.localOnly => '仅本地',
      ImageSyncStatus.uploaded => '已上传',
      ImageSyncStatus.remoteOnly => '待下载本地副本',
      ImageSyncStatus.localAndRemote => '已上传',
      ImageSyncStatus.uploading => '上传中…',
      ImageSyncStatus.failed => '上传失败',
    };
  }

  bool get canUpload =>
      status == ImageSyncStatus.localOnly || status == ImageSyncStatus.failed;

  static ImagePreviewSyncInfo uploaded({int? serverImageId}) {
    return ImagePreviewSyncInfo(
      status: ImageSyncStatus.uploaded,
      serverImageId: serverImageId,
    );
  }
}

/// File metadata shown in the fullscreen image preview.
class ImagePreviewMetaInfo {
  const ImagePreviewMetaInfo({
    this.imageId,
    this.fileRole,
    this.storage,
    this.bucket,
    this.objectKey,
    this.url,
    this.mime,
    this.fileSize,
    this.width,
    this.height,
    this.checksum,
  });

  final int? imageId;
  final int? fileRole;
  final String? storage;
  final String? bucket;
  final String? objectKey;
  final String? url;
  final String? mime;
  final int? fileSize;
  final int? width;
  final int? height;
  final String? checksum;

  factory ImagePreviewMetaInfo.fromGalleryImage(GalleryImage image) {
    final file = image.primaryFile;
    return ImagePreviewMetaInfo(
      imageId: image.id,
      fileRole: file?.fileRole,
      storage: _nonEmpty(file?.storage),
      bucket: _nonEmpty(file?.bucket),
      objectKey: _nonEmpty(file?.objectKey),
      url: _nonEmpty(file?.url) ?? _nonEmpty(image.imageUrl),
      mime: _nonEmpty(file?.mime) ?? _nonEmpty(image.mime),
      fileSize: file?.fileSize ?? image.fileSize,
      width: file?.width ?? image.width,
      height: file?.height ?? image.height,
      checksum: _nonEmpty(file?.checksum),
    );
  }

  factory ImagePreviewMetaInfo.fromFile(
    ImageFileInfo file, {
    required int imageId,
  }) {
    return ImagePreviewMetaInfo(
      imageId: imageId,
      fileRole: file.fileRole,
      storage: _nonEmpty(file.storage),
      bucket: _nonEmpty(file.bucket),
      objectKey: _nonEmpty(file.objectKey),
      url: _nonEmpty(file.url),
      mime: _nonEmpty(file.mime),
      fileSize: file.fileSize,
      width: file.width,
      height: file.height,
      checksum: _nonEmpty(file.checksum),
    );
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  bool get hasPrimaryInfo =>
      imageId != null ||
      (width != null && height != null) ||
      (mime != null && mime!.isNotEmpty) ||
      (fileSize != null && fileSize! > 0);

  bool get hasSecondaryInfo =>
      (storage != null && storage!.isNotEmpty) ||
      (bucket != null && bucket!.isNotEmpty) ||
      (objectKey != null && objectKey!.isNotEmpty) ||
      (checksum != null && checksum!.isNotEmpty) ||
      (url != null && url!.isNotEmpty);

  String get resolutionLabel {
    if (width != null && height != null) return '${width}×$height';
    return '—';
  }

  String get fileSizeLabel => formatImageFileSize(fileSize);

  String get formatLabel => mimeToShortLabel(mime);

  String get fileRoleLabel =>
      fileRole == null ? '—' : imageFileRoleLabel(fileRole!);

  String get storageLabel {
    final parts = <String>[
      if (storage != null && storage!.isNotEmpty) storage!,
      if (bucket != null && bucket!.isNotEmpty) bucket!,
    ];
    return parts.isEmpty ? '—' : parts.join(' / ');
  }

  String get shortChecksum {
    final value = checksum ?? '';
    if (value.isEmpty) return '—';
    if (value.length <= 12) return value;
    return '${value.substring(0, 8)}…${value.substring(value.length - 4)}';
  }

  String get shortUrl {
    final value = url ?? '';
    if (value.isEmpty) return '—';
    if (value.length <= 48) return value;
    return '${value.substring(0, 28)}…${value.substring(value.length - 12)}';
  }

  List<({String label, String value})> get primaryRows => [
        if (imageId != null) (label: '图片 ID', value: '#$imageId'),
        (label: '文件角色', value: fileRoleLabel),
        (label: '分辨率', value: resolutionLabel),
        (label: '格式', value: formatLabel),
        (label: '大小', value: fileSizeLabel),
      ];

  List<({String label, String value})> get secondaryRows => [
        if (storage != null && storage!.isNotEmpty)
          (label: '存储', value: storage!),
        if (bucket != null && bucket!.isNotEmpty)
          (label: '存储桶', value: bucket!),
        if (objectKey != null && objectKey!.isNotEmpty)
          (label: '对象键', value: objectKey!),
        if (checksum != null && checksum!.isNotEmpty)
          (label: '校验和', value: shortChecksum),
        if (url != null && url!.isNotEmpty) (label: 'URL', value: shortUrl),
      ];
}

/// Per-image tag state for gallery preview editing.
class ImagePreviewTagState {
  const ImagePreviewTagState({
    this.serverImageId,
    this.tags = const [],
    this.tagIds = const [],
  });

  final int? serverImageId;
  final List<String> tags;
  final List<int> tagIds;

  ImagePreviewTagState copyWith({
    int? serverImageId,
    List<String>? tags,
    List<int>? tagIds,
  }) {
    return ImagePreviewTagState(
      serverImageId: serverImageId ?? this.serverImageId,
      tags: tags ?? this.tags,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}
