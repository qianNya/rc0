// --C:\Users\qianlNya\GolandProjects\rc0-go\service\data\api\data--

class DeleteObjectReq {
  final String bucket;

  final String objectKey;
  DeleteObjectReq({required this.bucket, required this.objectKey});
  factory DeleteObjectReq.fromJson(Map<String, dynamic> m) {
    return DeleteObjectReq(
      bucket: m['bucket'] ?? "",
      objectKey: m['object_key'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'object_key': objectKey};
  }
}

class PingResp {
  final String pong;
  PingResp({required this.pong});
  factory PingResp.fromJson(Map<String, dynamic> m) {
    return PingResp(pong: m['pong'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'pong': pong};
  }
}

class PresignDownloadReq {
  final String bucket;

  final String objectKey;

  final num expireSec;
  PresignDownloadReq({
    required this.bucket,
    required this.objectKey,
    required this.expireSec,
  });
  factory PresignDownloadReq.fromJson(Map<String, dynamic> m) {
    return PresignDownloadReq(
      bucket: m['bucket'] ?? "",
      objectKey: m['object_key'] ?? "",
      expireSec: m['expire_sec'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'object_key': objectKey, 'expire_sec': expireSec};
  }
}

class PresignDownloadResp {
  final String downloadUrl;

  final num expireAt;
  PresignDownloadResp({required this.downloadUrl, required this.expireAt});
  factory PresignDownloadResp.fromJson(Map<String, dynamic> m) {
    return PresignDownloadResp(
      downloadUrl: m['download_url'] ?? "",
      expireAt: m['expire_at'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'download_url': downloadUrl, 'expire_at': expireAt};
  }
}

class StatObjectReq {
  final String bucket;

  final String objectKey;
  StatObjectReq({required this.bucket, required this.objectKey});
  factory StatObjectReq.fromJson(Map<String, dynamic> m) {
    return StatObjectReq(
      bucket: m['bucket'] ?? "",
      objectKey: m['object_key'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {'bucket': bucket, 'object_key': objectKey};
  }
}

class StatObjectResp {
  final String bucket;

  final String objectKey;

  final num size;

  final String contentType;

  final String etag;

  final String lastModified;
  StatObjectResp({
    required this.bucket,
    required this.objectKey,
    required this.size,
    required this.contentType,
    required this.etag,
    required this.lastModified,
  });
  factory StatObjectResp.fromJson(Map<String, dynamic> m) {
    return StatObjectResp(
      bucket: m['bucket'] ?? "",
      objectKey: m['object_key'] ?? "",
      size: m['size'] ?? 0,
      contentType: m['content_type'] ?? "",
      etag: m['etag'] ?? "",
      lastModified: m['last_modified'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'object_key': objectKey,
      'size': size,
      'content_type': contentType,
      'etag': etag,
      'last_modified': lastModified,
    };
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
  UploadResp({
    required this.md5,
    required this.filename,
    required this.objectKey,
    required this.bucket,
    required this.storage,
    required this.size,
    required this.deduplicated,
    required this.url,
  });
  factory UploadResp.fromJson(Map<String, dynamic> m) {
    return UploadResp(
      md5: m['md5'] ?? "",
      filename: m['filename'] ?? "",
      objectKey: m['object_key'] ?? "",
      bucket: m['bucket'] ?? "",
      storage: m['storage'] ?? "",
      size: m['size'] ?? 0,
      deduplicated: m['deduplicated'] ?? false,
      url: m['url'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'md5': md5,
      'filename': filename,
      'object_key': objectKey,
      'bucket': bucket,
      'storage': storage,
      'size': size,
      'deduplicated': deduplicated,
      'url': url,
    };
  }
}
