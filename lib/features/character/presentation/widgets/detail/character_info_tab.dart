import 'package:flutter/material.dart';

import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../domain/character_entry.dart';

class CharacterInfoTab extends StatelessWidget {
  const CharacterInfoTab({super.key, required this.entry});

  final CharacterEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (entry.summary.isNotEmpty) ...[
          Text('角色介绍', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(entry.summary, style: AppTextStyles.body),
          const SizedBox(height: 20),
        ],
        if (entry.appearance.isNotEmpty) ...[
          Text('背景设定', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(entry.appearance, style: AppTextStyles.body),
          const SizedBox(height: 20),
        ],
        if (entry.personality.isNotEmpty) ...[
          Text('拍摄建议', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(entry.personality, style: AppTextStyles.body),
          const SizedBox(height: 20),
        ],
        Text('灯光建议', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Text(
          entry.appearance.isNotEmpty
              ? '参考外观设定中的光影描述进行布光。'
              : '柔和侧光可突出角色轮廓，海边场景建议利用自然反光。',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 20),
        Text('镜头建议', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Text(
          '85mm 人像镜头适合特写；全景可使用 35mm 保留环境氛围。',
          style: AppTextStyles.bodySecondary,
        ),
        if (entry.summary.isEmpty &&
            entry.appearance.isEmpty &&
            entry.personality.isEmpty)
          const EmptyStateView(
            icon: Icons.info_outline,
            title: '暂无资料',
            subtitle: '编辑角色后可补充介绍与设定',
          ),
      ],
    );
  }
}

class CharacterPlaceholderTab extends StatelessWidget {
  const CharacterPlaceholderTab({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.hourglass_empty_outlined,
      title: title,
      subtitle: subtitle,
    );
  }
}
