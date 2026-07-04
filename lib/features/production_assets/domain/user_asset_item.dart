class UserAssetItem {
  const UserAssetItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.brand = '',
    this.model = '',
    this.notes = '',
    this.remoteId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String name;
  final String brand;
  final String model;
  final String notes;
  final int? remoteId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displaySubtitle {
    final parts = <String>[
      if (brand.isNotEmpty) brand,
      if (model.isNotEmpty) model,
    ];
    if (parts.isEmpty && notes.isNotEmpty) {
      return notes;
    }
    return parts.join(' · ');
  }

  UserAssetItem copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? brand,
    String? model,
    String? notes,
    int? remoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserAssetItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      notes: notes ?? this.notes,
      remoteId: remoteId ?? this.remoteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'brand': brand,
        'model': model,
        'notes': notes,
        if (remoteId != null) 'remote_id': remoteId,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  factory UserAssetItem.fromJson(Map<String, dynamic> json) {
    final remoteRaw = json['remote_id'] ?? json['remoteId'];
    return UserAssetItem(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
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
