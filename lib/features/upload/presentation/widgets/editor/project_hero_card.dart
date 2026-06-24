import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../../../shared/widgets/rc0_widgets.dart';
import '../../../../screenplay/data/screenplay_draft.dart'
    show ScreenplayDraft, draftCoverDisplayPath;
import '../../../../screenplay/data/screenplay_draft_tags.dart';

class ProjectHeroCard extends StatelessWidget {
  const ProjectHeroCard({
    super.key,
    required this.draft,
    this.onSettingsTap,
    this.onAddTagTap,
  });

  final ScreenplayDraft draft;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAddTagTap;

  @override
  Widget build(BuildContext context) {
    final coverPath = draftCoverDisplayPath(draft);
    final synopsis = draft.synopsis.trim();
    final tags = draftTagPoolSorted(draft).take(6).toList();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                const Spacer(),
                if (onSettingsTap != null)
                  TextButton(
                    onPressed: onSettingsTap,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('设置'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: coverPath != null
                        ? PoseCoverImage(
                            imagePath: coverPath,
                            expand: true,
                            borderRadius: AppDimensions.radiusMd,
                            enablePreview: false,
                          )
                        : const PlaceholderImage(
                            aspectRatio: 1,
                            borderRadius: AppDimensions.radiusMd,
                            iconSize: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        synopsis.isEmpty ? '暂无简介，点击设置添加' : synopsis,
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final tag in tags)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    fontSize: 11,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            if (onAddTagTap != null)
                              GestureDetector(
                                onTap: onAddTagTap,
                                child: Container(
                                  width: 28,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSm,
                                    ),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ] else if (onAddTagTap != null) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onAddTagTap,
                          child: Container(
                            width: 28,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm,
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
