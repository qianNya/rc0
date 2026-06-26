import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_shadows.dart';

/// 探索页桌面三栏卡片外壳与统一装饰。
abstract final class ExploreDesktopChrome {
  static const double gap = AppDimensions.spacingSm;

  static BoxDecoration decoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.card,
      );
}

class ExploreDesktopCard extends StatelessWidget {
  const ExploreDesktopCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.clipChild = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final bool clipChild;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusLg);

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (clipChild) {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    return Container(
      width: width,
      decoration: ExploreDesktopChrome.decoration(),
      child: content,
    );
  }
}
