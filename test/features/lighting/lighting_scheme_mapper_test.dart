import 'package:flutter_test/flutter_test.dart';

import 'package:rc0/features/lighting/data/lighting_preset_catalog.dart';
import 'package:rc0/features/lighting/data/lighting_scheme_mapper.dart';
import 'package:rc0/features/lighting/domain/light_source.dart';
import 'package:rc0/features/lighting/domain/lighting_scheme.dart';

void main() {
  group('LightingSchemeMapper', () {
    test('rig round-trip preserves lights', () {
      final scheme = LightingPresetCatalog.findById('builtin-rembrandt')!;
      final json = LightingSchemeMapper.rigToJson(scheme);
      final restored = LightingSchemeMapper.rigFromJson(json);

      expect(restored, isNotNull);
      expect(restored!.lights.length, scheme.lights.length);
      expect(restored.lights.first.role, LightRole.key);
    });

    test('shootParamsFromScheme uses display summary', () {
      const scheme = LightingScheme(
        id: 'test',
        title: '测试',
        category: LightingPresetCategory.studio,
        summaryLabel: '伦勃朗光',
        lights: [LightSource(id: 'key', role: LightRole.key)],
      );
      final params = LightingSchemeMapper.shootParamsFromScheme(scheme);
      expect(params.lighting, '伦勃朗光');
    });

    test('promptDescription includes enabled lights', () {
      const scheme = LightingScheme(
        id: 'test',
        title: '三点布光',
        category: LightingPresetCategory.studio,
        summaryLabel: '影棚三点布光',
        lights: [
          LightSource(id: 'key', role: LightRole.key, intensity: 80),
          LightSource(
            id: 'fill',
            role: LightRole.fill,
            intensity: 40,
            enabled: false,
          ),
        ],
      );
      final text = LightingSchemeMapper.promptDescription(scheme);
      expect(text, contains('影棚三点布光'));
      expect(text, contains('主光'));
      expect(text, isNot(contains('辅光')));
    });

    test('built-in presets have at least three lights', () {
      for (final scheme in LightingPresetCatalog.all) {
        expect(
          scheme.lights.length,
          greaterThanOrEqualTo(3),
          reason: scheme.id,
        );
      }
    });
  });
}
