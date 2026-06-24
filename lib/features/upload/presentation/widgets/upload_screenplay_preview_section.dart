import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_draft_preview.dart';
import '../../../screenplay/data/screenplay_draft_tags.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../../../screenplay/presentation/widgets/screenplay_info_header.dart';
import '../utils/shoot_preset_navigation.dart';
import 'collapsible_tag_picker.dart';

const _coverAspectRatio = 16 / 9;
const _titleFieldHeight = 48.0;
const _fieldContentPadding = EdgeInsets.symmetric(
  vertical: AppDimensions.spacingSm,
  horizontal: 0,
);

InputDecoration _uploadFieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: InputBorder.none,
    contentPadding: _fieldContentPadding,
  );
}

class UploadScreenplayPreviewSection extends StatelessWidget {
  const UploadScreenplayPreviewSection({
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
  final ValueChanged<String> onAddScreenplayTag;
  final bool tagsLoading;
  final String? tagsError;
  final VoidCallback? onRetryTags;
  final VoidCallback? onPickCover;
  final VoidCallback? onResetCover;

  @override
  Widget build(BuildContext context) {
    final preview = previewScreenplayFromDraft(draft);
    final coverPath = draftCoverDisplayPath(draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 2,
                  child: _UploadCoverArea(
                    coverPath: coverPath,
                    usesDefaultCover: draft.usesDefaultCover,
                    hasFrames: draft.hasFrames,
                    onPickCover: onPickCover,
                    onResetCover: onResetCover,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: _titleFieldHeight,
                          child: TextField(
                            controller: titleController,
                            style: AppTextStyles.display.copyWith(fontSize: 22),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: _uploadFieldDecoration(
                              '给这部剧本起个名字…',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Expanded(
                          child: TextField(
                            controller: synopsisController,
                            style: AppTextStyles.body,
                            expands: true,
                            maxLines: null,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: _uploadFieldDecoration('剧本简介…'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: CollapsibleTagPicker(
            title: '剧本标签',
            poolTags: poolTags,
            selectedTags: draft.tags,
            badgeCount: draftTagPool(draft).length,
            collapsedSummaryTags: draftTagPoolSorted(draft),
            onToggle: onToggleScreenplayTag,
            onAdd: onAddScreenplayTag,
            loading: tagsLoading,
            error: tagsError,
            onRetry: onRetryTags,
          ),
        ),
        const SizedBox(height: 16),
        ScreenplayInfoHeader(
          screenplay: preview,
          titleStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          showTitle: false,
          shootDefaults: draft.defaultParams,
          onShootParamsTap: () async {
            final params = await openShootPresetPicker(
              context,
              scope: 'screenplay',
            );
            if (params != null) onShootParamsChanged(params);
          },
        ),
      ],
    );
  }
}

class _UploadCoverArea extends StatelessWidget {
  const _UploadCoverArea({
    required this.coverPath,
    required this.usesDefaultCover,
    required this.hasFrames,
    this.onPickCover,
    this.onResetCover,
  });

  final String? coverPath;
  final bool usesDefaultCover;
  final bool hasFrames;
  final VoidCallback? onPickCover;
  final VoidCallback? onResetCover;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(AppDimensions.radiusMd),
      ),
      child: AspectRatio(
        aspectRatio: _coverAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickCover,
                child: _buildCoverContent(),
              ),
            ),
            if (usesDefaultCover && hasFrames)
              Positioned(
                top: AppDimensions.spacingSm,
                right: AppDimensions.spacingSm,
                child: _CoverBadge(label: '默认首图'),
              )
            else if (!usesDefaultCover && onResetCover != null)
              Positioned(
                top: AppDimensions.spacingSm,
                right: AppDimensions.spacingSm,
                child: _CoverBadge(
                  label: '恢复默认',
                  onTap: onResetCover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverContent() {
    if (coverPath != null) {
      return PoseCoverImage(
        imagePath: coverPath,
        aspectRatio: _coverAspectRatio,
        borderRadius: 0,
        iconSize: 48,
        enablePreview: false,
        expand: true,
      );
    }

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        const PlaceholderImage(
          aspectRatio: _coverAspectRatio,
          borderRadius: 0,
          iconSize: 48,
        ),
        Text(
          '点击上传',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CoverBadge extends StatelessWidget {
  const _CoverBadge({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
      ),
    );

    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: child,
      ),
    );
  }
}
