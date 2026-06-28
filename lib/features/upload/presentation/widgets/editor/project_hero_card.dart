import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../../../shared/widgets/rc0_widgets.dart';
import '../../../../screenplay/data/screenplay_draft.dart'
    show ScreenplayDraft, draftCoverDisplayPath;
import 'draft_meta_chip_row.dart';

enum ProjectHeroLayout { card, summary }

class ProjectHeroCard extends StatelessWidget {
  const ProjectHeroCard({
    super.key,
    required this.draft,
    this.fallbackTitle = '新建剧本',
    this.layout = ProjectHeroLayout.card,
    this.onSettingsTap,
    this.onAddTagTap,
  });

  final ScreenplayDraft draft;
  final String fallbackTitle;
  final ProjectHeroLayout layout;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAddTagTap;

  static const _cardCoverSize = 64.0;
  static const _summaryCoverSize = 72.0;

  @override
  Widget build(BuildContext context) {
    if (layout == ProjectHeroLayout.summary) {
      return _buildSummaryLayout(context);
    }
    return _buildCardLayout(context);
  }

  Widget _buildCover(double size, double radius, double placeholderIconSize) {
    final coverPath = draftCoverDisplayPath(draft);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: coverPath != null
            ? PoseCoverImage(
                imagePath: coverPath,
                expand: true,
                borderRadius: radius,
                enablePreview: false,
              )
            : PlaceholderImage(
                aspectRatio: 1,
                borderRadius: radius,
                iconSize: placeholderIconSize,
              ),
      ),
    );
  }

  Widget _buildTagsRow() {
    return DraftMetaChipRow(
      draft: draft,
      maxTags: 6,
      fontSize: 10,
    );
  }

  Widget _buildSynopsis({required int maxLines, VoidCallback? onTap}) {
    final synopsis = draft.synopsis.trim();
    final text = synopsis.isEmpty ? '暂无简介，点击设置添加' : synopsis;
    final child = Text(
      text,
      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }

  Widget _buildSummaryLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCover(
            _summaryCoverSize,
            AppDimensions.radiusLg,
            28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSynopsis(maxLines: 3, onTap: onAddTagTap),
                const SizedBox(height: 6),
                _buildTagsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    final title = draft.title.trim();
    final displayTitle = title.isEmpty ? fallbackTitle : title;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(
              _cardCoverSize,
              AppDimensions.radiusMd,
              24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          displayTitle,
                          style: AppTextStyles.label.copyWith(fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onSettingsTap != null)
                        TextButton(
                          onPressed: onSettingsTap,
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 0,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            '设置',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 12,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildSynopsis(maxLines: 2),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTagsRow()),
                      if (onAddTagTap != null)
                        GestureDetector(
                          onTap: onAddTagTap,
                          child: Container(
                            width: 22,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSm),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 12,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
