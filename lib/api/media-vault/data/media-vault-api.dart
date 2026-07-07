class MediaVaultAlbumItem {
  MediaVaultAlbumItem({
    required this.id,
    required this.title,
    this.coverImageId,
    this.imageCount = 0,
    this.createAt = '',
    this.updateAt = '',
  });

  final int id;
  final String title;
  final int? coverImageId;
  final int imageCount;
  final String createAt;
  final String updateAt;

  factory MediaVaultAlbumItem.fromJson(Map<String, dynamic> m) {
    return MediaVaultAlbumItem(
      id: (m['id'] as num?)?.toInt() ?? 0,
      title: m['title'] as String? ?? '',
      coverImageId: (m['cover_image_id'] as num?)?.toInt(),
      imageCount: (m['image_count'] as num?)?.toInt() ?? 0,
      createAt: m['create_at'] as String? ?? '',
      updateAt: m['update_at'] as String? ?? '',
    );
  }
}

class MediaVaultImageStateItem {
  MediaVaultImageStateItem({
    required this.imageId,
    this.isFavorite = false,
    this.inTrash = false,
    this.trashedAt,
    this.updateAt = '',
  });

  final int imageId;
  final bool isFavorite;
  final bool inTrash;
  final String? trashedAt;
  final String updateAt;

  factory MediaVaultImageStateItem.fromJson(Map<String, dynamic> m) {
    return MediaVaultImageStateItem(
      imageId: (m['image_id'] as num?)?.toInt() ?? 0,
      isFavorite: m['is_favorite'] == true,
      inTrash: m['in_trash'] == true,
      trashedAt: m['trashed_at'] as String?,
      updateAt: m['update_at'] as String? ?? '',
    );
  }
}

class MediaVaultAlbumMembershipItem {
  MediaVaultAlbumMembershipItem({
    required this.albumId,
    required this.imageId,
  });

  final int albumId;
  final int imageId;

  factory MediaVaultAlbumMembershipItem.fromJson(Map<String, dynamic> m) {
    return MediaVaultAlbumMembershipItem(
      albumId: (m['album_id'] as num?)?.toInt() ?? 0,
      imageId: (m['image_id'] as num?)?.toInt() ?? 0,
    );
  }
}

class MediaVaultMetricsItem {
  MediaVaultMetricsItem({
    this.imageCount = 0,
    this.usedBytes = 0,
    this.quotaBytes = 0,
  });

  final int imageCount;
  final int usedBytes;
  final int quotaBytes;

  factory MediaVaultMetricsItem.fromJson(Map<String, dynamic> m) {
    return MediaVaultMetricsItem(
      imageCount: (m['image_count'] as num?)?.toInt() ?? 0,
      usedBytes: (m['used_bytes'] as num?)?.toInt() ?? 0,
      quotaBytes: (m['quota_bytes'] as num?)?.toInt() ?? 0,
    );
  }
}

class MediaVaultCreateAlbumBody {
  MediaVaultCreateAlbumBody({
    required this.title,
    this.coverImageId,
  });

  final String title;
  final int? coverImageId;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (coverImageId != null) 'cover_image_id': coverImageId,
      };
}

class MediaVaultPatchImageStateBody {
  MediaVaultPatchImageStateBody({
    this.isFavorite,
    this.inTrash,
  });

  final bool? isFavorite;
  final bool? inTrash;

  Map<String, dynamic> toJson() => {
        if (isFavorite != null) 'is_favorite': isFavorite,
        if (inTrash != null) 'in_trash': inTrash,
      };
}
