/// RC0 plugin-based 3D runtime — Flutter product-layer SDK.
library;

export 'contracts/lighting_contract.dart';
export 'contracts/model_contract.dart';
export 'contracts/pose_contract.dart';
export 'core/runtime_command.dart';
export 'widgets/runtime_host.dart';
export 'widgets/runtime_preview_fallback.dart';
export 'core/runtime_event.dart';
export 'core/runtime_session.dart';
export 'modules/animation_module_facade.dart';
export 'modules/camera_module_facade.dart';
export 'modules/character_module_facade.dart';
export 'modules/export_module_facade.dart';
export 'modules/lighting_module_facade.dart';
export 'modules/pose_module_facade.dart';
export 'widgets/runtime_controller.dart' show RuntimeController, RuntimeMode, parseLightingEvent;

bool get isRc0RuntimeSupported {
  // Linux has no Unity embed in V1.
  return true;
}
