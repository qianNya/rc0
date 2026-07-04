import 'equipment_category.dart';

/// Second-level taxonomy under [EquipmentCategory]: e.g. Nikon, ARRI, Cooke.
///
/// Persisted on the backend in `cine_equipment_brand` (slug + name + category).
/// Bodies/lenses reference [id] via [CameraBody.brandId] / [Lens.brandId].
class EquipmentBrand {
  const EquipmentBrand({
    required this.id,
    required this.name,
    required this.category,
    required this.itemKind,
    this.sort = 0,
  });

  /// Stable slug, e.g. `nikon`, `arri`.
  final String id;

  /// Display name, e.g. `Nikon`, `尼康`.
  final String name;
  final EquipmentCategory category;
  final EquipmentItemKind itemKind;
  final int sort;

  EquipmentBrand copyWith({
    String? id,
    String? name,
    EquipmentCategory? category,
    EquipmentItemKind? itemKind,
    int? sort,
  }) {
    return EquipmentBrand(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      itemKind: itemKind ?? this.itemKind,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toJson() => {
        'slug': id,
        'name': name,
        'category': category.name,
        'item_kind': itemKind.name,
        'sort': sort,
      };

  factory EquipmentBrand.fromJson(Map<String, dynamic> json) {
    return EquipmentBrand(
      id: json['slug'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: _categoryFrom(json['category'] as String?),
      itemKind: _kindFrom(json['item_kind'] as String?),
      sort: (json['sort'] as num?)?.toInt() ?? 0,
    );
  }

  static EquipmentCategory _categoryFrom(String? raw) {
    return EquipmentCategory.values.firstWhere(
      (c) => c.name == raw,
      orElse: () => EquipmentCategory.photo,
    );
  }

  static EquipmentItemKind _kindFrom(String? raw) {
    return EquipmentItemKind.values.firstWhere(
      (k) => k.name == raw,
      orElse: () => EquipmentItemKind.body,
    );
  }
}

/// Derive a brand slug from a display name when seeding local catalog data.
String equipmentBrandSlug(String brandName) {
  final normalized = brandName.trim().toLowerCase();
  return switch (normalized) {
    'arrí' || 'arri' => 'arri',
    'fujifilm' || '富士' => 'fujifilm',
    'apple' => 'apple',
    _ => normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), ''),
  };
}
