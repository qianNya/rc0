import 'package:rc0_core/rc0_core.dart';

import '../module_registry.dart';

/// Collects shell navigation entries from registered [FeatureModule]s.
List<NavEntry> collectShellNavEntries() {
  return AppModuleRegistry.instance.modules
      .expand((module) => module.navEntries)
      .toList(growable: false);
}
