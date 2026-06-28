import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import 'storyboard_shot_meta.dart';

class StoryboardShotGridCard extends StatelessWidget {
  const StoryboardShotGridCard({
    super.key,
    required this.sequenceLabel,
    required this.ref,
    required this.selected,
    this.onTap,
    this.onMore,
  });

  final String sequenceLabel;
  final DraftFrameRef ref;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? AppColors.accent
        : (isDark ? AppColors.borderDark : AppColors.border);
    final cardBg =
        isDark ? AppColors.characterCardDark : AppColors.surface;
    final caption = ref.frame.caption.trim().isEmpty
        ? '未命名画面'
        : ref.frame.caption.trim();
    final meta = storyboardShotMetaLine(ref.frame.cineParams);
    final actionNote = ref.frame.actionNote.trim();
    final duration =
        storyboardShotDurationLabel(ref.frame.cineParams.durationSec);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusMd - 1),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PoseCoverImage(
                        imagePath: ref.preview.effectiveDisplayPath,
                        expand: true,
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _Badge(label: sequenceLabel),
                      ),
                      if (onMore != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            icon: Icon(
                              Icons.more_horiz,
                              size: 18,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : Colors.white,
                            ),
                            onPressed: onMore,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            caption,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.schedule_outlined,
                          size: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          duration,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 9,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (actionNote.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceSecondaryDark
                              : AppColors.surfaceSecondary,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          actionNote,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 9,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
