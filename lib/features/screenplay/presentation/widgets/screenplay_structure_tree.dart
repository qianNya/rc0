import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_act.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import '../../../../shared/widgets/image_preview.dart';
import 'frame_thumbnail_grid.dart';
import 'frame_thumbnail_strip.dart';

class ScreenplayStructureTree extends StatefulWidget {
  const ScreenplayStructureTree({
    super.key,
    required this.screenplay,
    required this.galleryPaths,
    required this.galleryCaptions,
    this.previewOptions,
    this.onDeleteAct,
    this.onDeleteScene,
    this.onDeleteFrame,
    this.onUploadFrame,
  });

  final Screenplay screenplay;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final ImagePreviewOptions? previewOptions;
  final Future<void> Function(int actIndex)? onDeleteAct;
  final Future<void> Function(int actIndex, int sceneIndex)? onDeleteScene;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onDeleteFrame;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onUploadFrame;

  @override
  State<ScreenplayStructureTree> createState() =>
      _ScreenplayStructureTreeState();
}

class _ScreenplayStructureTreeState extends State<ScreenplayStructureTree> {
  late Map<int, bool> _expandedActs;

  @override
  void initState() {
    super.initState();
    _expandedActs = {
      for (var i = 0; i < widget.screenplay.acts.length; i++) i: true,
    };
  }

  @override
  void didUpdateWidget(covariant ScreenplayStructureTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenplay.acts.length != widget.screenplay.acts.length) {
      _expandedActs = {
        for (var i = 0; i < widget.screenplay.acts.length; i++)
          i: _expandedActs[i] ?? true,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final acts = widget.screenplay.acts;
    if (acts.isEmpty) {
      return Text(
        '暂无结构',
        style: AppTextStyles.bodySecondary,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var actIndex = 0; actIndex < acts.length; actIndex++)
          _ActTreeSection(
            act: acts[actIndex],
            actIndex: actIndex,
            actCount: acts.length,
            expanded: _expandedActs[actIndex] ?? true,
            galleryPaths: widget.galleryPaths,
            galleryCaptions: widget.galleryCaptions,
            previewOptions: widget.previewOptions,
            onToggle: () => setState(() {
              _expandedActs[actIndex] = !(_expandedActs[actIndex] ?? true);
            }),
            onDeleteAct: widget.onDeleteAct,
            onDeleteScene: widget.onDeleteScene,
            onDeleteFrame: widget.onDeleteFrame,
            onUploadFrame: widget.onUploadFrame,
          ),
      ],
    );
  }
}

class _ActTreeSection extends StatelessWidget {
  const _ActTreeSection({
    required this.act,
    required this.actIndex,
    required this.actCount,
    required this.expanded,
    required this.galleryPaths,
    required this.galleryCaptions,
    required this.onToggle,
    this.previewOptions,
    this.onDeleteAct,
    this.onDeleteScene,
    this.onDeleteFrame,
    this.onUploadFrame,
  });

  final ScriptAct act;
  final int actIndex;
  final int actCount;
  final bool expanded;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final VoidCallback onToggle;
  final ImagePreviewOptions? previewOptions;
  final Future<void> Function(int actIndex)? onDeleteAct;
  final Future<void> Function(int actIndex, int sceneIndex)? onDeleteScene;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onDeleteFrame;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onUploadFrame;

  @override
  Widget build(BuildContext context) {
    final canDeleteAct = onDeleteAct != null && actCount > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            onLongPress: canDeleteAct ? () => onDeleteAct!(actIndex) : null,
            child: Row(
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Act ${actIndex + 1} ${act.title}',
                    style: AppTextStyles.label,
                  ),
                ),
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 2,
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    color: AppColors.border,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        for (var sceneIndex = 0;
                            sceneIndex < act.scenes.length;
                            sceneIndex++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _SceneTreeRow(
                              scene: act.scenes[sceneIndex],
                              sceneIndex: sceneIndex,
                              actIndex: actIndex,
                              sceneCount: act.scenes.length,
                              galleryPaths: galleryPaths,
                              galleryCaptions: galleryCaptions,
                              previewOptions: previewOptions,
                              onDeleteScene: onDeleteScene,
                              onDeleteFrame: onDeleteFrame,
                              onUploadFrame: onUploadFrame,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SceneTreeRow extends StatefulWidget {
  const _SceneTreeRow({
    required this.scene,
    required this.sceneIndex,
    required this.actIndex,
    required this.sceneCount,
    required this.galleryPaths,
    required this.galleryCaptions,
    this.previewOptions,
    this.onDeleteScene,
    this.onDeleteFrame,
    this.onUploadFrame,
  });

  final ScriptScene scene;
  final int sceneIndex;
  final int actIndex;
  final int sceneCount;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final ImagePreviewOptions? previewOptions;
  final Future<void> Function(int actIndex, int sceneIndex)? onDeleteScene;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onDeleteFrame;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onUploadFrame;

  @override
  State<_SceneTreeRow> createState() => _SceneTreeRowState();
}

class _SceneTreeRowState extends State<_SceneTreeRow> {
  bool _expanded = false;

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final canDeleteScene =
        widget.onDeleteScene != null && widget.sceneCount > 1;
    final canDeleteFrame =
        widget.onDeleteFrame != null && scene.frames.length > 1;
    final canUploadFrame = widget.onUploadFrame != null;
    final canFrameLongPress = canDeleteFrame || canUploadFrame;

    Future<void> onFrameLongPress(int frameIndex, _) async {
      if (!canFrameLongPress) return;

      if (canUploadFrame && !canDeleteFrame) {
        await widget.onUploadFrame!(
          widget.actIndex,
          widget.sceneIndex,
          frameIndex,
        );
        return;
      }

      if (!canUploadFrame && canDeleteFrame) {
        await widget.onDeleteFrame!(
          widget.actIndex,
          widget.sceneIndex,
          frameIndex,
        );
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('上传此图'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onUploadFrame!(
                    widget.actIndex,
                    widget.sceneIndex,
                    frameIndex,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除画格'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onDeleteFrame!(
                    widget.actIndex,
                    widget.sceneIndex,
                    frameIndex,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: _toggleExpanded,
                      onLongPress: canDeleteScene
                          ? () => widget.onDeleteScene!(
                                widget.actIndex,
                                widget.sceneIndex,
                              )
                          : null,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Text(
                            'Scene ${widget.sceneIndex + 1}',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scene.title,
                              style: AppTextStyles.label.copyWith(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: FrameThumbnailStrip(
                      frames: scene.frames,
                      galleryPaths: widget.galleryPaths,
                      galleryCaptions: widget.galleryCaptions,
                      previewOptions: widget.previewOptions,
                      itemSize: 40,
                      maxVisible: 3,
                      onExpandTap: _toggleExpanded,
                      onFrameLongPress:
                          canFrameLongPress ? onFrameLongPress : null,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: _toggleExpanded,
                    icon: Icon(
                      _expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (scene.location.isNotEmpty ||
                            scene.timeOfDay.isNotEmpty)
                          Text(
                            [scene.location, scene.timeOfDay]
                                .where((e) => e.isNotEmpty)
                                .join(' · '),
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        if (scene.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            scene.description,
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                        if (scene.location.isNotEmpty ||
                            scene.timeOfDay.isNotEmpty ||
                            scene.description.isNotEmpty)
                          const SizedBox(height: 8),
                        FrameThumbnailGrid(
                          frames: scene.frames,
                          galleryPaths: widget.galleryPaths,
                          galleryCaptions: widget.galleryCaptions,
                          previewOptions: widget.previewOptions,
                          onFrameLongPress:
                              canFrameLongPress ? onFrameLongPress : null,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
