import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/system_ui_style.dart';

/// Wiki hub: forced light theme with white page canvas; child chrome stays transparent.
class WikiHubTheme extends StatelessWidget {
  const WikiHubTheme({super.key, required this.child});

  final Widget child;

  static ThemeData themeOf(BuildContext context) {
    return AppTheme.light.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightStyle,
      child: ColoredBox(
        color: AppColors.surface,
        child: Theme(
          data: themeOf(context),
          child: child,
        ),
      ),
    );
  }
}
