import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

/// Unified coming-soon placeholder for stub features (tasks, future notifications).
class ComingSoonFeatureBody extends StatelessWidget {
  const ComingSoonFeatureBody({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.hourglass_empty_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
