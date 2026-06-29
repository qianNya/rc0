import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Douyin-style shortcut cell: icon on top, label below.
class ProfileShortcutItem extends StatelessWidget {
  const ProfileShortcutItem({
    super.key,
    required this.label,
    required this.icon,
    this.iconColor,
    this.iconBackground,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = iconColor ?? AppColors.accent;
    final bg = iconBackground ??
        (isDark ? AppColors.accentLightDark : AppColors.accentLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: fg, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.label.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
