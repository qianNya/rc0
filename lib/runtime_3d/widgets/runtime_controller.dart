import '../core/runtime_event.dart';
import '../core/runtime_session.dart';

enum RuntimeMode {
  characterPreview,
  lightingEditor,
}

/// Imperative API for wiki pages (camera reset, auto-rotate).
class RuntimeController {
  RuntimeSession? _session;

  void attachSession(RuntimeSession session) => _session = session;
  void detachSession() => _session = null;

  Future<void> resetCamera() => _session?.camera.reset() ?? Future.value();
  Future<void> setAutoRotate(bool enabled) =>
      _session?.camera.setAutoRotate(enabled) ?? Future.value();
}

LightingRuntimeEvent? parseLightingEvent(RuntimeEvent event) {
  switch (event.eventName) {
    case 'lightMoved':
      final payload = event.payload;
      return LightingLightMovedEvent(
        lightId: payload['id'] as String? ?? '',
        azimuthDeg: (payload['azimuthDeg'] as num?)?.toDouble() ?? 0,
        elevationDeg: (payload['elevationDeg'] as num?)?.toDouble() ?? 0,
      );
    case 'rigApplied':
      return const LightingRigAppliedEvent();
    default:
      return null;
  }
}
