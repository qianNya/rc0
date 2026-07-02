import 'light_source.dart';

enum LightingPresetCategory {
  recommended,
  natural,
  indoor,
  studio,
  fx,
  favorites,
}

extension LightingPresetCategoryLabel on LightingPresetCategory {
  String get label {
    switch (this) {
      case LightingPresetCategory.recommended:
        return '推荐';
      case LightingPresetCategory.natural:
        return '自然光';
      case LightingPresetCategory.indoor:
        return '室内光';
      case LightingPresetCategory.studio:
        return '影棚光';
      case LightingPresetCategory.fx:
        return '特效光';
      case LightingPresetCategory.favorites:
        return '收藏';
    }
  }
}

/// A complete lighting rig (preset or user scheme).
class LightingScheme {
  const LightingScheme({
    required this.id,
    required this.title,
    required this.category,
    required this.lights,
    this.tags = const [],
    this.summaryLabel = '',
    this.isBuiltIn = false,
    this.linkedCharacterId,
    this.linkedSceneId,
    this.favorite = false,
  });

  final String id;
  final String title;
  final LightingPresetCategory category;
  final List<LightSource> lights;
  final List<String> tags;
  final String summaryLabel;
  final bool isBuiltIn;
  final int? linkedCharacterId;
  final String? linkedSceneId;
  final bool favorite;

  String get displaySummary =>
      summaryLabel.isNotEmpty ? summaryLabel : title;

  LightingScheme copyWith({
    String? id,
    String? title,
    LightingPresetCategory? category,
    List<LightSource>? lights,
    List<String>? tags,
    String? summaryLabel,
    bool? isBuiltIn,
    int? linkedCharacterId,
    String? linkedSceneId,
    bool? favorite,
    bool clearCharacter = false,
    bool clearScene = false,
  }) {
    return LightingScheme(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      lights: lights ?? this.lights.map((l) => l.copyWith()).toList(),
      tags: tags != null ? List<String>.from(tags) : List<String>.from(this.tags),
      summaryLabel: summaryLabel ?? this.summaryLabel,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      linkedCharacterId:
          clearCharacter ? null : (linkedCharacterId ?? this.linkedCharacterId),
      linkedSceneId: clearScene ? null : (linkedSceneId ?? this.linkedSceneId),
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'lights': lights.map((l) => l.toJson()).toList(),
        'tags': tags,
        'summary_label': summaryLabel,
        'is_built_in': isBuiltIn,
        if (linkedCharacterId != null) 'linked_character_id': linkedCharacterId,
        if (linkedSceneId != null) 'linked_scene_id': linkedSceneId,
        'favorite': favorite,
      };

  factory LightingScheme.fromJson(Map<String, dynamic> json) {
    final lightsRaw = json['lights'];
    final lights = <LightSource>[];
    if (lightsRaw is List) {
      for (final item in lightsRaw) {
        if (item is Map<String, dynamic>) {
          lights.add(LightSource.fromJson(item));
        }
      }
    }
    return LightingScheme(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '未命名灯光',
      category: LightingPresetCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => LightingPresetCategory.recommended,
      ),
      lights: lights,
      tags: (json['tags'] as List?)?.map((e) => '$e').toList() ?? const [],
      summaryLabel: json['summary_label'] as String? ?? '',
      isBuiltIn: json['is_built_in'] as bool? ?? false,
      linkedCharacterId: (json['linked_character_id'] as num?)?.toInt(),
      linkedSceneId: json['linked_scene_id'] as String?,
      favorite: json['favorite'] as bool? ?? false,
    );
  }
}

String newLightingSchemeId() =>
    'lighting-${DateTime.now().millisecondsSinceEpoch}';
