class ToggleEngagementResp {
  final bool active;
  final num count;

  ToggleEngagementResp({required this.active, required this.count});

  factory ToggleEngagementResp.fromJson(Map<String, dynamic> m) {
    return ToggleEngagementResp(
      active: m['active'] ?? m['is_liked'] ?? m['is_favorited'] ?? false,
      count: m['count'] ?? m['like_count'] ?? m['favorite_count'] ?? 0,
    );
  }
}

class ScreenplayTagItem {
  final num id;
  final String name;
  final String slug;
  final String namespace;

  ScreenplayTagItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.namespace,
  });

  factory ScreenplayTagItem.fromJson(Map<String, dynamic> m) {
    return ScreenplayTagItem(
      id: m['id'] ?? 0,
      name: m['name'] ?? '',
      slug: m['slug'] ?? '',
      namespace: m['namespace'] ?? '',
    );
  }
}

class ListScreenplayTagsResp {
  final List<ScreenplayTagItem> list;

  ListScreenplayTagsResp({required this.list});

  factory ListScreenplayTagsResp.fromJson(dynamic data) {
    if (data is List) {
      return ListScreenplayTagsResp(
        list: data
            .whereType<Map<String, dynamic>>()
            .map(ScreenplayTagItem.fromJson)
            .toList(),
      );
    }
    if (data is Map<String, dynamic>) {
      final raw = (data['items'] ?? data['list'] ?? data['tags'] ?? []) as List;
      return ListScreenplayTagsResp(
        list: raw
            .whereType<Map<String, dynamic>>()
            .map(ScreenplayTagItem.fromJson)
            .toList(),
      );
    }
    return ListScreenplayTagsResp(list: const []);
  }
}
