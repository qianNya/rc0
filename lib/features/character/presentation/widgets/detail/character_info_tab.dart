import 'package:flutter/material.dart';

import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../domain/character_detail_data.dart';
import '../../../domain/character_entry.dart';
import '../../../../../shared/widgets/glass/glass.dart';

class CharacterInfoTab extends StatelessWidget {
  const CharacterInfoTab({
    super.key,
    required this.entry,
    required this.snapshot,
  });

  final CharacterEntry entry;
  final CharacterDetailSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final hasContent = entry.summary.isNotEmpty ||
        entry.appearance.isNotEmpty ||
        entry.personality.isNotEmpty ||
        entry.styleLabel.isNotEmpty ||
        snapshot.tags.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        if (snapshot.coverPath.isNotEmpty) ...[
          Text('官方立绘', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: PoseCoverImage(
                imagePath: snapshot.coverPath,
                expand: true,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        if (entry.styleLabel.isNotEmpty) ...[
          Text('视觉风格', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(entry.styleLabel, style: AppTextStyles.body),
          if (entry.style.promptFragment.isNotEmpty &&
              entry.style.promptFragment != entry.styleLabel) ...[
            const SizedBox(height: 4),
            Text(
              entry.style.promptFragment,
              style: AppTextStyles.bodySecondary,
            ),
          ],
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        if (entry.summary.isNotEmpty) ...[
          Text('角色背景', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(entry.summary, style: AppTextStyles.body),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        if (entry.appearance.isNotEmpty) ...[
          Text('外观设定', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(entry.appearance, style: AppTextStyles.body),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        if (entry.personality.isNotEmpty) ...[
          Text('性格', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(entry.personality, style: AppTextStyles.body),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        if (entry.aliases.isNotEmpty) ...[
          Text('别名', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              for (final alias in entry.aliases) Chip(label: Text(alias)),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        if (snapshot.tags.isNotEmpty) ...[
          Text('标签', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              for (final tag in snapshot.tags)
                Chip(
                  label: Text(tag.name),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        if (!hasContent)
          const GlassEmptyState(
            icon: Icons.info_outline,
            title: '暂无资料',
            subtitle: '编辑角色后可补充介绍与设定',
          ),
      ],
    );
  }
}
