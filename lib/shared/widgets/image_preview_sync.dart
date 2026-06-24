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
