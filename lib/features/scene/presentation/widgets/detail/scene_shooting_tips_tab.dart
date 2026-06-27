import 'package:flutter/material.dart';

import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../domain/scene_entry.dart';

class SceneShootingTipsTab extends StatelessWidget {
  const SceneShootingTipsTab({super.key, required this.entry});

  final SceneEntry entry;

  @override
  Widget build(BuildContext context) {
    final tips = entry.shootingTips;
    if (tips.isEmpty) {
      return Center(
        child: Text('暂无拍摄建议', style: AppTextStyles.bodySecondary),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        for (final entry in tips.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(entry.value, style: AppTextStyles.body),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Text(
            '构图示意占位',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      ],
    );
  }
}
