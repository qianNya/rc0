/// Rust `ImageResponse.files[].file_role`: 1 = original.
const _kImageFileRoleOriginal = 1;

/// Resolves display URL from flat fields or nested `files` (MinIO http/https).
String? imageUrlFromApiJson(Map<String, dynamic> m, {int? fileRole}) {
  for (final key in ['image_url', 'url']) {
    final direct = m[key] as String? ?? '';
    if (direct.isNotEmpty) return direct;
  }

  final files = m['files'];
  if (files is! List || files.isEmpty) return null;

  if (fileRole != null) {
    for (final entry in files) {
      if (entry is! Map<String, dynamic>) continue;
      if ((entry['file_role'] as num?)?.toInt() != fileRole) continue;
      final url = entry['url'] as String? ?? '';
      if (url.isNotEmpty) return url;
    }
  }

  for (final entry in files) {
    if (entry is! Map<String, dynamic>) continue;
    final url = entry['url'] as String? ?? '';
    if (url.isNotEmpty) return url;
  }
  return null;
}

class GalleryImageItem {
  final num id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String createAt;

  GalleryImageItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createAt,
  });

  factory GalleryImageItem.fromJson(Map<String, dynamic> m) {
    final fileUrl = imageUrlFromApiJson(m, fileRole: _kImageFileRoleOriginal);
    final thumbFromFiles = imageUrlFromApiJson(m);
    return GalleryImageItem(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      imageUrl: m['image_url'] ?? fileUrl ?? m['url'] ?? '',
      thumbnailUrl:
          m['thumbnail_url'] ?? m['image_url'] ?? thumbFromFiles ?? m['url'] ?? '',
      createAt: m['create_at']?.toString() ?? '',
    );
  }
}

class ListImagesResp {
  final List<GalleryImageItem> list;
  final num total;
  final num page;
  final num pageSize;

  ListImagesResp({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory ListImagesResp.fromJson(Map<String, dynamic> m) {
    final rawItems = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    return ListImagesResp(
      list: rawItems
          .map((i) => GalleryImageItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: m['total'] ?? 0,
      page: m['page'] ?? 1,
      pageSize: m['page_size'] ?? 20,
    );
  }
}

class ImageDetailResp {
  final num id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String createAt;

  ImageDetailResp({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createAt,
  });

  factory ImageDetailResp.fromJson(Map<String, dynamic> m) {
    final fileUrl = imageUrlFromApiJson(m, fileRole: _kImageFileRoleOriginal);
    final thumbFromFiles = imageUrlFromApiJson(m);
    return ImageDetailResp(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      imageUrl: m['image_url'] ?? fileUrl ?? m['url'] ?? '',
      thumbnailUrl:
          m['thumbnail_url'] ?? m['image_url'] ?? thumbFromFiles ?? m['url'] ?? '',
      createAt: m['create_at']?.toString() ?? '',
    );
  }
}

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
