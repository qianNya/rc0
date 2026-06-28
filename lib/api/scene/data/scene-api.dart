class SceneItem {
  SceneItem({
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
    required this.isSeed,
  });

  final num id;
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
  final num favoriteCount;
  final num useCount;
  final num viewCount;
  final num rating;
  final num sort;
  final bool isSeed;

  factory SceneItem.fromJson(Map<String, dynamic> m) {
    final tipsRaw = m['shooting_tips'];
    final tips = <String, String>{};
    if (tipsRaw is Map) {
      tipsRaw.forEach((key, value) {
        if (key is String && value is String) tips[key] = value;
      });
    }

    return SceneItem(
      id: m['id'] ?? 0,
      title: m['title'] as String? ?? '',
      coverUrl: m['cover_url'] as String? ?? '',
      description: m['description'] as String? ?? '',
      category: m['category'] as String? ?? '',
      tags: _stringList(m['tags']),
      themes: _stringList(m['themes']),
      imageUrls: _stringList(m['image_urls']),
      location: m['location'] as String? ?? '',
      city: m['city'] as String? ?? '',
      shootingTips: tips,
      favoriteCount: m['favorite_count'] ?? 0,
      useCount: m['use_count'] ?? 0,
      viewCount: m['view_count'] ?? 0,
      rating: m['rating'] ?? 0,
      sort: m['sort'] ?? 0,
      isSeed: m['is_seed'] as bool? ?? false,
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}

class ListScenesResp {
  ListScenesResp({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<SceneItem> list;
  final num total;
  final num page;
  final num pageSize;

  factory ListScenesResp.fromJson(Map<String, dynamic> m) {
    final raw = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    return ListScenesResp(
      list: raw
          .whereType<Map<String, dynamic>>()
          .map(SceneItem.fromJson)
          .toList(),
      total: m['total'] ?? 0,
      page: m['page'] ?? 1,
      pageSize: m['page_size'] ?? 20,
    );
  }
}

class SceneWriteBody {
  const SceneWriteBody({
    required this.title,
    this.coverUrl = '',
    this.description = '',
    this.category = '',
    this.tags = const [],
    this.themes = const [],
    this.imageUrls = const [],
    this.location = '',
    this.city = '',
    this.shootingTips = const {},
    this.sort = 0,
  });

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
  final int sort;

  Map<String, dynamic> toJson() => {
        'title': title,
        'cover_url': coverUrl,
        if (description.isNotEmpty) 'description': description,
        if (category.isNotEmpty) 'category': category,
        if (tags.isNotEmpty) 'tags': tags,
        if (themes.isNotEmpty) 'themes': themes,
        if (imageUrls.isNotEmpty) 'image_urls': imageUrls,
        if (location.isNotEmpty) 'location': location,
        if (city.isNotEmpty) 'city': city,
        if (shootingTips.isNotEmpty) 'shooting_tips': shootingTips,
        'sort': sort,
      };
}
