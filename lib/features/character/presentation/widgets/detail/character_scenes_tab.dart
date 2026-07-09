import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../domain/character_detail_data.dart';

class CharacterScenesTab extends StatelessWidget {
  const CharacterScenesTab({super.key, required this.affinities});

  final List<CharacterSceneAffinityItem> affinities;

  @override
  Widget build(BuildContext context) {
    if (affinities.isEmpty) {
      return const EmptyStateView(
        icon: Icons.landscape_outlined,
        title: '暂无适合场景',
        subtitle: '软关联场景 Wiki，便于调度时推荐',
      );
    }

    final sorted = List<CharacterSceneAffinityItem>.from(affinities)
      ..sort((a, b) => b.weight.compareTo(a.weight));

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: sorted.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final item = sorted[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Material(
          color: isDark ? AppColors.characterCardDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: SizedBox(
              width: 56,
              height: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: item.sceneCoverUrl.isNotEmpty
                    ? PoseCoverImage(
                        imagePath: item.sceneCoverUrl,
                        expand: true,
                      )
                    : ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.landscape_outlined),
                      ),
              ),
            ),
            title: Text(item.displayTitle, style: AppTextStyles.label),
            subtitle: Text(
              [
                if (item.note.isNotEmpty) item.note,
                '权重 ${item.weight}',
              ].join(' · '),
              style: AppTextStyles.bodySecondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () =>
                context.push(AppRoutes.sceneDetailPath(item.sceneId.toString())),
          ),
        );
      },
    );
  }
}
