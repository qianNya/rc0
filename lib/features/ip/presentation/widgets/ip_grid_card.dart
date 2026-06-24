import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../domain/ip_entry.dart';

class IpGridCard extends StatelessWidget {
  const IpGridCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final IpEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ColoredBox(
                color: AppColors.placeholderDark,
                child: Center(
                  child: Icon(
                    Icons.auto_stories_outlined,
                    color: AppColors.textTertiaryDark,
                    size: 28,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title.isNotEmpty ? entry.title : '未命名 IP',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppCatalog.ipWorkTypeLabel(entry.workType),
                    style: TextStyle(fontSize: 11, color: secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
