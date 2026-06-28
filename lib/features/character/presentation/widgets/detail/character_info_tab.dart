import 'package:flutter/material.dart';

import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../domain/character_detail_data.dart';
import '../../../domain/character_entry.dart';

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
        entry.personality.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        if (snapshot.coverPath.isNotEmpty) ...[
          Text('官方立绘', style: AppTextStyles.label),
          const SizedBox(height: 8),
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
          const SizedBox(height: 20),
        ],
        if (entry.summary.isNotEmpty) ...[
          Text('角色背景', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(entry.summary, style: AppTextStyles.body),
          const SizedBox(height: 20),
        ],
        if (entry.appearance.isNotEmpty) ...[
          Text('剧情介绍', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(entry.appearance, style: AppTextStyles.body),
          const SizedBox(height: 20),
        ],
        if (snapshot.tags.isNotEmpty) ...[
          Text('关键词', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in snapshot.tags)
                Chip(
                  label: Text(tag.name),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Text('摄影建议', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Text(
          entry.personality.isNotEmpty
              ? entry.personality
              : '柔和侧光可突出角色轮廓；海边场景建议利用自然反光与浅景深。',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 20),
        Text('镜头建议', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Text(
          '85mm 人像镜头适合特写；全景可使用 35mm 保留环境氛围。',
          style: AppTextStyles.bodySecondary,
        ),
        if (!hasContent)
          const EmptyStateView(
            icon: Icons.info_outline,
            title: '暂无资料',
            subtitle: '编辑角色后可补充介绍与设定',
          ),
      ],
    );
  }
}
