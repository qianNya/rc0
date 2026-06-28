import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../screenplay/data/screenplay_draft.dart'
    show ScreenplayDraft, draftCoverDisplayPath;
import '../../../upload/presentation/widgets/editor/draft_meta_chip_row.dart';

/// Screenplay meta for the studio hub app bar — two fixed rows, no wrap.
class ScriptStudioHubInfoStrip extends StatelessWidget {
  const ScriptStudioHubInfoStrip({
    super.key,
    required this.draft,
    required this.title,
    required this.subtitle,
    this.height = ScriptStudioHubInfoStrip.stripHeight,
    this.onEditTap,
    this.scriptMenuItems,
    this.onScriptSelected,
  });

  static const stripHeight = 44.0;
  static const coverSize = 40.0;

  final ScreenplayDraft draft;
  final String title;
  final String subtitle;
  final double height;
  final VoidCallback? onEditTap;
  final List<PopupMenuEntry<String>>? scriptMenuItems;
  final ValueChanged<String>? onScriptSelected;

  @override
  Widget build(BuildContext context) {
    final coverPath = draftCoverDisplayPath(draft);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCover(coverPath),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: coverSize,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 18,
                    child: _buildTitleRow(),
                  ),
                  SizedBox(
                    height: 16,
                    child: DraftMetaChipRow(
                      draft: draft,
                      fontSize: 9,
                      layout: DraftMetaChipLayout.singleLine,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(String? coverPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: SizedBox(
        width: coverSize,
        height: coverSize,
        child: coverPath != null
            ? PoseCoverImage(
                imagePath: coverPath,
                expand: true,
                borderRadius: AppDimensions.radiusSm,
                enablePreview: false,
              )
            : const PlaceholderImage(
                aspectRatio: 1,
                borderRadius: AppDimensions.radiusSm,
                iconSize: 18,
              ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(child: _buildTitleControl()),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
          ),
        ),
        if (onEditTap != null) _buildEditButton(),
      ],
    );
  }

  Widget _buildTitleControl() {
    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );

    if (scriptMenuItems == null || scriptMenuItems!.isEmpty) {
      return Align(alignment: Alignment.centerLeft, child: titleText);
    }

    return PopupMenuButton<String>(
      tooltip: '切换剧本',
      offset: const Offset(0, 28),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: onScriptSelected,
      itemBuilder: (context) => scriptMenuItems!,
      child: Row(
        children: [
          Expanded(child: titleText),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      tooltip: '编辑项目信息',
      onPressed: onEditTap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
      iconSize: 16,
      icon: const Icon(Icons.edit_outlined),
    );
  }
}
