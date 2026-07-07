import 'runtime_module_id.dart';

/// Immutable snapshot of a 3D preview session (package boundary).
class RuntimeSessionContract {
  const RuntimeSessionContract({
    required this.sessionId,
    required this.activeModules,
    this.isReady = false,
  });

  final String sessionId;
  final Set<RuntimeModuleId> activeModules;
  final bool isReady;
}

/// Port for app-layer Unity / fallback host binding.
abstract interface class RuntimeHostPort {
  Future<void> attachSession(RuntimeSessionContract session);
  Future<void> detachSession(String sessionId);
}
