import 'dart:io' show Platform;

bool get isDesktopOperatingSystemImpl =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

bool get isFlutterTestEnvironmentImpl =>
    Platform.environment.containsKey('FLUTTER_TEST');
