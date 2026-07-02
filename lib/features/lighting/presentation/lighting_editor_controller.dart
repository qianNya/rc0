import 'package:flutter/foundation.dart';

import '../data/lighting_repository.dart';
import '../domain/light_source.dart';
import '../domain/lighting_scheme.dart';

class LightingEditorController extends ChangeNotifier {
  LightingEditorController({
    LightingScheme? initialScheme,
    this.previewCharacterId,
    this.previewSceneId,
    this.applyScope = LightingApplyScope.browse,
  }) : _scheme = initialScheme ??
            LightingPresetCatalogFallback.defaultScheme;

  final int? previewCharacterId;
  final String? previewSceneId;
  final LightingApplyScope applyScope;

  final _repo = LightingRepository.instance;
  LightingScheme _scheme;
  int _selectedLightIndex = 0;
  LightingPresetCategory _category = LightingPresetCategory.recommended;
  bool _planView = false;

  LightingScheme get scheme => _scheme;
  int get selectedLightIndex => _selectedLightIndex;
  LightingPresetCategory get category => _category;
  bool get planView => _planView;

  LightSource? get selectedLight =>
      _scheme.lights.isEmpty ? null : _scheme.lights[_selectedLightIndex];

  List<LightingScheme> get presets => _repo.schemesForCategory(_category);

  List<LightingScheme> get mySchemes => _repo.userSchemes;

  Future<void> ensureLoaded() => _repo.load();

  void setCategory(LightingPresetCategory category) {
    _category = category;
    notifyListeners();
  }

  void loadScheme(LightingScheme scheme) {
    _scheme = scheme.copyWith();
    _selectedLightIndex = 0;
    notifyListeners();
  }

  void selectLight(int index) {
    if (index < 0 || index >= _scheme.lights.length) return;
    _selectedLightIndex = index;
    notifyListeners();
  }

  void updateSelectedLight(LightSource light) {
    if (_scheme.lights.isEmpty) return;
    final lights = List<LightSource>.from(_scheme.lights);
    lights[_selectedLightIndex] = light;
    _scheme = _scheme.copyWith(lights: lights);
    notifyListeners();
  }

  void selectLightById(String id, {bool notify = true}) {
    final index = _scheme.lights.indexWhere((l) => l.id == id);
    if (index < 0) return;
    if (index == _selectedLightIndex) return;
    _selectedLightIndex = index;
    if (notify) notifyListeners();
  }

  void updateLightById(
    String id,
    LightSource light, {
    bool notify = true,
  }) {
    final index = _scheme.lights.indexWhere((l) => l.id == id);
    if (index < 0) return;
    final lights = List<LightSource>.from(_scheme.lights);
    lights[index] = light;
    _scheme = _scheme.copyWith(lights: lights);
    if (notify) notifyListeners();
  }

  void toggleLightEnabled(int index) {
    if (index < 0 || index >= _scheme.lights.length) return;
    final lights = List<LightSource>.from(_scheme.lights);
    lights[index] = lights[index].copyWith(enabled: !lights[index].enabled);
    _scheme = _scheme.copyWith(lights: lights);
    notifyListeners();
  }

  void setPlanView(bool value) {
    _planView = value;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) => _repo.toggleFavorite(id);

  Future<void> saveCurrentScheme({String? title}) async {
    final custom = _scheme.copyWith(
      id: newLightingSchemeId(),
      title: title ?? '${_scheme.title}（自定义）',
      isBuiltIn: false,
    );
    await _repo.saveUserScheme(custom);
    _scheme = custom;
    notifyListeners();
  }
}

enum LightingApplyScope { browse, apply }

/// Avoid circular import with catalog in controller file.
abstract final class LightingPresetCatalogFallback {
  static LightingScheme get defaultScheme {
    return const LightingScheme(
      id: 'builtin-three-point',
      title: '三点布光',
      category: LightingPresetCategory.studio,
      summaryLabel: '影棚三点布光',
      isBuiltIn: true,
      lights: [
        LightSource(id: 'key', role: LightRole.key, intensity: 70),
        LightSource(
          id: 'fill',
          role: LightRole.fill,
          intensity: 40,
          azimuthDeg: -45,
        ),
        LightSource(
          id: 'rim',
          role: LightRole.rim,
          type: LightType.rim,
          intensity: 50,
          azimuthDeg: 160,
        ),
      ],
    );
  }
}
