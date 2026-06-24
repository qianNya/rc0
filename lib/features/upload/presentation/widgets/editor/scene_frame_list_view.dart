import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/domain/screenplay/script_frame.dart';
import '../../../../screenplay/presentation/widgets/frame_thumbnail_grid.dart';
import '../frame_editor/shot_list_card.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import 'editor_list_toolbar.dart';

enum SceneFrameSort { indexAsc, durationDesc, durationAsc }

enum SceneFrameFilter { all, hasImage, noImage }

List<FrameDraft> applySceneFrameFilter(
  List<FrameDraft> frames,
  SceneFrameFilter filter,
) {
  switch (filter) {
    case SceneFrameFilter.all:
      return frames;
    case SceneFrameFilter.hasImage:
      return frames.where((f) => f.image.displayPath.isNotEmpty).toList();
    case SceneFrameFilter.noImage:
      return frames.where((f) => f.image.displayPath.isEmpty).toList();
  }
}

List<({FrameDraft frame, int originalIndex})> applySceneFrameSort(
  List<FrameDraft> frames,
  SceneFrameSort sort,
) {
  final indexed = [
    for (var i = 0; i < frames.length; i++) (frame: frames[i], originalIndex: i),
  ];
  switch (sort) {
    case SceneFrameSort.indexAsc:
      return indexed;
    case SceneFrameSort.durationDesc:
      indexed.sort(
        (a, b) =>
            b.frame.cineParams.durationSec.compareTo(a.frame.cineParams.durationSec),
      );
      return indexed;
    case SceneFrameSort.durationAsc:
      indexed.sort(
        (a, b) =>
            a.frame.cineParams.durationSec.compareTo(b.frame.cineParams.durationSec),
      );
      return indexed;
  }
}

void showSceneFrameFilterSheet(
  BuildContext context, {
  required SceneFrameFilter current,
  required ValueChanged<SceneFrameFilter> onSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLg),
      ),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('筛选', style: AppTextStyles.title),
          ),
          for (final option in SceneFrameFilter.values)
            ListTile(
              title: Text(_filterLabel(option)),
              trailing: current == option
                  ? const Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}

void showSceneFrameSortSheet(
  BuildContext context, {
  required SceneFrameSort current,
  required ValueChanged<SceneFrameSort> onSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLg),
      ),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('排序', style: AppTextStyles.title),
          ),
          for (final option in SceneFrameSort.values)
            ListTile(
              title: Text(_sortLabel(option)),
              trailing: current == option
                  ? const Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}

String _filterLabel(SceneFrameFilter filter) {
  return switch (filter) {
    SceneFrameFilter.all => '全部画面',
    SceneFrameFilter.hasImage => '已有图片',
    SceneFrameFilter.noImage => '暂无图片',
  };
}

String _sortLabel(SceneFrameSort sort) {
  return switch (sort) {
    SceneFrameSort.indexAsc => '按编号',
    SceneFrameSort.durationDesc => '时长从长到短',
    SceneFrameSort.durationAsc => '时长从短到长',
  };
}

class SceneFrameListView extends StatelessWidget {
  const SceneFrameListView({
    super.key,
    required this.frames,
    required this.actIndex,
    required this.onFrameTap,
    this.onBatchEdit,
    this.emptySubtitle = '点击右下角添加画面',
  });

  final List<FrameDraft> frames;
  final int actIndex;
  final ValueChanged<int> onFrameTap;
  final VoidCallback? onBatchEdit;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return _SceneFrameListBody(
      frames: frames,
      actIndex: actIndex,
      onFrameTap: onFrameTap,
      onBatchEdit: onBatchEdit,
      emptySubtitle: emptySubtitle,
    );
  }
}

class _SceneFrameListBody extends StatefulWidget {
  const _SceneFrameListBody({
    required this.frames,
    required this.actIndex,
    required this.onFrameTap,
    this.onBatchEdit,
    required this.emptySubtitle,
  });

  final List<FrameDraft> frames;
  final int actIndex;
  final ValueChanged<int> onFrameTap;
  final VoidCallback? onBatchEdit;
  final String emptySubtitle;

  @override
  State<_SceneFrameListBody> createState() => _SceneFrameListBodyState();
}

class _SceneFrameListBodyState extends State<_SceneFrameListBody> {
  SceneFrameFilter _filter = SceneFrameFilter.all;
  SceneFrameSort _sort = SceneFrameSort.indexAsc;

  @override
  Widget build(BuildContext context) {
    final filtered = applySceneFrameFilter(widget.frames, _filter);
    final sorted = applySceneFrameSort(filtered, _sort);

    return Column(
      children: [
        EditorListToolbar(
          onBatchEdit: widget.onBatchEdit,
          onFilter: () => showSceneFrameFilterSheet(
            context,
            current: _filter,
            onSelected: (v) => setState(() => _filter = v),
          ),
          onSort: () => showSceneFrameSortSheet(
            context,
            current: _sort,
            onSelected: (v) => setState(() => _sort = v),
          ),
        ),
        Expanded(
          child: sorted.isEmpty
              ? Center(
                  child: Text(
                    widget.frames.isEmpty
                        ? widget.emptySubtitle
                        : '没有符合筛选条件的画面',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = sorted[index];
                    final frameIndex = item.originalIndex;
                    final shotLabel = '${widget.actIndex + 1}-${frameIndex + 1}';
                    return ShotListCard(
                      shotLabel: shotLabel,
                      frame: item.frame,
                      cineParams: item.frame.cineParams,
                      onTap: () => widget.onFrameTap(frameIndex),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class EditorStoryboardPanel extends StatefulWidget {
  const EditorStoryboardPanel({
    super.key,
    required this.title,
    required this.frames,
    required this.galleryPaths,
    required this.galleryCaptions,
    required this.shotLabels,
    this.onFrameTap,
    this.onBatchEdit,
    this.onAddFrame,
    this.showBottomBar = true,
  });

  final String title;
  final List<ScriptFrame> frames;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final List<String> shotLabels;
  final void Function(int index)? onFrameTap;
  final VoidCallback? onBatchEdit;
  final VoidCallback? onAddFrame;
  final bool showBottomBar;

  @override
  State<EditorStoryboardPanel> createState() => _EditorStoryboardPanelState();
}

class _EditorStoryboardPanelState extends State<EditorStoryboardPanel> {
  bool _landscape = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.title, style: AppTextStyles.label),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('竖屏')),
                  ButtonSegment(value: true, label: Text('横屏')),
                ],
                selected: {_landscape},
                onSelectionChanged: (s) =>
                    setState(() => _landscape = s.first),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.frames.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text('暂无画面可展示')),
                )
              else
                FrameThumbnailGrid(
                  frames: widget.frames,
                  galleryPaths: widget.galleryPaths,
                  galleryCaptions: widget.galleryCaptions,
                  crossAxisCount: _landscape ? 1 : 2,
                  showCaptions: true,
                  frameOverlayBuilder: (context, index, frame) {
                    final label = index < widget.shotLabels.length
                        ? widget.shotLabels[index]
                        : '${index + 1}';
                    final caption = frame.caption.trim();
                    return Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                        child: Text(
                          caption.isEmpty ? label : '$label $caption',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                  onFrameLongPress: widget.onFrameTap == null
                      ? null
                      : (index, _) => widget.onFrameTap!(index),
                ),
            ],
          ),
        ),
        if (widget.showBottomBar &&
            (widget.onBatchEdit != null || widget.onAddFrame != null))
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  if (widget.onBatchEdit != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onBatchEdit,
                        child: const Text('批量操作'),
                      ),
                    ),
                  if (widget.onBatchEdit != null && widget.onAddFrame != null)
                    const SizedBox(width: 12),
                  if (widget.onAddFrame != null)
                    Expanded(
                      child: FilledButton(
                        onPressed: widget.onAddFrame,
                        child: const Text('添加画面'),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
