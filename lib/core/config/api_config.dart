import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  /// Desktop/mobile can use LAN IP; Web must use same-machine localhost
  /// (and the backend must allow CORS for the Flutter web origin).
  static String get serverHost {
    if (kIsWeb) return 'http://127.0.0.1:8080';
    return 'http://192.168.110.167:8080';
  }
}
