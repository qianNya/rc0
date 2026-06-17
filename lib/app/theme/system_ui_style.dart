import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Unified status bar & navigation bar styling across the app.
abstract final class AppSystemUi {
  static const SystemUiOverlayStyle lightStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: AppColors.border,
  );

  static const SystemUiOverlayStyle darkStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.backgroundDark,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  @Deprecated('Use lightStyle or styleFor')
  static const SystemUiOverlayStyle style = lightStyle;

  static SystemUiOverlayStyle styleFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkStyle : lightStyle;
  }

  static void applyFor(Brightness brightness) {
    SystemChrome.setSystemUIOverlayStyle(styleFor(brightness));
  }

  static void apply() {
    applyFor(Brightness.light);
  }
}
