import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_draft_tags.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../utils/shoot_preset_navigation.dart';
import 'collapsible_tag_picker.dart';
import 'upload_shoot_param_cards.dart';

const _coverAspectRatio = 16 / 9;

InputDecoration _settingsFieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingMd,
      vertical: AppDimensions.spacingSm,
    ),
  );
}

/// Full project settings form (cover, title, synopsis, tags, default params).
class ProjectSettingsForm extends StatelessWidget {
  const ProjectSettingsForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.synopsisController,
    required this.onShootParamsChanged,
    required this.poolTags,
    required this.onToggleScreenplayTag,
    required this.onAddScreenplayTag,
    this.tagsLoading = false,
    this.tagsError,
    this.onRetryTags,
    this.onPickCover,
    this.onResetCover,
  });

  final ScreenplayDraft draft;
  final TextEditingController titleController;
  final TextEditingController synopsisController;
  final ValueChanged<ShootParams> onShootParamsChanged;
  final List<String> poolTags;
  final ValueChanged<String> onToggleScreenplayTag;
  final Future<void> Function(String) onAddScreenplayTag;
  final bool tagsLoading;
  final String? tagsError;
  final VoidCallback? onRetryTags;
  final VoidCallback? onPickCover;
  final VoidCallback? onResetCover;

  @override
  Widget build(BuildContext context) {
    final coverPath = draftCoverDisplayPath(draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('基础设置', style: AppTextStyles.title),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: SizedBox(
                width: 120,
                child: AspectRatio(
                  aspectRatio: _coverAspectRatio,
                  child: coverPath != null
                      ? PoseCoverImage(
                          imagePath: coverPath,
                          expand: true,
                          borderRadius: AppDimensions.radiusMd,
                          enablePreview: false,
                        )
                      : const PlaceholderImage(
                          aspectRatio: _coverAspectRatio,
                          borderRadius: AppDimensions.radiusMd,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (onPickCover != null)
              OutlinedButton(
                onPressed: onPickCover,
                child: const Text('更换封面'),
              ),
            if (!draft.usesDefaultCover && onResetCover != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onResetCover,
                child: const Text('恢复默认'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: titleController,
          style: AppTextStyles.title,
          decoration: _settingsFieldDecoration('项目名称'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: synopsisController,
          style: AppTextStyles.body,
          maxLines: 4,
          decoration: _settingsFieldDecoration('项目简介'),
        ),
        const SizedBox(height: 16),
        CollapsibleTagPicker(
          title: '标签',
          poolTags: poolTags,
          selectedTags: draft.tags,
          badgeCount: poolTags.length,
          collapsedSummaryTags: draftTagPoolSorted(draft),
          onToggle: onToggleScreenplayTag,
          onAdd: onAddScreenplayTag,
          loading: tagsLoading,
          error: tagsError,
          onRetry: onRetryTags,
        ),
        const SizedBox(height: 24),
        const Text('默认参数', style: AppTextStyles.title),
        const SizedBox(height: 12),
        ShootParamPresetCards(
          params: draft.defaultParams,
          onChanged: onShootParamsChanged,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            final params = await openShootPresetPicker(
              context,
              scope: 'screenplay',
            );
            if (params != null) onShootParamsChanged(params);
          },
          child: const Text('从预设库选择'),
        ),
      ],
    );
  }
}
