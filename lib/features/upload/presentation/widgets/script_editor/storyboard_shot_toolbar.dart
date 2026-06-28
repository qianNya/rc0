import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';

class StoryboardShotToolbar extends StatelessWidget {
  const StoryboardShotToolbar({
    super.key,
    required this.shotCount,
    required this.tags,
    required this.selectedTags,
    required this.groupByScene,
    required this.onTagToggle,
    required this.onClearTags,
    required this.onGroupToggled,
  });

  final int shotCount;
  final List<String> tags;
  final Set<String> selectedTags;
  final bool groupByScene;
  final ValueChanged<String> onTagToggle;
  final VoidCallback onClearTags;
  final VoidCallback onGroupToggled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countStyle = AppTextStyles.label.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        8,
        AppDimensions.spacingMd,
        4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('镜头：$shotCount', style: countStyle),
              const Spacer(),
              _ToolbarChipButton(
                label: '分组',
                selected: groupByScene,
                onTap: onGroupToggled,
              ),
              const SizedBox(width: 4),
              const _GridViewToggle(active: true),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _TagFilterChip(
                    label: '全部',
                    selected: selectedTags.isEmpty,
                    onTap: onClearTags,
                  ),
                  for (final tag in tags) ...[
                    const SizedBox(width: 6),
                    _TagFilterChip(
                      label: tag,
                      selected: selectedTags.contains(tag),
                      onTap: () => onTagToggle(tag),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TagFilterChip extends StatelessWidget {
  const _TagFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.accent.withValues(alpha: 0.18)
        : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary);
    final border = selected
        ? AppColors.accent
        : (isDark ? AppColors.borderDark : AppColors.border);
    final textColor = selected
        ? AppColors.accent
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarChipButton extends StatelessWidget {
  const _ToolbarChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.accent.withValues(alpha: 0.18)
        : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary);
    final border = selected
        ? AppColors.accent
        : (isDark ? AppColors.borderDark : AppColors.border);
    final textColor = selected
        ? AppColors.accent
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridViewToggle extends StatelessWidget {
  const _GridViewToggle({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: active
            ? AppColors.accent.withValues(alpha: 0.18)
            : (isDark
                ? AppColors.surfaceSecondaryDark
                : AppColors.surfaceSecondary),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: active
              ? AppColors.accent
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: Icon(
        Icons.grid_view_rounded,
        size: 18,
        color: active
            ? AppColors.accent
            : (isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary),
      ),
    );
  }
}
