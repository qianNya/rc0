import 'package:flutter/foundation.dart';

import 'platform_features_stub.dart'
    if (dart.library.io) 'platform_features_io.dart' as impl;

bool get isDesktopOperatingSystem {
  if (kIsWeb) return false;
  return impl.isDesktopOperatingSystemImpl;
}

/// 桌面无边框窗口与自定义顶栏（测试环境除外）。
bool get shouldUseDesktopWindowChrome {
  if (!isDesktopOperatingSystem) return false;
  return !impl.isFlutterTestEnvironmentImpl;
}
