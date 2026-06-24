import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/shoot_params_draft.dart';
import '../../../screenplay/data/cine_params_draft.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_image.dart';
import 'upload_shoot_param_cards.dart';
import 'upload_structure_drag.dart';
import 'collapsible_tag_picker.dart';
import 'frame_editor/cine_params_chips.dart';

const _collapseDuration = Duration(milliseconds: 200);
const _collapseCurve = Curves.easeOutCubic;

class EditorDragHandle extends StatelessWidget {
  const EditorDragHandle({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: const _DragHandleIcon(),
    );
  }
}

class _DragHandleIcon extends StatelessWidget {
  const _DragHandleIcon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 4),
      child: Icon(
        Icons.drag_handle,
        size: 20,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _EditorCollapseToggle extends StatelessWidget {
  const _EditorCollapseToggle({
    required this.expanded,
    required this.onPressed,
  });

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      onPressed: onPressed,
      icon: Icon(
        expanded ? Icons.expand_less : Icons.expand_more,
        size: 20,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
      ),
    );
  }
}

class _CollapsibleBody extends StatelessWidget {
  const _CollapsibleBody({required this.expanded, required this.child});

  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _collapseDuration,
      curve: _collapseCurve,
      alignment: Alignment.topCenter,
      child: Visibility(
        visible: expanded,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: false,
        child: child,
      ),
    );
  }
}

class _FrameThumbnail extends StatelessWidget {
  const _FrameThumbnail({required this.path, required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (isNetworkImagePath(path)) {
      return Rc0Image(
        path: path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder();
        },
        errorWidget: _placeholder(),
      );
    }

    return Rc0Image(
      path: path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorWidget: _placeholder(),
    );
  }

  Widget _placeholder() {
    return SizedBox(
      width: size,
      height: size,
      child: ColoredBox(
        color: AppColors.placeholder,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: size * 0.35,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class FrameListEditor extends StatelessWidget {
  const FrameListEditor({
    super.key,
    required this.frames,
    required this.draft,
    required this.actIndex,
    required this.sceneIndex,
    required this.onRemove,
    required this.onCaptionChanged,
    required this.onActionNoteChanged,
    required this.onFrameOverrideChanged,
    required this.isFrameExpanded,
    required this.onToggleFrame,
    required this.onMoveFrame,
    required this.poolTags,
    required this.onToggleFrameTag,
    this.onOpenFrameDetail,
  });

  final List<FrameDraft> frames;
  final ScreenplayDraft draft;
  final int actIndex;
  final int sceneIndex;
  final ValueChanged<int> onRemove;
  final void Function(int index, String value) onCaptionChanged;
  final void Function(int index, String value) onActionNoteChanged;
  final void Function(int index, ShootParams? override) onFrameOverrideChanged;
  final bool Function(FrameDraft frame) isFrameExpanded;
  final ValueChanged<FrameDraft> onToggleFrame;
  final void Function(FrameDragData data, int toInsertIndex) onMoveFrame;
  final List<String> poolTags;
  final void Function(int index, String tag) onToggleFrameTag;
  final ValueChanged<int>? onOpenFrameDetail;

  SceneDraft get _scene => draft.acts[actIndex].scenes[sceneIndex];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('画 · 分镜画面', style: AppTextStyles.label),
        const SizedBox(height: 8),
        if (frames.isEmpty)
          StructureInsertDropTarget<FrameDragData>(
            onAccept: (data) => onMoveFrame(data, 0),
          )
        else
          Column(
            children: [
              for (var index = 0; index < frames.length; index++) ...[
                StructureInsertDropTarget<FrameDragData>(
                  onAccept: (data) => onMoveFrame(data, index),
                  canAccept: (data) {
                    if (data.fromActIndex != actIndex ||
                        data.fromScene != _scene) {
                      return true;
                    }
                    return frames.indexOf(data.frame) != index;
                  },
                ),
                _buildFrameCard(context, index),
              ],
              StructureInsertDropTarget<FrameDragData>(
                onAccept: (data) => onMoveFrame(data, frames.length),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFrameCard(BuildContext context, int index) {
    final frame = frames[index];
    final paths = frames.map((f) => f.image.displayPath).toList();
    final expanded = isFrameExpanded(frame);
    final canPreview = isPreviewableImagePath(frame.image.displayPath);
    final captionSummary =
        frame.caption.trim().isEmpty ? '画面说明' : frame.caption.trim();

    return Container(
      key: ValueKey('frame-$actIndex-$sceneIndex-$index'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CrossListDragHandle<FrameDragData>(
                data: FrameDragData(
                  fromActIndex: actIndex,
                  fromScene: _scene,
                  frame: frame,
                ),
                feedback: frameDragFeedback(frame),
                child: const _DragHandleIcon(),
              ),
              GestureDetector(
                onTap: canPreview
                    ? () => showImagePreview(
                          context,
                          imagePaths: paths,
                          initialIndex: index,
                          captions: frames.map((f) => f.caption).toList(),
                        )
                    : null,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  child: SizedBox(
                    width: expanded ? 88 : 40,
                    height: expanded ? 88 : 40,
                    child: _FrameThumbnail(
                      path: frame.image.displayPath,
                      size: expanded ? 88 : 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (onOpenFrameDetail != null) {
                      onOpenFrameDetail!(index);
                    } else {
                      onToggleFrame(frame);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    captionSummary,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      color: frame.caption.trim().isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (onOpenFrameDetail != null)
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 18),
                  onPressed: () => onOpenFrameDetail!(index),
                  tooltip: '画面详情',
                ),
              _EditorCollapseToggle(
                expanded: expanded,
                onPressed: () => onToggleFrame(frame),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onRemove(index),
              ),
            ],
          ),
          _CollapsibleBody(
            expanded: expanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: frame.caption,
                    decoration: const InputDecoration(
                      hintText: '画面说明',
                      isDense: true,
                    ),
                    onChanged: (v) => onCaptionChanged(index, v),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: frame.actionNote,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: '画面描述',
                      isDense: true,
                      alignLabelWithHint: true,
                    ),
                    onChanged: (v) => onActionNoteChanged(index, v),
                  ),
                  const SizedBox(height: 8),
                  CineParamsChips(
                    params: effectiveCineParamsForFrame(
                      draft,
                      actIndex,
                      sceneIndex,
                      index,
                    ),
                    compact: true,
                  ),
                  const SizedBox(height: 8),
                          ShootParamOverrideSection(
                            effectiveParams: effectiveParamsForFrame(
                              draft,
                              actIndex,
                              sceneIndex,
                              index,
                            ),
                            paramOverride: frame.paramOverride,
                            inheritLabel: '沿用场设置',
                            onOverrideChanged: (value) =>
                                onFrameOverrideChanged(index, value),
                            scope: 'frame',
                            actIndex: actIndex,
                            sceneIndex: sceneIndex,
                            frameIndex: index,
                          ),
                          const SizedBox(height: 8),
                          CollapsibleTagPicker(
                            poolTags: poolTags,
                            selectedTags: frame.tags,
                            onToggle: (tag) => onToggleFrameTag(index, tag),
                            initiallyCollapsed: frames.length > 1,
                            showAddChip: false,
                          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoverEditorSection extends StatelessWidget {
  const CoverEditorSection({
    super.key,
    required this.displayPath,
    required this.usesDefault,
    required this.hasFrames,
    required this.onPickCover,
    required this.onResetDefault,
  });

  final String? displayPath;
  final bool usesDefault;
  final bool hasFrames;
  final VoidCallback onPickCover;
  final VoidCallback onResetDefault;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('封面', style: AppTextStyles.title),
            const Spacer(),
            if (usesDefault && hasFrames)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '默认首图',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          usesDefault
              ? '未单独设置时，使用第一张分镜图；视频将取第一帧。'
              : '已设置自定义封面。',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PoseCoverImage(
              imagePath: displayPath,
              aspectRatio: 16 / 9,
              borderRadius: AppDimensions.radiusMd,
              enablePreview: displayPath != null &&
                  isPreviewableImagePath(displayPath!),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onPickCover,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: const Text('更换封面'),
            ),
            if (!usesDefault) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onResetDefault,
                child: const Text('恢复默认'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class SceneEditorSection extends StatelessWidget {
  const SceneEditorSection({
    super.key,
    required this.scene,
    required this.sceneIndex,
    required this.actIndex,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
    required this.canRemove,
    required this.frames,
    required this.onPickFrames,
    required this.onRemoveFrame,
    required this.onCaptionChanged,
    required this.onActionNoteChanged,
    required this.onFrameOverrideChanged,
    required this.onSceneOverrideChanged,
    required this.expanded,
    required this.onToggleExpanded,
    required this.isFrameExpanded,
    required this.onToggleFrame,
    required this.onMoveFrame,
    required this.poolTags,
    required this.onToggleSceneTag,
    required this.onToggleFrameTag,
    this.onOpenFrameDetail,
  });

  final SceneDraft scene;
  final int sceneIndex;
  final int actIndex;
  final ScreenplayDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final bool canRemove;
  final List<FrameDraft> frames;
  final VoidCallback onPickFrames;
  final ValueChanged<int> onRemoveFrame;
  final void Function(int index, String value) onCaptionChanged;
  final void Function(int index, String value) onActionNoteChanged;
  final void Function(int index, ShootParams? override) onFrameOverrideChanged;
  final ValueChanged<ShootParams?> onSceneOverrideChanged;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final bool Function(FrameDraft frame) isFrameExpanded;
  final ValueChanged<FrameDraft> onToggleFrame;
  final void Function(FrameDragData data, int toInsertIndex) onMoveFrame;
  final List<String> poolTags;
  final ValueChanged<String> onToggleSceneTag;
  final void Function(int frameIndex, String tag) onToggleFrameTag;
  final ValueChanged<int>? onOpenFrameDetail;

  String get _titleSummary {
    final title = scene.title.trim();
    return title.isEmpty ? '场标题' : title;
  }

  @override
  Widget build(BuildContext context) {
    final frameCount = frames.length;
    final firstFramePath =
        frameCount > 0 ? frames.first.image.displayPath : null;

    return DragTarget<FrameDragData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) =>
          onMoveFrame(details.data, frames.length),
      builder: (context, candidate, rejected) {
        final accepting = candidate.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: accepting ? AppColors.accent : AppColors.border,
              width: accepting ? 1.5 : 1,
            ),
          ),
          child: _buildSceneContent(context, frameCount, firstFramePath),
        );
      },
    );
  }

  Widget _buildSceneContent(
    BuildContext context,
    int frameCount,
    String? firstFramePath,
  ) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CrossListDragHandle<SceneDragData>(
                data: SceneDragData(fromActIndex: actIndex, scene: scene),
                feedback: sceneDragFeedback(scene, sceneIndex),
                child: const _DragHandleIcon(),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onToggleExpanded,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        '第${sceneIndex + 1}场',
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _titleSummary,
                          style: AppTextStyles.label.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (frameCount > 0) ...[
                _CountBadge(label: '$frameCount画'),
                if (firstFramePath != null && !expanded) ...[
                  const SizedBox(width: 6),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSm),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: _FrameThumbnail(path: firstFramePath, size: 28),
                    ),
                  ),
                ],
              ],
              _EditorCollapseToggle(
                expanded: expanded,
                onPressed: onToggleExpanded,
              ),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onRemove,
                ),
            ],
          ),
          _CollapsibleBody(
            expanded: expanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: scene.title,
                    decoration: const InputDecoration(hintText: '场标题'),
                    onChanged: (v) {
                      scene.title = v;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  ShootParamOverrideSection(
                    effectiveParams:
                        effectiveParamsForScene(draft, actIndex, sceneIndex),
                    paramOverride: scene.paramOverride,
                    inheritLabel: '沿用剧本设置',
                    onOverrideChanged: onSceneOverrideChanged,
                    scope: 'scene',
                    actIndex: actIndex,
                    sceneIndex: sceneIndex,
                  ),
                  const SizedBox(height: 8),
                  CollapsibleTagPicker(
                    poolTags: poolTags,
                    selectedTags: scene.tags,
                    onToggle: onToggleSceneTag,
                    initiallyCollapsed: frames.length > 1,
                    showAddChip: false,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onPickFrames,
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        size: 18),
                    label: const Text('添加画面'),
                  ),
                  const SizedBox(height: 8),
                  FrameListEditor(
                    frames: frames,
                    draft: draft,
                    actIndex: actIndex,
                    sceneIndex: sceneIndex,
                    onRemove: onRemoveFrame,
                    onCaptionChanged: onCaptionChanged,
                    onActionNoteChanged: onActionNoteChanged,
                    onFrameOverrideChanged: onFrameOverrideChanged,
                    isFrameExpanded: isFrameExpanded,
                    onToggleFrame: onToggleFrame,
                    onMoveFrame: onMoveFrame,
                    poolTags: poolTags,
                    onToggleFrameTag: onToggleFrameTag,
                    onOpenFrameDetail: onOpenFrameDetail,
                  ),
                ],
              ),
            ),
          ),
        ],
    );
  }
}

class ActEditorSection extends StatelessWidget {
  const ActEditorSection({
    super.key,
    required this.act,
    required this.actIndex,
    required this.onChanged,
    required this.onRemove,
    required this.canRemove,
    required this.onAddScene,
    required this.sceneBuilder,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onMoveScene,
    required this.poolTags,
    required this.onToggleActTag,
  });

  final ActDraft act;
  final int actIndex;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final bool canRemove;
  final VoidCallback onAddScene;
  final Widget Function(int sceneIndex) sceneBuilder;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final void Function(SceneDragData data, int toInsertIndex) onMoveScene;
  final List<String> poolTags;
  final ValueChanged<String> onToggleActTag;

  String get _titleSummary {
    final title = act.title.trim();
    return title.isEmpty ? '幕标题' : title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EditorDragHandle(index: actIndex),
              Expanded(
                child: GestureDetector(
                  onTap: onToggleExpanded,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        '第${actIndex + 1}幕',
                        style: AppTextStyles.title.copyWith(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _titleSummary,
                          style: AppTextStyles.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _CountBadge(label: '${act.scenes.length}场'),
              const SizedBox(width: 6),
              _EditorCollapseToggle(
                expanded: expanded,
                onPressed: onToggleExpanded,
              ),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
            ],
          ),
          _CollapsibleBody(
            expanded: expanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: act.title,
                    decoration: const InputDecoration(hintText: '幕标题'),
                    onChanged: (v) {
                      act.title = v;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: act.synopsis,
                    decoration: const InputDecoration(hintText: '幕简介'),
                    maxLines: 2,
                    onChanged: (v) {
                      act.synopsis = v;
                      onChanged();
                    },
                  ),
                  const SizedBox(height: 8),
                  CollapsibleTagPicker(
                    poolTags: poolTags,
                    selectedTags: act.tags,
                    onToggle: onToggleActTag,
                    initiallyCollapsed: act.scenes.length > 1,
                    showAddChip: false,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      for (var sceneIndex = 0;
                          sceneIndex < act.scenes.length;
                          sceneIndex++) ...[
                        StructureInsertDropTarget<SceneDragData>(
                          onAccept: (data) => onMoveScene(data, sceneIndex),
                          canAccept: (data) {
                            if (data.fromActIndex != actIndex) return true;
                            return act.scenes.indexOf(data.scene) !=
                                sceneIndex;
                          },
                        ),
                        sceneBuilder(sceneIndex),
                      ],
                      StructureInsertDropTarget<SceneDragData>(
                        onAccept: (data) =>
                            onMoveScene(data, act.scenes.length),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: onAddScene,
                    icon: const Icon(Icons.add),
                    label: const Text('添加场'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
