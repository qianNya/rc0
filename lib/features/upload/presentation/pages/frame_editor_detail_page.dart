import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../studio/domain/script_editor_selection.dart';
import '../../../studio/presentation/widgets/frame_inspector_panel.dart';
import '../widgets/editor/editor_footer_actions.dart';
import '../widgets/script_editor/script_editor_actions.dart';
import '../../../../shared/widgets/rc0_app_bar.dart';

class FrameEditorDetailPage extends StatefulWidget {
  const FrameEditorDetailPage({
    super.key,
    required this.actions,
    required this.actIndex,
    required this.sceneIndex,
    required this.frameIndex,
  });

  final ScriptEditorActions actions;
  final int actIndex;
  final int sceneIndex;
  final int frameIndex;

  @override
  State<FrameEditorDetailPage> createState() => _FrameEditorDetailPageState();
}

class _FrameEditorDetailPageState extends State<FrameEditorDetailPage> {
  FrameDraft get _frame => widget.actions.draft.acts[widget.actIndex]
      .scenes[widget.sceneIndex].frames[widget.frameIndex];

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除画面'),
        content: const Text('确定要删除这个画面吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.actions.onRemoveFrame(
        widget.actIndex,
        widget.sceneIndex,
        widget.frameIndex,
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    final sceneFrames = widget.actions.draft.acts[widget.actIndex]
        .scenes[widget.sceneIndex].frames;
    final paths = sceneFrames.map((f) => f.image.displayPath).toList();
    final shotLabel =
        '${widget.actIndex + 1}-${widget.sceneIndex + 1}-${widget.frameIndex + 1}';
    final selection = ScriptEditorSelection().selectFrame(
      widget.actIndex,
      widget.sceneIndex,
      widget.frameIndex,
    );

    return DesktopStackScaffold(
      title: Text('画面 $shotLabel'),
      onBack: () => popOrGoStudio(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: () => showImagePreview(
                    context,
                    imagePaths: paths,
                    initialIndex: widget.frameIndex,
                    captions: sceneFrames.map((f) => f.caption).toList(),
                  ),
                  child: PoseCoverImage(
                    imagePath: frame.image.displayPath,
                    expand: true,
                    borderRadius: AppDimensions.radiusMd,
                    enablePreview: false,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FrameInspectorPanel(
              actions: widget.actions,
              selection: selection,
              onChanged: () => setState(() {}),
              showHeader: false,
            ),
          ),
          EditorFooterActions(
            onSave: () => Navigator.of(context).pop(),
            onDelete: _confirmDelete,
          ),
        ],
      ),
    );
  }
}
