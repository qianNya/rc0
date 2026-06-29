import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

class ProfileGridTile extends StatelessWidget {
  const ProfileGridTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.onTap,
    this.nested = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback? onTap;
  final bool nested;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final innerBorder = isDark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;
    final innerSurface = isDark
        ? AppColors.glassSurfaceDark.withValues(alpha: 0.45)
        : AppColors.glassSurfaceLight.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: nested ? innerSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: nested ? Border.all(color: innerBorder) : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm + 4,
            vertical: AppDimensions.spacingSm + 4,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppDimensions.spacingSm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
