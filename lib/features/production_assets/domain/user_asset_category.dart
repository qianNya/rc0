class UserAssetCategory {
  const UserAssetCategory({
    required this.id,
    required this.label,
    this.iconName = 'category_outlined',
    this.sort = 0,
    this.remoteId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String label;
  final String iconName;
  final int sort;
  final int? remoteId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserAssetCategory copyWith({
    String? id,
    String? label,
    String? iconName,
    int? sort,
    int? remoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAssetCategory(
      id: id ?? this.id,
      label: label ?? this.label,
      iconName: iconName ?? this.iconName,
      sort: sort ?? this.sort,
      remoteId: remoteId ?? this.remoteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'icon_name': iconName,
        'sort': sort,
        if (remoteId != null) 'remote_id': remoteId,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  factory UserAssetCategory.fromJson(Map<String, dynamic> json) {
    final remoteRaw = json['remote_id'] ?? json['remoteId'];
    return UserAssetCategory(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'category_outlined',
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      remoteId: remoteRaw is num ? remoteRaw.toInt() : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
