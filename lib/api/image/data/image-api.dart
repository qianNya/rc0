class ImageUploadResp {
  final num id;
  final String title;
  final String description;
  final String createAt;

  ImageUploadResp({
    required this.id,
    required this.title,
    required this.description,
    required this.createAt,
  });

  factory ImageUploadResp.fromJson(Map<String, dynamic> m) {
    return ImageUploadResp(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      createAt: m['create_at'] ?? '',
    );
  }
}

class ImageDownloadResp {
  final String downloadUrl;
  final num expireSec;

  ImageDownloadResp({required this.downloadUrl, required this.expireSec});

  factory ImageDownloadResp.fromJson(Map<String, dynamic> m) {
    return ImageDownloadResp(
      downloadUrl: m['download_url'] ?? '',
      expireSec: m['expire_sec'] ?? 0,
    );
  }
}

class UploadResp {
  final String md5;
  final String filename;
  final String objectKey;
  final String bucket;
  final String storage;
  final num size;
  final bool deduplicated;
  final String url;
  final num imageId;

  UploadResp({
    required this.md5,
    required this.filename,
    required this.objectKey,
    required this.bucket,
    required this.storage,
    required this.size,
    required this.deduplicated,
    required this.url,
    required this.imageId,
  });

  factory UploadResp.fromJson(Map<String, dynamic> m) {
    return UploadResp(
      md5: m['md5'] ?? '',
      filename: m['filename'] ?? '',
      objectKey: m['object_key'] ?? '',
      bucket: m['bucket'] ?? '',
      storage: m['storage'] ?? '',
      size: m['size'] ?? 0,
      deduplicated: m['deduplicated'] ?? false,
      url: m['url'] ?? m['download_url'] ?? '',
      imageId: m['id'] ?? 0,
    );
  }
}
