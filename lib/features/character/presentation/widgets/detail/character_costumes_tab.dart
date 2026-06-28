import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../domain/character_detail_data.dart';

class CharacterCostumesTab extends StatelessWidget {
  const CharacterCostumesTab({super.key, required this.costumes});

  final List<CharacterCostumeItem> costumes;

  @override
  Widget build(BuildContext context) {
    if (costumes.isEmpty) {
      return const EmptyStateView(
        icon: Icons.checkroom_outlined,
        title: '暂无服装参考',
        subtitle: '角色服装版本将在此展示',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: costumes.length,
      itemBuilder: (context, index) {
        final costume = costumes[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Material(
          color: isDark ? AppColors.characterCardDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: costume.linkedScriptId == null
                ? null
                : () => context.push(AppRoutes.script(costume.linkedScriptId!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PoseCoverImage(
                    imagePath: costume.coverPath ?? '',
                    expand: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    costume.name,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
