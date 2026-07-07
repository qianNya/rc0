import 'package:rc0_core/rc0_core.dart';
import 'package:rc0_feature_editor/rc0_feature_editor.dart';

import 'features/explore_feature_module.dart';
import 'features/library_feature_module.dart';
import 'features/profile_feature_module.dart';
import 'ports/app_ports.dart';

/// Global module registry for the app shell (TECHNICAL_DESIGN §3.5).
final class AppModuleRegistry {
  AppModuleRegistry._();

  static late final ModuleRegistry instance;

  static void initialize({List<FeatureModule> modules = const []}) {
    instance = ModuleRegistry(
      modules: [
        const EditorFeatureModule(),
        const ExploreFeatureModule(),
        const LibraryFeatureModule(),
        const ProfileFeatureModule(),
        ...modules,
      ],
    );
    registerAppPorts(instance);
    instance.bootstrapFromModules();
  }
}
