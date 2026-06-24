import 'shoot_params.dart';

/// Preset origin: 0 = official, 1 = community, null = user-owned.
enum ShootPresetScope { official, community, personal }

ShootPresetScope? shootPresetScopeFromInt(int? value) {
  return switch (value) {
    0 => ShootPresetScope.official,
    1 => ShootPresetScope.community,
    _ => null,
  };
}

int? shootPresetScopeToInt(ShootPresetScope? scope) {
  return switch (scope) {
    ShootPresetScope.official => 0,
    ShootPresetScope.community => 1,
    ShootPresetScope.personal => null,
    null => null,
  };
}

/// Combined shoot preset card (device + aspect + lighting).
class ShootPreset {
  const ShootPreset({
    required this.id,
    required this.label,
    required this.params,
    this.subtitle,
    this.isBuiltIn = false,
    this.remoteId,
    this.createdAt,
    this.updatedAt,
    this.coverImageUrl,
    this.likeCount,
    this.usageCount,
    this.downloadCount,
    this.favoriteCount,
    this.rating,
    this.authorName,
    this.authorAvatarUrl,
    this.scope,
    this.categoryId,
  });

  final String id;
  final String label;
  final String? subtitle;
  final ShootParams params;
  final bool isBuiltIn;
  final int? remoteId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? coverImageUrl;
  final int? likeCount;
  final int? usageCount;
  final int? downloadCount;
  final int? favoriteCount;
  final double? rating;
  final String? authorName;
  final String? authorAvatarUrl;
  final ShootPresetScope? scope;
  final String? categoryId;

  bool get isCommunity => scope == ShootPresetScope.community;

  bool get isOfficial =>
      isBuiltIn || scope == ShootPresetScope.official;

  String get displaySubtitle => subtitle ?? subtitleFromParams(params);

  String get deviceLabel =>
      params.device?.isNotEmpty == true ? params.device! : '未指定设备';

  String get aspectLightingLabel {
    final parts = <String>[
      if (params.aspectRatio != null && params.aspectRatio!.isNotEmpty)
        params.aspectRatio!,
      if (params.lighting != null && params.lighting!.isNotEmpty)
        params.lighting!,
    ];
    return parts.join(' · ');
  }

  static String subtitleFromParams(ShootParams params) {
    final parts = <String>[
      if (params.device != null && params.device!.isNotEmpty) params.device!,
      if (params.aspectRatio != null && params.aspectRatio!.isNotEmpty)
        params.aspectRatio!,
      if (params.lighting != null && params.lighting!.isNotEmpty)
        params.lighting!,
    ];
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        if (subtitle != null) 'subtitle': subtitle,
        'params': params.toJson(),
        'is_built_in': isBuiltIn,
        if (remoteId != null) 'remote_id': remoteId,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (likeCount != null) 'like_count': likeCount,
        if (usageCount != null) 'usage_count': usageCount,
        if (downloadCount != null) 'download_count': downloadCount,
        if (favoriteCount != null) 'favorite_count': favoriteCount,
        if (rating != null) 'rating': rating,
        if (authorName != null) 'author_name': authorName,
        if (authorAvatarUrl != null) 'author_avatar_url': authorAvatarUrl,
        if (scope != null) 'scope': shootPresetScopeToInt(scope),
        if (categoryId != null) 'category_id': categoryId,
      };

  factory ShootPreset.fromJson(Map<String, dynamic> json) {
    return ShootPreset(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      params: ShootParams.fromJson(
        json['params'] as Map<String, dynamic>?,
      ),
      isBuiltIn: json['is_built_in'] as bool? ?? false,
      remoteId: (json['remote_id'] as num?)?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      coverImageUrl: json['cover_image_url'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt(),
      usageCount: (json['usage_count'] as num?)?.toInt(),
      downloadCount: (json['download_count'] as num?)?.toInt(),
      favoriteCount: (json['favorite_count'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      authorName: json['author_name'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      scope: shootPresetScopeFromInt((json['scope'] as num?)?.toInt()),
      categoryId: json['category_id'] as String?,
    );
  }

  ShootPreset copyWith({
    String? id,
    String? label,
    String? subtitle,
    ShootParams? params,
    bool? isBuiltIn,
    int? remoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverImageUrl,
    int? likeCount,
    int? usageCount,
    int? downloadCount,
    int? favoriteCount,
    double? rating,
    String? authorName,
    String? authorAvatarUrl,
    ShootPresetScope? scope,
    String? categoryId,
  }) {
    return ShootPreset(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: subtitle ?? this.subtitle,
      params: params ?? this.params,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      remoteId: remoteId ?? this.remoteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      likeCount: likeCount ?? this.likeCount,
      usageCount: usageCount ?? this.usageCount,
      downloadCount: downloadCount ?? this.downloadCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      rating: rating ?? this.rating,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      scope: scope ?? this.scope,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
