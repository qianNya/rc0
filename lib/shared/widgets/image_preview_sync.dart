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
