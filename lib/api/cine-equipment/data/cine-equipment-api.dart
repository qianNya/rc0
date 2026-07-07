class CineEquipmentBrandItem {
  CineEquipmentBrandItem({
    required this.slug,
    required this.name,
    required this.category,
    required this.itemKind,
    this.sort = 0,
  });

  final String slug;
  final String name;
  final String category;
  final String itemKind;
  final int sort;

  factory CineEquipmentBrandItem.fromJson(Map<String, dynamic> m) {
    return CineEquipmentBrandItem(
      slug: m['slug'] as String? ?? '',
      name: m['name'] as String? ?? '',
      category: m['category'] as String? ?? '',
      itemKind: m['item_kind'] as String? ?? '',
      sort: (m['sort'] as num?)?.toInt() ?? 0,
    );
  }
}

class CineCameraBodyItem {
  CineCameraBodyItem({
    required this.slug,
    required this.brandId,
    required this.brand,
    required this.model,
    required this.displayName,
    required this.mount,
    required this.category,
    this.promptHint = '',
    this.summaryLabel = '',
    this.isBuiltIn = true,
  });

  final String slug;
  final String brandId;
  final String brand;
  final String model;
  final String displayName;
  final String mount;
  final String category;
  final String promptHint;
  final String summaryLabel;
  final bool isBuiltIn;

  factory CineCameraBodyItem.fromJson(Map<String, dynamic> m) {
    return CineCameraBodyItem(
      slug: m['slug'] as String? ?? '',
      brandId: m['brand_id'] as String? ?? '',
      brand: m['brand'] as String? ?? '',
      model: m['model'] as String? ?? '',
      displayName: m['display_name'] as String? ?? '',
      mount: m['mount'] as String? ?? '',
      category: m['category'] as String? ?? '',
      promptHint: m['prompt_hint'] as String? ?? '',
      summaryLabel: m['summary_label'] as String? ?? '',
      isBuiltIn: m['is_built_in'] != false,
    );
  }
}

class CineLensItem {
  CineLensItem({
    required this.slug,
    required this.brandId,
    required this.brand,
    required this.model,
    required this.displayName,
    required this.focalRange,
    required this.mount,
    required this.category,
    this.promptHint = '',
    this.summaryLabel = '',
    this.isBuiltIn = true,
  });

  final String slug;
  final String brandId;
  final String brand;
  final String model;
  final String displayName;
  final String focalRange;
  final String mount;
  final String category;
  final String promptHint;
  final String summaryLabel;
  final bool isBuiltIn;

  factory CineLensItem.fromJson(Map<String, dynamic> m) {
    return CineLensItem(
      slug: m['slug'] as String? ?? '',
      brandId: m['brand_id'] as String? ?? '',
      brand: m['brand'] as String? ?? '',
      model: m['model'] as String? ?? '',
      displayName: m['display_name'] as String? ?? '',
      focalRange: m['focal_range'] as String? ?? '',
      mount: m['mount'] as String? ?? '',
      category: m['category'] as String? ?? '',
      promptHint: m['prompt_hint'] as String? ?? '',
      summaryLabel: m['summary_label'] as String? ?? '',
      isBuiltIn: m['is_built_in'] != false,
    );
  }
}

class CineCameraSetupItem {
  CineCameraSetupItem({
    required this.id,
    required this.slug,
    required this.title,
    required this.bodySlug,
    required this.lensSlug,
    required this.focalLengthMm,
    required this.apertureF,
    required this.scope,
  });

  final num id;
  final String slug;
  final String title;
  final String bodySlug;
  final String lensSlug;
  final double focalLengthMm;
  final double apertureF;
  final int scope;

  bool get isBuiltIn => scope == 0;

  factory CineCameraSetupItem.fromJson(Map<String, dynamic> m) {
    return CineCameraSetupItem(
      id: m['id'] ?? 0,
      slug: m['slug'] as String? ?? '',
      title: m['title'] as String? ?? '',
      bodySlug: m['body_slug'] as String? ?? '',
      lensSlug: m['lens_slug'] as String? ?? '',
      focalLengthMm: _toDouble(m['focal_length_mm']),
      apertureF: _toDouble(m['aperture_f']),
      scope: (m['scope'] as num?)?.toInt() ?? 0,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class CineCameraSetupWriteBody {
  const CineCameraSetupWriteBody({
    required this.title,
    required this.bodySlug,
    required this.lensSlug,
    required this.focalLengthMm,
    required this.apertureF,
  });

  final String title;
  final String bodySlug;
  final String lensSlug;
  final double focalLengthMm;
  final double apertureF;

  Map<String, dynamic> toJson() => {
        'title': title,
        'body_slug': bodySlug,
        'lens_slug': lensSlug,
        'focal_length_mm': focalLengthMm,
        'aperture_f': apertureF,
      };
}

class CineCameraSetupUpdateBody {
  const CineCameraSetupUpdateBody({
    this.title,
    this.bodySlug,
    this.lensSlug,
    this.focalLengthMm,
    this.apertureF,
  });

  final String? title;
  final String? bodySlug;
  final String? lensSlug;
  final double? focalLengthMm;
  final double? apertureF;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (bodySlug != null) json['body_slug'] = bodySlug;
    if (lensSlug != null) json['lens_slug'] = lensSlug;
    if (focalLengthMm != null) json['focal_length_mm'] = focalLengthMm;
    if (apertureF != null) json['aperture_f'] = apertureF;
    return json;
  }
}

class CineEquipmentFavoriteToggleBody {
  const CineEquipmentFavoriteToggleBody({
    required this.itemKind,
    required this.itemRef,
  });

  final String itemKind;
  final String itemRef;

  Map<String, dynamic> toJson() => {
        'item_kind': itemKind,
        'item_ref': itemRef,
      };
}

class CineEquipmentFavoriteItem {
  CineEquipmentFavoriteItem({
    required this.itemKind,
    required this.itemRef,
  });

  final String itemKind;
  final String itemRef;

  factory CineEquipmentFavoriteItem.fromJson(Map<String, dynamic> m) {
    return CineEquipmentFavoriteItem(
      itemKind: m['item_kind'] as String? ?? '',
      itemRef: m['item_ref'] as String? ?? '',
    );
  }
}

class GearCabinetLayoutItem {
  GearCabinetLayoutItem({
    required this.version,
    required this.rooms,
  });

  final int version;
  final Map<String, dynamic> rooms;

  factory GearCabinetLayoutItem.fromJson(Map<String, dynamic> m) {
    final roomsRaw = m['rooms'];
    return GearCabinetLayoutItem(
      version: (m['version'] as num?)?.toInt() ?? 1,
      rooms: roomsRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(roomsRaw)
          : const {},
    );
  }
}

class GearCabinetLayoutSaveBody {
  const GearCabinetLayoutSaveBody({
    required this.version,
    required this.rooms,
  });

  final int version;
  final Map<String, dynamic> rooms;

  Map<String, dynamic> toJson() => {
        'version': version,
        'rooms': rooms,
      };
}
