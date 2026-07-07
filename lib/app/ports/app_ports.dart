import 'package:rc0_core/rc0_core.dart';
import 'package:rc0_feature_editor/rc0_feature_editor.dart';

import 'app_camera_binding_port.dart';
import 'app_editor_host_port.dart';
import 'app_lighting_binding_port.dart';
import 'app_picker_ports.dart';

export 'app_camera_binding_port.dart';
export 'app_editor_host_port.dart';
export 'app_lighting_binding_port.dart';
export 'app_picker_ports.dart';

/// Registers all app-layer port implementations into [registry].
void registerAppPorts(ModuleRegistry registry) {
  registry.registerPorts({
    ScenePickerPort: const AppScenePickerPort(),
    SceneBindingPort: const AppSceneBindingPort(),
    CharacterPickerPort: const AppCharacterPickerPort(),
    CharacterBindingPort: const AppCharacterBindingPort(),
    LightingBindingPort: const AppLightingBindingPort(),
    CameraBindingPort: const AppCameraBindingPort(),
    EditorHostPort: const AppEditorHostPort(),
  });
}
