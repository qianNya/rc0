import '../../screenplay/domain/shoot_params.dart';
import '../domain/light_source.dart';
import '../domain/lighting_scheme.dart';

/// Maps lighting schemes to screenplay tree JSON and ShootParams.
abstract final class LightingSchemeMapper {
  static Map<String, dynamic> rigToJson(LightingScheme scheme) => {
        'scheme_id': scheme.id,
        'title': scheme.title,
        'summary_label': scheme.displaySummary,
        'lights': scheme.lights.map((l) => l.toJson()).toList(),
      };

  static LightingScheme? rigFromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    final lightsRaw = json['lights'];
    if (lightsRaw is! List || lightsRaw.isEmpty) return null;
    return LightingScheme(
      id: json['scheme_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summaryLabel: json['summary_label'] as String? ?? '',
      category: LightingPresetCategory.recommended,
      lights: [
        for (final item in lightsRaw)
          if (item is Map<String, dynamic>) LightSource.fromJson(item),
      ],
      isBuiltIn: false,
    );
  }

  static ShootParams shootParamsFromScheme(LightingScheme scheme) {
    return ShootParams(lighting: scheme.displaySummary);
  }

  static String promptDescription(LightingScheme scheme) {
    final parts = <String>[scheme.displaySummary];
    for (final light in scheme.lights.where((l) => l.enabled)) {
      parts.add(
        '${light.role.label} ${light.type.label} '
        '${light.intensity}% ${light.colorTempK}K',
      );
    }
    return parts.join(', ');
  }
}
