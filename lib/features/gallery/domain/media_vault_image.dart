import 'package:flutter/material.dart';

import 'media_vault_types.dart';

/// Visual asset in the media vault.
class MediaVaultImage {
  const MediaVaultImage({
    required this.id,
    required this.title,
    required this.category,
    this.imageUrl,
    this.thumbnailUrl,
    this.tags = const [],
    this.albumId,
    this.createdAt,
    this.format,
    this.isFavorite = false,
    this.rating = 0,
    this.isRaw = false,
    this.exif = const {},
    this.placeholderIcon,
    this.placeholderColors,
    this.width,
    this.height,
    this.fileSizeMb,
    this.galleryImageId,
  });

  final String id;
  /// Backing [GalleryImage.id] when sourced from the user API.
  final int? galleryImageId;
  final String title;
  final MediaVaultCategory category;
  final String? imageUrl;
  final String? thumbnailUrl;
  final List<String> tags;
  final String? albumId;
  final DateTime? createdAt;
  final String? format;
  final bool isFavorite;
  final int rating;
  final bool isRaw;
  final Map<String, String> exif;
  final IconData? placeholderIcon;
  final List<Color>? placeholderColors;
  final int? width;
  final int? height;
  final double? fileSizeMb;

  String get displayUrl =>
      (thumbnailUrl?.isNotEmpty == true) ? thumbnailUrl! : (imageUrl ?? '');

  bool get hasNetworkImage => displayUrl.isNotEmpty;

  String get resolutionLabel {
    if (width != null && height != null) return '${width}x$height';
    return '—';
  }

  /// Width / height for masonry layout.
  double get displayAspectRatio {
    if (width != null && height != null && width! > 0 && height! > 0) {
      return width! / height!;
    }
    return 4 / 3;
  }

  MediaVaultImage copyWith({
    bool? isFavorite,
    int? rating,
    List<String>? tags,
    String? albumId,
  }) {
    return MediaVaultImage(
      id: id,
      title: title,
      category: category,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      tags: tags ?? this.tags,
      albumId: albumId ?? this.albumId,
      createdAt: createdAt,
      format: format,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      isRaw: isRaw,
      exif: exif,
      placeholderIcon: placeholderIcon,
      placeholderColors: placeholderColors,
      width: width,
      height: height,
      fileSizeMb: fileSizeMb,
      galleryImageId: galleryImageId,
    );
  }
}

class MediaAlbum {
  const MediaAlbum({
    required this.id,
    required this.name,
    required this.imageCount,
    this.coverColors,
    this.coverIcon,
  });

  final String id;
  final String name;
  final int imageCount;
  final List<Color>? coverColors;
  final IconData? coverIcon;
}

class MediaTagEntry {
  const MediaTagEntry({
    required this.name,
    required this.count,
    this.isAi = false,
  });

  final String name;
  final int count;
  final bool isAi;
}
