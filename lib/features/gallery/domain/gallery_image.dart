import 'image_tag.dart';
import '../../../api/image/data/image-api.dart' show ImageFileInfo, formatImageFileSize, imageFileRoleLabel, mimeToShortLabel;

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
    this.primaryFile,
  });

  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String createAt;
  final List<String> tags;
  final List<int> tagIds;
  final ImageFileInfo? primaryFile;

  String get displayUrl =>
      thumbnailUrl.isNotEmpty ? thumbnailUrl : imageUrl;

  int? get width => primaryFile?.width;
  int? get height => primaryFile?.height;
  String? get mime => primaryFile?.mime;
  int? get fileSize => primaryFile?.fileSize;

  String get resolutionLabel {
    if (width != null && height != null) return '${width}×$height';
    return '—';
  }

  String get fileSizeLabel => formatImageFileSize(fileSize);

  String get formatLabel => mimeToShortLabel(mime);

  String get fileRoleLabel =>
      primaryFile == null ? '—' : imageFileRoleLabel(primaryFile!.fileRole);

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
    ImageFileInfo? primaryFile,
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
      primaryFile: primaryFile ?? this.primaryFile,
    );
  }
}
