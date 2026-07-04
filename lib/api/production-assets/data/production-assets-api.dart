class ProductionAssetCategoryItem {
  ProductionAssetCategoryItem({
    required this.id,
    required this.label,
    this.iconName = 'category_outlined',
    this.sort = 0,
    this.createAt,
    this.updateAt,
  });

  final int id;
  final String label;
  final String iconName;
  final int sort;
  final DateTime? createAt;
  final DateTime? updateAt;

  factory ProductionAssetCategoryItem.fromJson(Map<String, dynamic> m) {
    return ProductionAssetCategoryItem(
      id: (m['id'] as num?)?.toInt() ?? 0,
      label: m['label'] as String? ?? '',
      iconName: m['icon_name'] as String? ?? 'category_outlined',
      sort: (m['sort'] as num?)?.toInt() ?? 0,
      createAt: m['create_at'] != null
          ? DateTime.tryParse(m['create_at'] as String)
          : null,
      updateAt: m['update_at'] != null
          ? DateTime.tryParse(m['update_at'] as String)
          : null,
    );
  }
}

class ProductionAssetItemDto {
  ProductionAssetItemDto({
    required this.id,
    required this.categoryRef,
    required this.name,
    this.brand = '',
    this.model = '',
    this.notes = '',
    this.createAt,
    this.updateAt,
  });

  final int id;
  final String categoryRef;
  final String name;
  final String brand;
  final String model;
  final String notes;
  final DateTime? createAt;
  final DateTime? updateAt;

  factory ProductionAssetItemDto.fromJson(Map<String, dynamic> m) {
    return ProductionAssetItemDto(
      id: (m['id'] as num?)?.toInt() ?? 0,
      categoryRef: m['category_ref'] as String? ?? '',
      name: m['name'] as String? ?? '',
      brand: m['brand'] as String? ?? '',
      model: m['model'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
      createAt: m['create_at'] != null
          ? DateTime.tryParse(m['create_at'] as String)
          : null,
      updateAt: m['update_at'] != null
          ? DateTime.tryParse(m['update_at'] as String)
          : null,
    );
  }
}

class ProductionAssetCategoryWriteBody {
  ProductionAssetCategoryWriteBody({
    required this.label,
    this.iconName = 'category_outlined',
    this.sort = 0,
  });

  final String label;
  final String iconName;
  final int sort;

  Map<String, dynamic> toJson() => {
        'label': label,
        'icon_name': iconName,
        'sort': sort,
      };
}

class ProductionAssetCategoryUpdateBody {
  ProductionAssetCategoryUpdateBody({
    this.label,
    this.iconName,
    this.sort,
  });

  final String? label;
  final String? iconName;
  final int? sort;

  Map<String, dynamic> toJson() => {
        if (label != null) 'label': label,
        if (iconName != null) 'icon_name': iconName,
        if (sort != null) 'sort': sort,
      };
}

class ProductionAssetItemWriteBody {
  ProductionAssetItemWriteBody({
    required this.categoryRef,
    required this.name,
    this.brand = '',
    this.model = '',
    this.notes = '',
  });

  final String categoryRef;
  final String name;
  final String brand;
  final String model;
  final String notes;

  Map<String, dynamic> toJson() => {
        'category_ref': categoryRef,
        'name': name,
        'brand': brand,
        'model': model,
        'notes': notes,
      };
}

class ProductionAssetItemUpdateBody {
  ProductionAssetItemUpdateBody({
    this.categoryRef,
    this.name,
    this.brand,
    this.model,
    this.notes,
  });

  final String? categoryRef;
  final String? name;
  final String? brand;
  final String? model;
  final String? notes;

  Map<String, dynamic> toJson() => {
        if (categoryRef != null) 'category_ref': categoryRef,
        if (name != null) 'name': name,
        if (brand != null) 'brand': brand,
        if (model != null) 'model': model,
        if (notes != null) 'notes': notes,
      };
}
