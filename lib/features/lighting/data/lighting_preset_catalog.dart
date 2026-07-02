import '../domain/light_source.dart';
import '../domain/lighting_scheme.dart';

/// Built-in lighting schemes mapped from design presets + PresetCatalog.
abstract final class LightingPresetCatalog {
  static List<LightingScheme> get all => [
        ...recommended,
        ...natural,
        ...indoor,
        ...studio,
        ...fx,
      ];

  static List<LightingScheme> forCategory(LightingPresetCategory category) {
    if (category == LightingPresetCategory.favorites) return const [];
    return all.where((s) => s.category == category).toList();
  }

  static LightingScheme? findById(String id) {
    for (final scheme in all) {
      if (scheme.id == id) return scheme;
    }
    return null;
  }

  static LightingScheme _scheme({
    required String id,
    required String title,
    required LightingPresetCategory category,
    required String summary,
    required List<LightSource> lights,
    List<String> tags = const [],
  }) {
    return LightingScheme(
      id: id,
      title: title,
      category: category,
      summaryLabel: summary,
      lights: lights,
      tags: tags,
      isBuiltIn: true,
    );
  }

  static LightSource _light({
    required String id,
    required LightRole role,
    LightType type = LightType.softbox,
    int intensity = 70,
    int colorTempK = 5500,
    double azimuth = 45,
    double elevation = 30,
    LightQuality quality = LightQuality.soft,
    int colorArgb = 0xFFFFFFFF,
  }) {
    return LightSource(
      id: id,
      role: role,
      type: type,
      intensity: intensity,
      colorTempK: colorTempK,
      azimuthDeg: azimuth,
      elevationDeg: elevation,
      quality: quality,
      colorArgb: colorArgb,
    );
  }

  static final recommended = [
    _scheme(
      id: 'builtin-rembrandt',
      title: '伦勃朗光',
      category: LightingPresetCategory.recommended,
      summary: '伦勃朗光',
      tags: const ['人像', '经典'],
      lights: [
        _light(
          id: 'rem-key',
          role: LightRole.key,
          intensity: 75,
          colorTempK: 5200,
          azimuth: 50,
          elevation: 35,
        ),
        _light(
          id: 'rem-fill',
          role: LightRole.fill,
          intensity: 35,
          colorTempK: 4800,
          azimuth: -40,
          elevation: 20,
        ),
        _light(
          id: 'rem-rim',
          role: LightRole.rim,
          type: LightType.rim,
          intensity: 55,
          colorTempK: 6000,
          azimuth: 180,
          elevation: 25,
        ),
      ],
    ),
    _scheme(
      id: 'builtin-window-soft',
      title: '窗边柔光',
      category: LightingPresetCategory.recommended,
      summary: '柔光',
      tags: const ['自然', '室内'],
      lights: [
        _light(
          id: 'win-key',
          role: LightRole.key,
          type: LightType.softbox,
          intensity: 65,
          colorTempK: 5600,
          azimuth: 80,
          elevation: 15,
          quality: LightQuality.soft,
        ),
        _light(
          id: 'win-fill',
          role: LightRole.fill,
          intensity: 30,
          colorTempK: 5000,
          azimuth: -60,
          elevation: 10,
        ),
        _light(
          id: 'win-rim',
          role: LightRole.rim,
          type: LightType.rim,
          intensity: 35,
          colorTempK: 4800,
          azimuth: 160,
          elevation: 25,
        ),
      ],
    ),
  ];

  static final natural = [
    _scheme(
      id: 'builtin-natural',
      title: '自然光',
      category: LightingPresetCategory.natural,
      summary: '自然光',
      lights: [
        _light(
          id: 'nat-key',
          role: LightRole.key,
          type: LightType.ambient,
          intensity: 60,
          colorTempK: 5800,
          azimuth: 60,
          elevation: 45,
        ),
        _light(
          id: 'nat-fill',
          role: LightRole.fill,
          intensity: 25,
          colorTempK: 6500,
          azimuth: -30,
          elevation: 20,
        ),
        _light(
          id: 'nat-bg',
          role: LightRole.background,
          type: LightType.ambient,
          intensity: 15,
          azimuth: 0,
          elevation: 70,
        ),
      ],
    ),
    _scheme(
      id: 'builtin-backlit',
      title: '轮廓逆光',
      category: LightingPresetCategory.natural,
      summary: '逆光',
      lights: [
        _light(
          id: 'back-rim',
          role: LightRole.rim,
          type: LightType.rim,
          intensity: 80,
          colorTempK: 6200,
          azimuth: 180,
          elevation: 20,
        ),
        _light(
          id: 'back-fill',
          role: LightRole.fill,
          intensity: 30,
          colorTempK: 5000,
          azimuth: 30,
          elevation: 15,
        ),
        _light(
          id: 'back-key',
          role: LightRole.key,
          intensity: 40,
          colorTempK: 5400,
          azimuth: -20,
          elevation: 25,
        ),
      ],
    ),
  ];

  static final indoor = [
    _scheme(
      id: 'builtin-side',
      title: '侧光',
      category: LightingPresetCategory.indoor,
      summary: '侧光',
      lights: [
        _light(
          id: 'side-key',
          role: LightRole.key,
          intensity: 70,
          azimuth: 90,
          elevation: 25,
          quality: LightQuality.hard,
        ),
        _light(
          id: 'side-fill',
          role: LightRole.fill,
          intensity: 25,
          azimuth: -70,
          elevation: 15,
        ),
        _light(
          id: 'side-rim',
          role: LightRole.rim,
          type: LightType.rim,
          intensity: 45,
          azimuth: 170,
          elevation: 30,
        ),
      ],
    ),
  ];

  static final studio = [
    _scheme(
      id: 'builtin-three-point',
      title: '三点布光',
      category: LightingPresetCategory.studio,
      summary: '影棚三点布光',
      lights: [
        _light(id: '3p-key', role: LightRole.key, intensity: 70),
        _light(
          id: '3p-fill',
          role: LightRole.fill,
          intensity: 40,
          azimuth: -45,
          elevation: 20,
        ),
        _light(
          id: '3p-rim',
          role: LightRole.rim,
          type: LightType.rim,
          intensity: 50,
          azimuth: 160,
          elevation: 30,
        ),
        _light(
          id: '3p-bg',
          role: LightRole.background,
          type: LightType.ambient,
          intensity: 20,
          azimuth: 0,
          elevation: 80,
        ),
      ],
    ),
  ];

  static final fx = [
    _scheme(
      id: 'builtin-neon',
      title: '霓虹光',
      category: LightingPresetCategory.fx,
      summary: '霓虹氛围',
      tags: const ['赛博', '夜景'],
      lights: [
        _light(
          id: 'neo-key',
          role: LightRole.key,
          type: LightType.neon,
          intensity: 65,
          colorTempK: 8000,
          azimuth: 45,
          elevation: 20,
          colorArgb: 0xFF9B5CFF,
        ),
        _light(
          id: 'neo-rim',
          role: LightRole.rim,
          type: LightType.neon,
          intensity: 55,
          azimuth: 200,
          elevation: 15,
          colorArgb: 0xFF00E5FF,
        ),
        _light(
          id: 'neo-fill',
          role: LightRole.fill,
          type: LightType.neon,
          intensity: 30,
          azimuth: -50,
          elevation: 10,
          colorArgb: 0xFFFF4080,
        ),
      ],
    ),
  ];
}
