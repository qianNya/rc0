import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/domain/cine_params.dart';
import '../../../upload/presentation/widgets/frame_editor/cine_params_chips.dart';

enum StudioShotCardAction { delete, duplicateParams, openDetail }

class StudioShotCard extends StatelessWidget {
  const StudioShotCard({
    super.key,
    required this.shotLabel,
    required this.frame,
    required this.cineParams,
    required this.selected,
    required this.checked,
    required this.onTap,
    required this.onCheckedChanged,
    required this.onCaptionChanged,
    required this.onActionNoteChanged,
    this.onMenuAction,
    this.subtitle,
  });

  final String shotLabel;
  final FrameDraft frame;
  final CineParams cineParams;
  final bool selected;
  final bool checked;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheckedChanged;
  final ValueChanged<String> onCaptionChanged;
  final ValueChanged<String> onActionNoteChanged;
  final ValueChanged<StudioShotCardAction>? onMenuAction;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
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
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: checked,
                onChanged: (v) => onCheckedChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                    child: SizedBox(
                      width: 160,
                      height: 90,
                      child: PoseCoverImage(
                        imagePath: frame.image.displayPath,
                        expand: true,
                        borderRadius: AppDimensions.radiusSm,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                      child: Text(
                        shotLabel,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('caption-$shotLabel-${frame.caption}'),
                            initialValue: frame.caption,
                            style: AppTextStyles.label.copyWith(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: '分镜标题',
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: onCaptionChanged,
                            onTap: onTap,
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
                        if (onMenuAction != null)
                          PopupMenuButton<StudioShotCardAction>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: onMenuAction,
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: StudioShotCardAction.openDetail,
                                child: Text('全屏编辑'),
                              ),
                              PopupMenuItem(
                                value: StudioShotCardAction.duplicateParams,
                                child: Text('复制参数到下一镜'),
                              ),
                              PopupMenuItem(
                                value: StudioShotCardAction.delete,
                                child: Text(
                                  '删除分镜',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    TextFormField(
                      key: ValueKey(
                        'action-$shotLabel-${frame.actionNote.hashCode}',
                      ),
                      initialValue: frame.actionNote,
                      maxLines: 2,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: '画面描述…',
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: onActionNoteChanged,
                      onTap: onTap,
                    ),
                    if (frame.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final tag in frame.tags.take(5))
                            TagChip(label: tag, selected: true),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    CineParamsChips(params: cineParams),
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
