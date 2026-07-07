import 'feature_module.dart';
import 'ports.dart';

/// App-level registry for feature modules and injected ports.
class ModuleRegistry {
  ModuleRegistry({List<FeatureModule> modules = const []})
      : _modules = List.unmodifiable(modules);

  final List<FeatureModule> _modules;
  final Map<Type, Object> _ports = {};

  List<FeatureModule> get modules => _modules;

  void registerPorts(Map<Type, Object> ports) {
    _ports.addAll(ports);
  }

  T port<T extends Object>() {
    final value = _ports[T];
    if (value == null) {
      throw StateError('Port $T is not registered in ModuleRegistry');
    }
    return value as T;
  }

  T? portOrNull<T extends Object>() => _ports[T] as T?;

  /// Collects ports from all registered modules (later modules override).
  void bootstrapFromModules() {
    for (final module in _modules) {
      _ports.addAll(module.ports);
    }
  }

  ScenePickerPort get scenePicker => port<ScenePickerPort>();
  CharacterPickerPort get characterPicker => port<CharacterPickerPort>();
  PresetPickerPort get presetPicker => port<PresetPickerPort>();
}
