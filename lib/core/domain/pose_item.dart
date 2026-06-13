class PoseItem {
  const PoseItem({
    required this.id,
    required this.title,
    required this.tags,
    required this.likes,
    required this.views,
    this.description =
        '侧身站立，一手插兜，头部微转看向镜头。适合街拍、日常穿搭展示，光线柔和时效果最佳。',
    this.author = '小林',
    this.authorBio = '摄影创作者',
    this.favorites = 56,
    this.coverImagePath,
    this.imagePaths = const [],
    this.isLocal = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final List<String> tags;
  final int likes;
  final int views;
  final String description;
  final String author;
  final String authorBio;
  final int favorites;
  final String? coverImagePath;
  final List<String> imagePaths;
  final bool isLocal;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'tags': tags,
        'likes': likes,
        'views': views,
        'description': description,
        'author': author,
        'authorBio': authorBio,
        'favorites': favorites,
        'imagePaths': imagePaths,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory PoseItem.fromJson(Map<String, dynamic> json) {
    final paths = (json['imagePaths'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const <String>[];
    return PoseItem(
      id: json['id'] as String,
      title: json['title'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      author: json['author'] as String? ?? '我',
      authorBio: json['authorBio'] as String? ?? '摄影创作者',
      favorites: json['favorites'] as int? ?? 0,
      coverImagePath: paths.isNotEmpty ? paths.first : null,
      imagePaths: paths,
      isLocal: true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
