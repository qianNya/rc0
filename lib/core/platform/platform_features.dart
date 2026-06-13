import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

bool get isDesktopOperatingSystem {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

/// 桌面无边框窗口与自定义顶栏（测试环境除外）。
bool get shouldUseDesktopWindowChrome {
  if (!isDesktopOperatingSystem) return false;
  return !Platform.environment.containsKey('FLUTTER_TEST');
}
