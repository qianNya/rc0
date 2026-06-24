import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/domain/cine_params.dart';
import 'cine_params_chips.dart';

class ShotListCard extends StatelessWidget {
  const ShotListCard({
    super.key,
    required this.shotLabel,
    required this.frame,
    required this.cineParams,
    this.subtitle,
    this.showDragHandle = false,
    this.dragHandle,
    this.onTap,
    this.trailing,
  });

  final String shotLabel;
  final FrameDraft frame;
  final CineParams cineParams;
  final String? subtitle;
  final bool showDragHandle;
  final Widget? dragHandle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final caption =
        frame.caption.trim().isEmpty ? '未命名画面' : frame.caption.trim();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDragHandle && dragHandle != null) ...[
                dragHandle!,
                const SizedBox(width: 4),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: PoseCoverImage(
                    imagePath: frame.image.displayPath,
                    expand: true,
                    borderRadius: AppDimensions.radiusSm,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$shotLabel $caption',
                            style: AppTextStyles.label.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                          ),
                          child: Text(
                            '${cineParams.durationSec}秒',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 11,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (frame.actionNote.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        frame.actionNote.trim(),
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (frame.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final tag in frame.tags)
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
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    CineParamsChips(
                      params: cineParams,
                      compact: true,
                      showDuration: false,
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
