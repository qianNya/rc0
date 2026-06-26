import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_shadows.dart';

/// 桌面卡片布局统一间距与装饰。
abstract final class DesktopChrome {
  static const double gap = AppDimensions.spacingSm;

  static BoxDecoration decoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.card,
      );
}
