import 'equipment_category.dart';

/// Cinema / photo camera body in the equipment library.
class CameraBody {
  const CameraBody({
    required this.id,
    required this.brandId,
    required this.brand,
    required this.model,
    required this.displayName,
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
  final String mount;
  final EquipmentCategory category;
  final String promptHint;
  final String summaryLabel;
  final bool isBuiltIn;
  final bool favorite;

  String get displaySummary =>
      summaryLabel.isNotEmpty ? summaryLabel : displayName;

  CameraBody copyWith({
    String? id,
    String? brandId,
    String? brand,
    String? model,
    String? displayName,
    String? mount,
    EquipmentCategory? category,
    String? promptHint,
    String? summaryLabel,
    bool? isBuiltIn,
    bool? favorite,
  }) {
    return CameraBody(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      displayName: displayName ?? this.displayName,
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
        'mount': mount,
        'category': category.name,
        if (promptHint.isNotEmpty) 'prompt_hint': promptHint,
        if (summaryLabel.isNotEmpty) 'summary_label': summaryLabel,
        'is_built_in': isBuiltIn,
      };

  factory CameraBody.fromJson(Map<String, dynamic> json) {
    return CameraBody(
      id: json['id'] as String? ?? json['slug'] as String? ?? '',
      brandId: json['brand_id'] as String? ?? json['brandId'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      displayName:
          json['display_name'] as String? ?? json['displayName'] as String? ?? '',
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
