import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../domain/character_detail_data.dart';
import '../../../../../shared/widgets/glass/glass.dart';

class CharacterCostumesTab extends StatelessWidget {
  const CharacterCostumesTab({
    super.key,
    required this.costumes,
    this.canEdit = false,
    this.onAdd,
    this.onSetDefault,
  });

  final List<CharacterCostumeItem> costumes;
  final bool canEdit;
  final VoidCallback? onAdd;
  final ValueChanged<CharacterCostumeItem>? onSetDefault;

  @override
  Widget build(BuildContext context) {
    if (costumes.isEmpty) {
      return GlassEmptyState(
        icon: Icons.checkroom_outlined,
        title: '暂无服装',
        subtitle: '添加常服、礼服等变体，便于分镜换装与 AI 一致性',
        actionLabel: canEdit && onAdd != null ? '添加服装' : null,
        onAction: canEdit ? onAdd : null,
      );
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppDimensions.spacingMd,
            crossAxisSpacing: AppDimensions.spacingMd,
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
                onLongPress: canEdit && onSetDefault != null && !costume.isDefault
                    ? () => onSetDefault!(costume)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PoseCoverImage(
                            imagePath: costume.coverUrl,
                            expand: true,
                          ),
                          if (costume.isDefault)
                            Positioned(
                              top: AppDimensions.spacingSm,
                              left: AppDimensions.spacingSm,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '默认',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            costume.name,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (costume.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              costume.description,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
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
              label: const Text('添加服装'),
            ),
          ),
      ],
    );
  }
}
