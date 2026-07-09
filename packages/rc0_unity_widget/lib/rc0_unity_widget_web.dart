import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// WebGL Unity embed via iframe + postMessage bridge.
class Rc0UnityWidgetWeb {
  static void registerWith(Registrar registrar) {
    // Pass [registrar] as BinaryMessenger — required before
    // WidgetsFlutterBinding is ready during web plugin registration.
    final channel = MethodChannel(
      'rc0_unity_widget',
      const JSONMethodCodec(),
      registrar,
    );
    channel.setMethodCallHandler(_handleMethod);
  }

  static final _eventController = StreamController<String>.broadcast();

  static Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'isUnityAvailable':
        return false;
      case 'createView':
        return call.arguments is Map
            ? (call.arguments as Map)['sessionId']?.hashCode ?? 1
            : 1;
      case 'sendCommand':
        return null;
      case 'disposeView':
        return null;
      default:
        throw PlatformException(code: 'unimplemented');
    }
  }
}
