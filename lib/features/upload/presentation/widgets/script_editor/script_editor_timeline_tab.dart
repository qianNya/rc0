import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/cine_params_draft.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../../../shared/widgets/rc0_image.dart';
import '../../../../../shared/widgets/shell_insets.dart';
import '../../../../../core/responsive/breakpoints.dart';
import '../upload_structure_drag.dart';
import 'script_editor_actions.dart';
import 'script_editor_navigation.dart';
import 'storyboard_playback_bar.dart';

const _secPerPixel = 24.0;
const _minBlockWidth = 72.0;
const _maxBlockWidth = 180.0;
const _trackHeight = 80.0;
const _sceneCardWidth = 92.0;
const _actAccentWidth = 4.0;
const _gapInactiveWidth = 4.0;

class ScriptEditorTimelineTab extends StatefulWidget {
  const ScriptEditorTimelineTab({
    super.key,
    required this.draft,
    this.actions,
    this.filterActIndex,
    this.filterSceneIndex,
    this.embeddedInHub = false,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions? actions;
  final int? filterActIndex;
  final int? filterSceneIndex;
  final bool embeddedInHub;

  @override
  State<ScriptEditorTimelineTab> createState() =>
      _ScriptEditorTimelineTabState();
}

class _ScriptEditorTimelineTabState extends State<ScriptEditorTimelineTab> {
  int? _filterActIndex;
  int? _filterSceneIndex;

  bool get _isSceneFilter =>
      _filterActIndex != null && _filterSceneIndex != null;

  @override
  void initState() {
    super.initState();
    _filterActIndex = widget.filterActIndex;
    _filterSceneIndex = widget.filterSceneIndex;
  }

  List<DraftFrameRef> get _refs => draftAllFrameRefs(
        widget.draft,
        filterActIndex: _filterActIndex,
        filterSceneIndex: _filterSceneIndex,
      );

  List<({int actIndex, int sceneIndex, SceneDraft scene})> get _sceneRows {
    final rows = <({int actIndex, int sceneIndex, SceneDraft scene})>[];
    for (var actIndex = 0; actIndex < widget.draft.acts.length; actIndex++) {
      final act = widget.draft.acts[actIndex];
      for (var sceneIndex = 0; sceneIndex < act.scenes.length; sceneIndex++) {
        if (_isSceneFilter &&
            (actIndex != _filterActIndex || sceneIndex != _filterSceneIndex)) {
          continue;
        }
        rows.add((
          actIndex: actIndex,
          sceneIndex: sceneIndex,
          scene: act.scenes[sceneIndex],
        ));
      }
    }
    return rows;
  }

  String get _sceneLabel {
    if (_isSceneFilter) {
      final scene =
          widget.draft.acts[_filterActIndex!].scenes[_filterSceneIndex!];
      final title = scene.title.trim().isEmpty
          ? '第${_filterSceneIndex! + 1}场'
          : scene.title.trim();
      return '$title（${scene.frames.length}画）';
    }
    return '全部场次（${countDraftFrames(widget.draft)}画）';
  }

  int get _totalDurationSec {
    if (_isSceneFilter) {
      return _sceneDurationSec(
        widget.draft.acts[_filterActIndex!].scenes[_filterSceneIndex!],
      );
    }
    return draftTotalDurationSec(widget.draft);
  }

  void _handleMoveFrame(
    FrameDragData data,
    int toActIndex,
    SceneDraft toScene,
    int toInsertIndex,
  ) {
    widget.actions?.onMoveFrame(data, toActIndex, toScene, toInsertIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.draft.acts.isEmpty) {
      return const EmptyStateView(
        icon: Icons.timeline_outlined,
        title: '暂无时间线',
        subtitle: '添加幕与场次后，可在此按轨道预览顺序',
      );
    }

    final sceneRows = _sceneRows;
    if (sceneRows.isEmpty) {
      return const EmptyStateView(
        icon: Icons.timeline_outlined,
        title: '暂无时间线',
        subtitle: '添加场次后可在此编排分镜',
      );
    }

    final shellBottom =
        widget.embeddedInHub ? ShellInsets.of(context) : 0.0;

    return Column(
      children: [
        if (widget.filterActIndex == null && widget.filterSceneIndex == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                draftHierarchySummary(widget.draft),
                style: AppTextStyles.bodySecondary,
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + shellBottom),
            itemCount: sceneRows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final row = sceneRows[index];
              return _SceneTimelineRow(
                act: widget.draft.acts[row.actIndex],
                actIndex: row.actIndex,
                sceneIndex: row.sceneIndex,
                scene: row.scene,
                draggable: widget.actions != null,
                onSceneTap: widget.actions == null
                    ? null
                    : () => openSceneEditorDetail(
                          context,
                          actions: widget.actions!,
                          actIndex: row.actIndex,
                          sceneIndex: row.sceneIndex,
                        ),
                onFrameTap: widget.actions == null
                    ? null
                    : (ref) => openFrameEditorDetail(
                          context,
                          actions: widget.actions!,
                          actIndex: ref.actIndex,
                          sceneIndex: ref.sceneIndex,
                          frameIndex: ref.frameIndex,
                        ),
                onMoveFrame: widget.actions == null
                    ? null
                    : (data, insertIndex) => _handleMoveFrame(
                          data,
                          row.actIndex,
                          row.scene,
                          insertIndex,
                        ),
              );
            },
          ),
        ),
        if (!widget.embeddedInHub)
          StoryboardPlaybackBar(
            sceneLabel: _sceneLabel,
            frameCount: _refs.length,
            totalDurationSec: _totalDurationSec,
            onPlay: () => showPlaybackComingSoon(context),
          ),
      ],
    );
  }
}

int _sceneDurationSec(SceneDraft scene) {
  if (scene.frames.isEmpty) return 0;
  return scene.frames.fold<int>(
    0,
    (sum, frame) => sum + frame.cineParams.durationSec,
  );
}

double _durationWidth(int durationSec) =>
    (durationSec * _secPerPixel).clamp(_minBlockWidth, _maxBlockWidth);

double _framePlaceholderWidth(FrameDragData data) =>
    _durationWidth(data.frame.cineParams.durationSec);

bool _canAcceptFrameDrop({
  required FrameDragData data,
  required ActDraft act,
  required int actIndex,
  required SceneDraft toScene,
  required int toSceneIndex,
  required int toInsertIndex,
}) {
  if (data.fromActIndex != actIndex) return true;
  final fromSceneIndex = act.scenes.indexOf(data.fromScene);
  if (fromSceneIndex < 0) return true;
  if (fromSceneIndex != toSceneIndex) return true;
  final fromFrameIndex = toScene.frames.indexOf(data.frame);
  if (fromFrameIndex < 0) return true;
  return fromFrameIndex != toInsertIndex;
}

class _SceneTimelineRow extends StatelessWidget {
  const _SceneTimelineRow({
    required this.act,
    required this.actIndex,
    required this.sceneIndex,
    required this.scene,
    required this.draggable,
    this.onSceneTap,
    this.onFrameTap,
    this.onMoveFrame,
  });

  final ActDraft act;
  final int actIndex;
  final int sceneIndex;
  final SceneDraft scene;
  final bool draggable;
  final VoidCallback? onSceneTap;
  final void Function(DraftFrameRef ref)? onFrameTap;
  final void Function(FrameDragData data, int insertIndex)? onMoveFrame;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final compact = Breakpoints.isCompact(context);

    final sceneCard = _SceneTimelineCard(
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      scene: scene,
      onTap: onSceneTap,
      expanded: compact,
    );

    final track = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: _SceneFrameTrack(
          act: act,
          actIndex: actIndex,
          sceneIndex: sceneIndex,
          scene: scene,
          draggable: draggable,
          onFrameTap: onFrameTap,
          onMoveFrame: onMoveFrame,
        ),
      ),
    );

    final accentBar = Container(
      width: _actAccentWidth,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                accentBar,
                const SizedBox(width: 8),
                Expanded(child: sceneCard),
              ],
            ),
          ),
          const SizedBox(height: 8),
          track,
        ],
      );
    }

    return SizedBox(
      height: _trackHeight + 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          accentBar,
          const SizedBox(width: 8),
          sceneCard,
          const SizedBox(width: 10),
          Expanded(child: track),
        ],
      ),
    );
  }
}

class _SceneTimelineCard extends StatelessWidget {
  const _SceneTimelineCard({
    required this.actIndex,
    required this.sceneIndex,
    required this.scene,
    this.onTap,
    this.expanded = false,
  });

  final int actIndex;
  final int sceneIndex;
  final SceneDraft scene;
  final VoidCallback? onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final title = scene.title.trim().isEmpty
        ? '第${sceneIndex + 1}场'
        : scene.title.trim();
    final durationSec = _sceneDurationSec(scene);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: expanded ? null : _sceneCardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '第${actIndex + 1}幕',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.label.copyWith(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${scene.frames.length}画 · $durationSec秒',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneFrameTrack extends StatelessWidget {
  const _SceneFrameTrack({
    required this.act,
    required this.actIndex,
    required this.sceneIndex,
    required this.scene,
    required this.draggable,
    this.onFrameTap,
    this.onMoveFrame,
  });

  final ActDraft act;
  final int actIndex;
  final int sceneIndex;
  final SceneDraft scene;
  final bool draggable;
  final void Function(DraftFrameRef ref)? onFrameTap;
  final void Function(FrameDragData data, int insertIndex)? onMoveFrame;

  List<DraftFrameRef> get _refs {
    final refs = <DraftFrameRef>[];
    final actTitle = '第${actIndex + 1}幕';
    final sceneTitle = scene.title.trim().isEmpty
        ? '第${sceneIndex + 1}场'
        : scene.title.trim();
    for (var frameIndex = 0; frameIndex < scene.frames.length; frameIndex++) {
      final frame = scene.frames[frameIndex];
      refs.add(
        DraftFrameRef(
          actIndex: actIndex,
          sceneIndex: sceneIndex,
          frameIndex: frameIndex,
          frame: frame,
          preview: frameDraftToPreviewFrame(
            frame: frame,
            id: 'draft-$actIndex-$sceneIndex-$frameIndex',
            orderIndex: frameIndex,
          ),
          sceneTitle: sceneTitle,
          actTitle: actTitle,
        ),
      );
    }
    return refs;
  }

  @override
  Widget build(BuildContext context) {
    final refs = _refs;

    if (refs.isEmpty) {
      if (!draggable || onMoveFrame == null) {
        return SizedBox(
          height: _trackHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '暂无分镜',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
          ),
        );
      }
      return SizedBox(
        height: _trackHeight,
        child: StructureInsertDropTarget<FrameDragData>(
          axis: Axis.horizontal,
          inactiveExtent: _minBlockWidth,
          activeExtent: _minBlockWidth,
          activeExtentForData: _framePlaceholderWidth,
          crossExtent: _trackHeight,
          onAccept: (data) => onMoveFrame!(data, 0),
          canAccept: (data) => _canAcceptFrameDrop(
            data: data,
            act: act,
            actIndex: actIndex,
            toScene: scene,
            toSceneIndex: sceneIndex,
            toInsertIndex: 0,
          ),
        ),
      );
    }

    return SizedBox(
      height: _trackHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < refs.length; i++) ...[
            if (draggable && onMoveFrame != null)
              StructureInsertDropTarget<FrameDragData>(
                axis: Axis.horizontal,
                inactiveExtent: _gapInactiveWidth,
                activeExtent: _minBlockWidth,
                activeExtentForData: _framePlaceholderWidth,
                crossExtent: _trackHeight,
                onAccept: (data) => onMoveFrame!(data, refs[i].frameIndex),
                canAccept: (data) => _canAcceptFrameDrop(
                  data: data,
                  act: act,
                  actIndex: actIndex,
                  toScene: scene,
                  toSceneIndex: sceneIndex,
                  toInsertIndex: refs[i].frameIndex,
                ),
              )
            else
              const SizedBox(width: _gapInactiveWidth),
            _FrameTimelineBlock(
              ref: refs[i],
              fromScene: scene,
              draggable: draggable,
              onTap: onFrameTap == null ? null : () => onFrameTap!(refs[i]),
            ),
          ],
          if (draggable && onMoveFrame != null)
            StructureInsertDropTarget<FrameDragData>(
              axis: Axis.horizontal,
              inactiveExtent: _gapInactiveWidth,
              activeExtent: _minBlockWidth,
              activeExtentForData: _framePlaceholderWidth,
              crossExtent: _trackHeight,
              onAccept: (data) => onMoveFrame!(data, refs.length),
              canAccept: (data) => _canAcceptFrameDrop(
                data: data,
                act: act,
                actIndex: actIndex,
                toScene: scene,
                toSceneIndex: sceneIndex,
                toInsertIndex: refs.length,
              ),
            )
          else
            const SizedBox(width: _gapInactiveWidth),
        ],
      ),
    );
  }
}

class _FrameTimelineBlock extends StatelessWidget {
  const _FrameTimelineBlock({
    required this.ref,
    required this.fromScene,
    required this.draggable,
    this.onTap,
  });

  final DraftFrameRef ref;
  final SceneDraft fromScene;
  final bool draggable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final durationSec = ref.frame.cineParams.durationSec;
    final width = _durationWidth(durationSec);

    final block = _TimelineImageBlock(
      width: width,
      height: _trackHeight,
      imagePath: ref.frame.image.displayPath,
      title: ref.shotLabel,
      subtitle: '$durationSec秒',
      onTap: onTap,
    );

    if (!draggable) {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: block,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: CrossListDragHandle<FrameDragData>(
        data: FrameDragData(
          fromActIndex: ref.actIndex,
          fromScene: fromScene,
          frame: ref.frame,
        ),
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: width,
            height: _trackHeight,
            child: _TimelineImageBlock(
              width: width,
              height: _trackHeight,
              imagePath: ref.frame.image.displayPath,
              title: ref.shotLabel,
              subtitle: '$durationSec秒',
            ),
          ),
        ),
        child: block,
      ),
    );
  }
}

class _TimelineImageBlock extends StatelessWidget {
  const _TimelineImageBlock({
    required this.width,
    required this.height,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.onTap,
  });

  final double width;
  final double height;
  final String? imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imagePath != null && imagePath!.isNotEmpty)
                Rc0Image(
                  path: imagePath!,
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                  errorWidget: _placeholder(),
                )
              else
                _placeholder(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceSecondary,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
