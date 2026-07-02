import 'dart:async';
import 'dart:convert';

import '../rc0_unity_platform.dart';

/// JSON command/event bridge between Flutter runtime_3d and Unity.
class RuntimeBridge {
  RuntimeBridge({Rc0UnityPlatform? platform})
      : _platform = platform ?? Rc0UnityPlatform.instance;

  final Rc0UnityPlatform _platform;
  final _eventController = StreamController<RuntimeBridgeEvent>.broadcast();
  StreamSubscription<String>? _subscription;

  Stream<RuntimeBridgeEvent> get events => _eventController.stream;

  Future<bool> get isUnityAvailable => _platform.isUnityAvailable();

  void startListening() {
    _subscription ??= _platform.events.listen(_onRawEvent);
  }

  Future<void> send({
    required String sessionId,
    required String module,
    required String action,
    Map<String, dynamic>? payload,
  }) async {
    final json = jsonEncode({
      'v': 1,
      'sessionId': sessionId,
      'module': module,
      'action': action,
      'payload': payload ?? <String, dynamic>{},
    });
    await _platform.sendCommand(json);
  }

  void _onRawEvent(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _eventController.add(RuntimeBridgeEvent.fromJson(map));
    } on Object catch (error) {
      _eventController.addError(error);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _eventController.close();
  }
}

class RuntimeBridgeEvent {
  const RuntimeBridgeEvent({
    required this.sessionId,
    required this.module,
    required this.eventName,
    this.payload = const {},
  });

  final String sessionId;
  final String module;
  final String eventName;
  final Map<String, dynamic> payload;

  factory RuntimeBridgeEvent.fromJson(Map<String, dynamic> json) {
    return RuntimeBridgeEvent(
      sessionId: json['sessionId'] as String? ?? '',
      module: json['module'] as String? ?? '',
      eventName: json['event'] as String? ?? json['eventName'] as String? ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : const {},
    );
  }
}
