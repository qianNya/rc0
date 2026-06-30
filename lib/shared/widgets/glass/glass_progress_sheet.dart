import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';

/// Opaque progress sheet for long-running tasks (not frosted glass).
Future<T?> showGlassProgressSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
  bool isDismissible = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Material(
            color: surface,
            elevation: 8,
            shadowColor: AppColors.shadowAmbient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: AppTextStyles.title),
                  const SizedBox(height: AppDimensions.spacingMd),
                  child,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
