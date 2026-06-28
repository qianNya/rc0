import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/shell_insets.dart';

/// Related wiki domains linked from the Wiki hub.
class WikiRelatedTab extends StatelessWidget {
  const WikiRelatedTab({super.key});

  void _open(BuildContext context, WikiRelatedLinkItem item) {
    if (item.usePush) {
      context.push(item.route);
      return;
    }
    context.go(item.route);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final links = AppCatalog.wikiRelatedLinks;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        ShellInsets.scrollBottom(context, extra: AppDimensions.spacingMd),
      ),
      children: [
        Text(
          '相关 Wiki',
          style: AppTextStyles.title.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          '剧本、场景、动作与素材等关联知识库',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        for (final item in links)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
            child: Material(
              color: isDark
                  ? AppColors.surfaceSecondaryDark
                  : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: InkWell(
                onTap: () => _open(context, item),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? item.iconColor.withValues(alpha: 0.18)
                              : item.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 22),
                      ),
                      const SizedBox(width: AppDimensions.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: AppTextStyles.label.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
