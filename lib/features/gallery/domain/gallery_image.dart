import 'image_tag.dart';

/// User-uploaded image shown in the personal gallery.
class GalleryImage {
  const GalleryImage({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createAt,
    this.tags = const [],
    this.tagIds = const [],
  });

  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String createAt;
  final List<String> tags;
  final List<int> tagIds;

  String get displayUrl =>
      thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

  bool matchesTag(ImageTag tag) {
    if (tagIds.contains(tag.id)) return true;
    if (tags.contains(tag.name)) return true;
    if (tag.slug.isNotEmpty && tags.contains(tag.slug)) return true;
    return false;
  }

  GalleryImage copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? thumbnailUrl,
    String? createAt,
    List<String>? tags,
    List<int>? tagIds,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createAt: createAt ?? this.createAt,
      tags: tags ?? this.tags,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}
