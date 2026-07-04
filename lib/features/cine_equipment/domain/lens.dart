import 'equipment_category.dart';

/// Interchangeable lens in the equipment library.
class Lens {
  const Lens({
    required this.id,
    required this.brandId,
    required this.brand,
    required this.model,
    required this.displayName,
    required this.focalRange,
    required this.mount,
    required this.category,
    this.promptHint = '',
    this.summaryLabel = '',
    this.isBuiltIn = false,
    this.favorite = false,
  });

  final String id;
  final String brandId;
  final String brand;
  final String model;
  final String displayName;
  final String focalRange;
  final String mount;
  final EquipmentCategory category;
  final String promptHint;
  final String summaryLabel;
  final bool isBuiltIn;
  final bool favorite;

  String get displaySummary =>
      summaryLabel.isNotEmpty ? summaryLabel : displayName;

  Lens copyWith({
    String? id,
    String? brandId,
    String? brand,
    String? model,
    String? displayName,
    String? focalRange,
    String? mount,
    EquipmentCategory? category,
    String? promptHint,
    String? summaryLabel,
    bool? isBuiltIn,
    bool? favorite,
  }) {
    return Lens(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      displayName: displayName ?? this.displayName,
      focalRange: focalRange ?? this.focalRange,
      mount: mount ?? this.mount,
      category: category ?? this.category,
      promptHint: promptHint ?? this.promptHint,
      summaryLabel: summaryLabel ?? this.summaryLabel,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_id': brandId,
        'brand': brand,
        'model': model,
        'display_name': displayName,
        'focal_range': focalRange,
        'mount': mount,
        'category': category.name,
        if (promptHint.isNotEmpty) 'prompt_hint': promptHint,
        if (summaryLabel.isNotEmpty) 'summary_label': summaryLabel,
        'is_built_in': isBuiltIn,
      };

  factory Lens.fromJson(Map<String, dynamic> json) {
    return Lens(
      id: json['id'] as String? ?? json['slug'] as String? ?? '',
      brandId: json['brand_id'] as String? ?? json['brandId'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      displayName:
          json['display_name'] as String? ?? json['displayName'] as String? ?? '',
      focalRange: json['focal_range'] as String? ?? '',
      mount: json['mount'] as String? ?? '',
      category: _categoryFrom(json['category'] as String?),
      promptHint: json['prompt_hint'] as String? ?? '',
      summaryLabel: json['summary_label'] as String? ?? '',
      isBuiltIn: json['is_built_in'] == true,
    );
  }

  static EquipmentCategory _categoryFrom(String? raw) {
    return EquipmentCategory.values.firstWhere(
      (c) => c.name == raw,
      orElse: () => EquipmentCategory.cinema,
    );
  }
}
