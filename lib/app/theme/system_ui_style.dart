import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Unified status bar & navigation bar styling across the app.
abstract final class AppSystemUi {
  static const SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: AppColors.border,
  );

  static void apply() {
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}
