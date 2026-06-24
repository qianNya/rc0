import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';

class EditorListToolbar extends StatelessWidget {
  const EditorListToolbar({
    super.key,
    this.onBatchEdit,
    this.onFilter,
    this.onSort,
  });

  final VoidCallback? onBatchEdit;
  final VoidCallback? onFilter;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          _ToolbarButton(label: '批量操作', onTap: onBatchEdit),
          _dot(),
          _ToolbarButton(label: '筛选', onTap: onFilter),
          _dot(),
          _ToolbarButton(label: '排序', onTap: onSort),
        ],
      ),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          '·',
          style: AppTextStyles.bodySecondary.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      );
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
      ),
    );
  }
}
