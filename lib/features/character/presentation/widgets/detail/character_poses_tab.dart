import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../../../shared/widgets/rc0_image.dart';
import '../../../../../shared/widgets/rc0_widgets.dart';
import '../../../domain/character_detail_data.dart';

class CharacterPosesTab extends StatelessWidget {
  const CharacterPosesTab({super.key, required this.poses});

  final List<CharacterPoseItem> poses;

  @override
  Widget build(BuildContext context) {
    if (poses.isEmpty) {
      return const EmptyStateView(
        icon: Icons.accessibility_new_outlined,
        title: '暂无姿势参考',
        subtitle: '补充角色拍摄建议后可生成姿势库',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: poses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pose = poses[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor =
            isDark ? AppColors.characterCardDark : AppColors.surface;

        return Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 88,
                height: 104,
                child: pose.coverPath != null && pose.coverPath!.isNotEmpty
                    ? Rc0Image(path: pose.coverPath!, fit: BoxFit.cover)
                    : const PlaceholderImage(
                        aspectRatio: 3 / 4,
                        borderRadius: 0,
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pose.title,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '动作说明',
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pose.tips,
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
