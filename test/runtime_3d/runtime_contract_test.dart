import 'package:flutter_test/flutter_test.dart';

import 'package:rc0/runtime_3d/core/runtime_command.dart';
import 'package:rc0/runtime_3d/core/runtime_event.dart';
import 'package:rc0/runtime_3d/widgets/runtime_controller.dart';

void main() {
  test('RuntimeCommand serializes v1 envelope', () {
    const command = RuntimeCommand(
      sessionId: 'test-session',
      module: 'lighting',
      action: 'applyRig',
      payload: {'lights': <dynamic>[]},
    );
    final json = command.toJson();
    expect(json['v'], 1);
    expect(json['sessionId'], 'test-session');
    expect(json['module'], 'lighting');
    expect(json['action'], 'applyRig');
  });

  test('parseLightingEvent maps lightMoved', () {
    final event = parseLightingEvent(
      const RuntimeEvent(
        sessionId: 's',
        module: 'lighting',
        eventName: 'lightMoved',
        payload: {
          'id': 'key',
          'azimuthDeg': 45.0,
          'elevationDeg': 30.0,
        },
      ),
    );
    expect(event, isA<LightingLightMovedEvent>());
    final moved = event! as LightingLightMovedEvent;
    expect(moved.lightId, 'key');
    expect(moved.azimuthDeg, 45);
    expect(moved.elevationDeg, 30);
  });
}
