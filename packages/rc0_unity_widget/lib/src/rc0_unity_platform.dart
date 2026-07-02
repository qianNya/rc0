import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bridge/runtime_bridge.dart';

/// Platform abstraction for Unity embed + JSON bridge.
abstract class Rc0UnityPlatform extends PlatformInterface {
  Rc0UnityPlatform() : super(token: _token);

  static final Object _token = Object();
  static Rc0UnityPlatform _instance = _Rc0UnityMethodChannel();

  static Rc0UnityPlatform get instance => _instance;

  static set instance(Rc0UnityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Whether a Unity player library is linked for this platform build.
  Future<bool> isUnityAvailable();

  /// Creates a platform view id for embedding Unity.
  Future<int?> createView({required String sessionId});

  /// Sends a JSON command string to Unity.
  Future<void> sendCommand(String json);

  /// Stream of JSON event strings from Unity.
  Stream<String> get events;

  /// Disposes a platform view.
  Future<void> disposeView(int viewId);
}

class _Rc0UnityMethodChannel extends Rc0UnityPlatform {
  static const _channel = MethodChannel('rc0_unity_widget');
  static const _events = EventChannel('rc0_unity_widget/events');

  final _controller = StreamController<String>.broadcast();
  Stream<String>? _eventStream;
  bool _listening = false;

  @override
  Future<bool> isUnityAvailable() async {
    if (kIsWeb) return true;
    if (defaultTargetPlatform == TargetPlatform.linux) return false;
    try {
      final available = await _channel.invokeMethod<bool>('isUnityAvailable');
      return available ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<int?> createView({required String sessionId}) async {
    try {
      final id = await _channel.invokeMethod<int>('createView', {
        'sessionId': sessionId,
      });
      _ensureListening();
      return id;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> sendCommand(String json) async {
    try {
      await _channel.invokeMethod<void>('sendCommand', {'json': json});
    } on MissingPluginException {
      // Dev fallback — no-op when Unity lib not linked.
    }
  }

  @override
  Stream<String> get events {
    _ensureListening();
    return _controller.stream;
  }

  void _ensureListening() {
    if (_listening) return;
    _listening = true;
    if (kIsWeb) return;
    _eventStream ??= _events.receiveBroadcastStream().cast<String>();
    _eventStream!.listen(
      _controller.add,
      onError: _controller.addError,
    );
  }

  @override
  Future<void> disposeView(int viewId) async {
    try {
      await _channel.invokeMethod<void>('disposeView', {'viewId': viewId});
    } on MissingPluginException {
      // ignore
    }
  }
}

/// Singleton bridge used by [RuntimeBridge].
Rc0UnityPlatform get rc0UnityPlatform => Rc0UnityPlatform.instance;
