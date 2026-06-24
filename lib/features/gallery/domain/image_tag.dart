/// Image tag from `GET /image-tags`.
class ImageTag {
  const ImageTag({
    required this.id,
    required this.name,
    required this.slug,
    required this.namespace,
    this.imageCount = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String namespace;
  final int imageCount;
}
