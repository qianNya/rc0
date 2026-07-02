/// JSON event envelope (Unity → Flutter, v1).
class RuntimeEvent {
  const RuntimeEvent({
    required this.sessionId,
    required this.module,
    required this.eventName,
    this.payload = const {},
    this.version = 1,
  });

  final int version;
  final String sessionId;
  final String module;
  final String eventName;
  final Map<String, dynamic> payload;

  factory RuntimeEvent.fromBridge(Map<String, dynamic> json) {
    return RuntimeEvent(
      version: json['v'] as int? ?? 1,
      sessionId: json['sessionId'] as String? ?? '',
      module: json['module'] as String? ?? '',
      eventName: json['event'] as String? ?? json['eventName'] as String? ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : const {},
    );
  }
}

/// Lighting-specific events from Unity LightingModule.
sealed class LightingRuntimeEvent {
  const LightingRuntimeEvent();
}

class LightingLightMovedEvent extends LightingRuntimeEvent {
  const LightingLightMovedEvent({
    required this.lightId,
    required this.azimuthDeg,
    required this.elevationDeg,
  });

  final String lightId;
  final double azimuthDeg;
  final double elevationDeg;
}

class LightingRigAppliedEvent extends LightingRuntimeEvent {
  const LightingRigAppliedEvent();
}
