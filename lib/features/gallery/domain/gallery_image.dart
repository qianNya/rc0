/// User-uploaded image shown in the personal gallery.
class GalleryImage {
  const GalleryImage({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.createAt,
  });

  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String createAt;

  String get displayUrl =>
      thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

  GalleryImage copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? thumbnailUrl,
    String? createAt,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createAt: createAt ?? this.createAt,
    );
  }
}
