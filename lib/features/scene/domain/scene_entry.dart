class SceneEntry {
  const SceneEntry({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.description,
    required this.category,
    required this.tags,
    required this.themes,
    required this.imageUrls,
    required this.location,
    required this.city,
    required this.shootingTips,
    required this.favoriteCount,
    required this.useCount,
    required this.viewCount,
    required this.rating,
    required this.sort,
    required this.createdAt,
    required this.updatedAt,
    this.isSeed = false,
  });

  final String id;
  final String title;
  final String coverUrl;
  final String description;
  final String category;
  final List<String> tags;
  final List<String> themes;
  final List<String> imageUrls;
  final String location;
  final String city;
  final Map<String, String> shootingTips;
  final int favoriteCount;
  final int useCount;
  final int viewCount;
  final double rating;
  final int sort;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSeed;

  List<String> get displayTags {
    final merged = <String>{category, ...tags};
    merged.removeWhere((t) => t.isEmpty);
    return merged.toList(growable: false);
  }

  SceneEntry copyWith({
    String? id,
    String? title,
    String? coverUrl,
    String? description,
    String? category,
    List<String>? tags,
    List<String>? themes,
    List<String>? imageUrls,
    String? location,
    String? city,
    Map<String, String>? shootingTips,
    int? favoriteCount,
    int? useCount,
    int? viewCount,
    double? rating,
    int? sort,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSeed,
  }) {
    return SceneEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      themes: themes ?? this.themes,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      city: city ?? this.city,
      shootingTips: shootingTips ?? this.shootingTips,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      useCount: useCount ?? this.useCount,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      sort: sort ?? this.sort,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSeed: isSeed ?? this.isSeed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cover_url': coverUrl,
        'description': description,
        'category': category,
        'tags': tags,
        'themes': themes,
        'image_urls': imageUrls,
        'location': location,
        'city': city,
        'shooting_tips': shootingTips,
        'favorite_count': favoriteCount,
        'use_count': useCount,
        'view_count': viewCount,
        'rating': rating,
        'sort': sort,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_seed': isSeed,
      };

  factory SceneEntry.fromJson(Map<String, dynamic> json) {
    final tipsRaw = json['shooting_tips'];
    final tips = <String, String>{};
    if (tipsRaw is Map) {
      tipsRaw.forEach((key, value) {
        if (key is String && value is String) tips[key] = value;
      });
    }
    return SceneEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const [],
      themes: (json['themes'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const [],
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const [],
      location: json['location'] as String? ?? '',
      city: json['city'] as String? ?? '',
      shootingTips: tips,
      favoriteCount: (json['favorite_count'] as num?)?.toInt() ?? 0,
      useCount: (json['use_count'] as num?)?.toInt() ?? 0,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      isSeed: json['is_seed'] as bool? ?? false,
    );
  }
}
