import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/status_bar_spacer.dart';
import '../../../screenplay/data/screenplay_draft.dart'
    show ScreenplayDraft, draftCoverDisplayPath, draftHierarchySummary;
import '../../../upload/presentation/widgets/editor/draft_meta_chip_row.dart';
import 'script_studio_glass_widgets.dart';
import 'script_studio_theme.dart';

/// Immersive screenplay meta card for the create / edit hub (replaces app-bar strip).
class ScriptStudioProjectInfoCard extends StatelessWidget {
  const ScriptStudioProjectInfoCard({
    super.key,
    required this.draft,
    required this.title,
    required this.onBack,
    this.fallbackTitle = '新建剧本',
    this.onEditTap,
    this.scriptMenuItems,
    this.onScriptSelected,
    this.statusLabel = '创作中',
  });

  final ScreenplayDraft draft;
  final String title;
  final VoidCallback onBack;
  final String fallbackTitle;
  final VoidCallback? onEditTap;
  final List<PopupMenuEntry<String>>? scriptMenuItems;
  final ValueChanged<String>? onScriptSelected;
  final String statusLabel;

  static const _coverSize = 88.0;

  String get _displayTitle {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return fallbackTitle;
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final coverPath = draftCoverDisplayPath(draft);
    final synopsis = draft.synopsis.trim();
    final hierarchy = draftHierarchySummary(draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusBarSpacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
          ),
          child: StudioGlassCard(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    StudioGlassIconButton(
                      icon: Icons.arrow_back,
                      onPressed: onBack,
                      tooltip: '返回',
                      size: 36,
                      iconSize: 20,
                    ),
                    const Spacer(),
                    if (onEditTap != null)
                      StudioGlassIconButton(
                        icon: Icons.tune_rounded,
                        onPressed: onEditTap,
                        tooltip: '编辑项目信息',
                        size: 36,
                        iconSize: 20,
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Cover(path: coverPath),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TitleRow(
                            title: _displayTitle,
                            scriptMenuItems: scriptMenuItems,
                            onScriptSelected: onScriptSelected,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _StatusPill(label: statusLabel),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  hierarchy,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ScriptStudioColors.cardSubtitle,
                                ),
                              ),
                            ],
                          ),
                          if (synopsis.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: onEditTap,
                              child: Text(
                                synopsis,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ScriptStudioColors.cardSubtitle,
                              ),
                            ),
                          ] else if (onEditTap != null) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: onEditTap,
                              child: Text(
                                '添加简介与标签…',
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 12,
                                  color: ScriptStudioColors.accentGlow,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                DraftMetaChipRow(
                  draft: draft,
                  maxTags: 5,
                  fontSize: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: SizedBox(
        width: ScriptStudioProjectInfoCard._coverSize,
        height: ScriptStudioProjectInfoCard._coverSize,
        child: path != null
            ? PoseCoverImage(
                imagePath: path!,
                expand: true,
                borderRadius: AppDimensions.radiusLg,
                enablePreview: false,
              )
            : const PlaceholderImage(
                aspectRatio: 1,
                borderRadius: AppDimensions.radiusLg,
                iconSize: 32,
              ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ScriptStudioColors.iconSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          fontSize: 10,
          color: ScriptStudioColors.iconForeground,
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.title,
    this.scriptMenuItems,
    this.onScriptSelected,
  });

  final String title;
  final List<PopupMenuEntry<String>>? scriptMenuItems;
  final ValueChanged<String>? onScriptSelected;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: ScriptStudioColors.cardTitle.copyWith(fontSize: 18),
    );

    if (scriptMenuItems == null || scriptMenuItems!.isEmpty) {
      return titleWidget;
    }

    return PopupMenuButton<String>(
      tooltip: '切换剧本',
      offset: const Offset(0, 36),
      padding: EdgeInsets.zero,
      onSelected: onScriptSelected,
      itemBuilder: (context) => scriptMenuItems!,
      child: Row(
        children: [
          Expanded(child: titleWidget),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: ScriptStudioColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
