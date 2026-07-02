import 'dart:async';

import 'package:rc0_unity_widget/rc0_unity_widget.dart';

import 'runtime_command.dart';
import 'runtime_event.dart';
import '../modules/animation_module_facade.dart';
import '../modules/camera_module_facade.dart';
import '../modules/character_module_facade.dart';
import '../modules/export_module_facade.dart';
import '../modules/lighting_module_facade.dart';
import '../modules/pose_module_facade.dart';

/// Owns a Unity session and module facades for one viewport.
class RuntimeSession {
  RuntimeSession({
    required this.sessionId,
    RuntimeBridge? bridge,
  }) : bridge = bridge ?? RuntimeBridge() {
    this.bridge.startListening();
    _subscription = this.bridge.events.listen(_onBridgeEvent);
  }

  final String sessionId;
  final RuntimeBridge bridge;
  final _eventController = StreamController<RuntimeEvent>.broadcast();
  StreamSubscription<RuntimeBridgeEvent>? _subscription;

  late final CharacterModuleFacade character = CharacterModuleFacade(this);
  late final LightingModuleFacade lighting = LightingModuleFacade(this);
  late final CameraModuleFacade camera = CameraModuleFacade(this);
  late final PoseModuleFacade pose = PoseModuleFacade(this);
  late final AnimationModuleFacade animation = AnimationModuleFacade(this);
  late final ExportModuleFacade export = ExportModuleFacade(this);

  Stream<RuntimeEvent> get events => _eventController.stream;

  Future<bool> get isUnityAvailable => bridge.isUnityAvailable;

  Future<void> send(RuntimeCommand command) {
    return bridge.send(
      sessionId: command.sessionId,
      module: command.module,
      action: command.action,
      payload: command.payload,
    );
  }

  Future<void> initializeScene({required String mode}) {
    return send(RuntimeCommand(
      sessionId: sessionId,
      module: 'scene',
      action: 'setMode',
      payload: {'mode': mode},
    ));
  }

  void _onBridgeEvent(RuntimeBridgeEvent event) {
    _eventController.add(RuntimeEvent.fromBridge({
      'v': 1,
      'sessionId': event.sessionId,
      'module': event.module,
      'event': event.eventName,
      'payload': event.payload,
    }));
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await bridge.dispose();
    await _eventController.close();
  }
}
