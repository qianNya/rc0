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
