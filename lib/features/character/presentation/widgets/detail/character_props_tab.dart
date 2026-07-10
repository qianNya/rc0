import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../domain/character_detail_data.dart';
import '../../../../../shared/widgets/glass/glass.dart';

class CharacterPropsTab extends StatelessWidget {
  const CharacterPropsTab({
    super.key,
    required this.props,
    this.canEdit = false,
    this.onAdd,
  });

  final List<CharacterPropItem> props;
  final bool canEdit;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    if (props.isEmpty) {
      return GlassEmptyState(
        icon: Icons.inventory_2_outlined,
        title: '暂无道具',
        subtitle: '添加随身道具，分镜生成时会注入 Prompt',
        actionLabel: canEdit && onAdd != null ? '添加道具' : null,
        onAction: canEdit ? onAdd : null,
      );
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          itemCount: props.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppDimensions.spacingSm),
          itemBuilder: (context, index) {
            final prop = props[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Material(
              color: isDark ? AppColors.characterCardDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    child: prop.coverUrl.isNotEmpty
                        ? PoseCoverImage(
                            imagePath: prop.coverUrl,
                            expand: true,
                          )
                        : ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.inventory_2_outlined),
                          ),
                  ),
                ),
                title: Text(prop.name, style: AppTextStyles.label),
                subtitle: prop.description.isEmpty
                    ? null
                    : Text(
                        prop.description,
                        style: AppTextStyles.bodySecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            );
          },
        ),
        if (canEdit && onAdd != null)
          Positioned(
            right: AppDimensions.spacingMd,
            bottom: AppDimensions.spacingLg,
            child: FloatingActionButton.extended(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('添加道具'),
            ),
          ),
      ],
    );
  }
}
