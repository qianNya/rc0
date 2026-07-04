import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/system_ui_style.dart';

/// Wiki hub / shell tab pages: forced light theme with solid light canvas.
class WikiHubTheme extends StatelessWidget {
  const WikiHubTheme({super.key, required this.child});

  final Widget child;

  static ThemeData themeOf(BuildContext context) {
    return AppTheme.light.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightStyle,
      child: ColoredBox(
        color: AppColors.background,
        child: Theme(
          data: themeOf(context),
          child: child,
        ),
      ),
    );
  }
}
