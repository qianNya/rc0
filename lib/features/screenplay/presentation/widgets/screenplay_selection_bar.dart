import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import 'screenplay_selection_controller.dart';

class ScreenplaySelectionAppBarActions extends StatelessWidget {
  const ScreenplaySelectionAppBarActions({
    super.key,
    required this.controller,
    required this.localIds,
    this.onSelectionChanged,
  });

  final ScreenplaySelectionController controller;
  final List<String> localIds;
  final VoidCallback? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.selectionMode) {
          if (localIds.isEmpty) return const SizedBox.shrink();
          return TextButton(
            onPressed: () {
              controller.enterSelection();
              onSelectionChanged?.call();
            },
            child: const Text('选择'),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '已选 ${controller.selectedCount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                controller.selectAll(localIds);
                onSelectionChanged?.call();
              },
              child: const Text('全选'),
            ),
            TextButton(
              onPressed: () {
                controller.exitSelection();
                onSelectionChanged?.call();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
}

class ScreenplaySelectionBottomBar extends StatelessWidget {
  const ScreenplaySelectionBottomBar({
    super.key,
    required this.controller,
    required this.onDelete,
  });

  final ScreenplaySelectionController controller;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.selectionMode) return const SizedBox.shrink();

        return Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      controller.selectedCount > 0 ? onDelete : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('删除 (${controller.selectedCount})'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
