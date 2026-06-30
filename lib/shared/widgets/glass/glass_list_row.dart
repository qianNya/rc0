import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';

/// Glass-styled list row for settings, messages, and action menus.
class GlassListRow extends StatelessWidget {
  const GlassListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackground,
    this.dense = false,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackground;
  final bool dense;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleStyle = AppTextStyles.label.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );
    final subtitleStyle = AppTextStyles.caption.copyWith(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );

    Widget? leadingWidget = leading;
    if (leadingWidget is Icon && iconColor != null) {
      leadingWidget = Icon(leadingWidget.icon, color: iconColor, size: 22);
    }

    final row = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: dense ? AppDimensions.spacingSm : AppDimensions.spacingMd,
          ),
          child: Row(
            children: [
              if (leadingWidget != null) ...[
                if (iconBackground != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingSm),
                      child: leadingWidget,
                    ),
                  )
                else
                  leadingWidget,
                const SizedBox(width: AppDimensions.spacingMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: subtitleStyle),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );

    if (!showDivider) return row;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        Divider(
          height: 1,
          indent: AppDimensions.spacingMd,
          endIndent: AppDimensions.spacingMd,
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ],
    );
  }
}
