class CinePresetItem {
  CinePresetItem({
    required this.id,
    required this.categoryId,
    required this.scope,
    required this.name,
    required this.description,
    required this.params,
    required this.isDefault,
    required this.creator,
  });

  final num id;
  final num categoryId;
  final num scope;
  final String name;
  final String description;
  final Map<String, dynamic> params;
  final bool isDefault;
  final num creator;

  bool get isBuiltIn => scope.toInt() == 0;

  factory CinePresetItem.fromJson(Map<String, dynamic> m) {
    final rawParams = m['params'];
    return CinePresetItem(
      id: m['id'] ?? 0,
      categoryId: m['category_id'] ?? 0,
      scope: m['scope'] ?? 0,
      name: m['name'] ?? '',
      description: m['description'] ?? '',
      params: rawParams is Map<String, dynamic>
          ? rawParams
          : (rawParams is Map ? Map<String, dynamic>.from(rawParams) : {}),
      isDefault: (m['is_default'] ?? 0) == 1,
      creator: m['creator'] ?? 0,
    );
  }
}

class CinePresetWriteBody {
  const CinePresetWriteBody({
    required this.name,
    this.description = '',
    this.categoryId,
    required this.params,
  });

  final String name;
  final String description;
  final int? categoryId;
  final Map<String, dynamic> params;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        if (categoryId != null) 'category_id': categoryId,
        'params': params,
      };
}

class CinePresetUpdateBody {
  const CinePresetUpdateBody({
    this.name,
    this.description,
    this.params,
  });

  final String? name;
  final String? description;
  final Map<String, dynamic>? params;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (params != null) json['params'] = params;
    return json;
  }
}
