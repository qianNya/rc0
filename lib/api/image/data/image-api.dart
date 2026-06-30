/// Rust `ImageResponse.files[].file_role` values.
const kImageFileRoleOriginal = 1;
const kImageFileRoleDisplay = 2;
const kImageFileRoleFeed = 3;
const kImageFileRoleThumb = 4;

class ImageFileInfo {
  const ImageFileInfo({
    required this.id,
    required this.fileRole,
    required this.url,
  });

  final int id;
  final int fileRole;
  final String url;

  factory ImageFileInfo.fromJson(Map<String, dynamic> m) {
    return ImageFileInfo(
      id: (m['id'] as num?)?.toInt() ?? 0,
      fileRole: (m['file_role'] as num?)?.toInt() ?? kImageFileRoleOriginal,
      url: m['url'] as String? ?? '',
    );
  }
}

List<ImageFileInfo> parseImageFiles(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(ImageFileInfo.fromJson)
      .where((f) => f.url.isNotEmpty)
      .toList();
}

/// Resolved URLs/ids from `files[]` (display / feed / thumb), with legacy original fallback.
class ImageFilesBundle {
  const ImageFilesBundle({
    required this.displayUrl,
    required this.thumbUrl,
    required this.feedUrl,
    this.displayFileId,
    this.thumbFileId,
  });

  final String displayUrl;
  final String thumbUrl;
  final String feedUrl;
  final int? displayFileId;
  final int? thumbFileId;

  factory ImageFilesBundle.fromFiles(List<ImageFileInfo> files) {
    String? urlFor(int role) {
      for (final f in files) {
        if (f.fileRole == role && f.url.isNotEmpty) return f.url;
      }
      return null;
    }

    int? idFor(int role) {
      for (final f in files) {
        if (f.fileRole == role && f.id > 0) return f.id;
      }
      return null;
    }

    final display = urlFor(kImageFileRoleDisplay) ??
        urlFor(kImageFileRoleOriginal) ??
        (files.isNotEmpty ? files.first.url : '');
    final thumb = urlFor(kImageFileRoleThumb) ?? display;
    final feed = urlFor(kImageFileRoleFeed) ?? display;

    return ImageFilesBundle(
      displayUrl: display,
      thumbUrl: thumb,
      feedUrl: feed,
      displayFileId:
          idFor(kImageFileRoleDisplay) ?? idFor(kImageFileRoleOriginal),
      thumbFileId: idFor(kImageFileRoleThumb),
    );
  }

  factory ImageFilesBundle.fromApiJson(Map<String, dynamic> m) {
    return ImageFilesBundle.fromFiles(parseImageFiles(m['files']));
  }
}

List<String> parseImageTagNames(dynamic raw) {
  if (raw is! List) return const [];
  final names = <String>[];
  for (final entry in raw) {
    if (entry is String && entry.isNotEmpty) {
      names.add(entry);
      continue;
    }
    if (entry is Map) {
      final name = entry['name'] as String? ?? entry['slug'] as String? ?? '';
      if (name.isNotEmpty) names.add(name);
    }
  }
  return names;
}

List<int> parseImageTagIds(dynamic raw) {
  if (raw is! List) return const [];
  final ids = <int>[];
  for (final entry in raw) {
    if (entry is Map) {
      final id = (entry['id'] as num?)?.toInt();
      if (id != null) ids.add(id);
    }
  }
  return ids;
}

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
    if (fileRole == kImageFileRoleDisplay) {
      return imageUrlFromApiJson(m, fileRole: kImageFileRoleOriginal);
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
  final List<String> tags;
  final List<int> tagIds;

  GalleryImageItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createAt,
    this.tags = const [],
    this.tagIds = const [],
  });

  factory GalleryImageItem.fromJson(Map<String, dynamic> m) {
    final bundle = ImageFilesBundle.fromApiJson(m);
    final rawTags = m['tags'];
    return GalleryImageItem(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      imageUrl: m['image_url'] as String? ?? bundle.displayUrl,
      thumbnailUrl:
          m['thumbnail_url'] as String? ?? bundle.thumbUrl,
      createAt: m['create_at']?.toString() ?? '',
      tags: parseImageTagNames(rawTags),
      tagIds: parseImageTagIds(rawTags),
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
  final List<String> tags;
  final List<int> tagIds;
  final List<ImageFileInfo> files;
  final ImageFilesBundle filesBundle;

  ImageDetailResp({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createAt,
    this.tags = const [],
    this.tagIds = const [],
    this.files = const [],
    ImageFilesBundle? filesBundle,
  }) : filesBundle = filesBundle ??
            ImageFilesBundle.fromFiles(files);

  factory ImageDetailResp.fromJson(Map<String, dynamic> m) {
    final bundle = ImageFilesBundle.fromApiJson(m);
    final rawTags = m['tags'];
    return ImageDetailResp(
      id: m['id'] ?? 0,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      imageUrl: m['image_url'] as String? ?? bundle.displayUrl,
      thumbnailUrl: m['thumbnail_url'] as String? ?? bundle.thumbUrl,
      createAt: m['create_at']?.toString() ?? '',
      tags: parseImageTagNames(rawTags),
      tagIds: parseImageTagIds(rawTags),
      files: parseImageFiles(m['files']),
      filesBundle: bundle,
    );
  }
}

class ImageAnalysisResp {
  ImageAnalysisResp({
    required this.status,
    required this.summary,
    this.labels = const [],
    this.rawJson = const {},
  });

  final String status;
  final String summary;
  final List<String> labels;
  final Map<String, dynamic> rawJson;

  factory ImageAnalysisResp.fromJson(Map<String, dynamic> m) {
    final labelsRaw = m['labels'] ?? m['tags'];
    return ImageAnalysisResp(
      status: m['status']?.toString() ?? 'unknown',
      summary: m['summary']?.toString() ?? m['description']?.toString() ?? '',
      labels: labelsRaw is List
          ? labelsRaw.map((e) => e.toString()).toList()
          : const [],
      rawJson: m,
    );
  }
}

class ImageTagItem {
  final num id;
  final String name;
  final String slug;
  final String namespace;
  final num imageCount;

  ImageTagItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.namespace,
    this.imageCount = 0,
  });

  factory ImageTagItem.fromJson(Map<String, dynamic> m) {
    return ImageTagItem(
      id: m['id'] ?? 0,
      name: m['name'] ?? '',
      slug: m['slug'] ?? '',
      namespace: m['namespace'] ?? '',
      imageCount: m['image_count'] ?? m['count'] ?? 0,
    );
  }
}

class ListImageTagsResp {
  final List<ImageTagItem> list;

  ListImageTagsResp({required this.list});

  factory ListImageTagsResp.fromJson(dynamic data) {
    if (data is List) {
      return ListImageTagsResp(
        list: data
            .whereType<Map<String, dynamic>>()
            .map(ImageTagItem.fromJson)
            .toList(),
      );
    }
    if (data is Map<String, dynamic>) {
      final raw = (data['items'] ?? data['list'] ?? data['tags'] ?? []) as List;
      return ListImageTagsResp(
        list: raw
            .whereType<Map<String, dynamic>>()
            .map(ImageTagItem.fromJson)
            .toList(),
      );
    }
    return ListImageTagsResp(list: const []);
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
