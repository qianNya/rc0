import 'package:flutter/material.dart';

import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/domain/screenplay/script_frame.dart';
import '../../../../../shared/widgets/glass/glass_sheet.dart';
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
  showGlassSheet<void>(
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spacingSm),
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
  );
}

void showSceneFrameSortSheet(
  BuildContext context, {
  required SceneFrameSort current,
  required ValueChanged<SceneFrameSort> onSelected,
}) {
  showGlassSheet<void>(
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spacingSm),
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
    required this.sceneIndex,
    required this.onFrameTap,
    this.onBatchEdit,
    this.emptySubtitle = '点击右下角添加画面',
    this.bottomPadding = 0,
  });

  final List<FrameDraft> frames;
  final int actIndex;
  final int sceneIndex;
  final ValueChanged<int> onFrameTap;
  final VoidCallback? onBatchEdit;
  final String emptySubtitle;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return _SceneFrameListBody(
      frames: frames,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      onFrameTap: onFrameTap,
      onBatchEdit: onBatchEdit,
      emptySubtitle: emptySubtitle,
      bottomPadding: bottomPadding,
    );
  }
}

class _SceneFrameListBody extends StatefulWidget {
  const _SceneFrameListBody({
    required this.frames,
    required this.actIndex,
    required this.sceneIndex,
    required this.onFrameTap,
    this.onBatchEdit,
    required this.emptySubtitle,
    required this.bottomPadding,
  });

  final List<FrameDraft> frames;
  final int actIndex;
  final int sceneIndex;
  final ValueChanged<int> onFrameTap;
  final VoidCallback? onBatchEdit;
  final String emptySubtitle;
  final double bottomPadding;

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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + widget.bottomPadding,
                  ),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = sorted[index];
                    final frameIndex = item.originalIndex;
                    final shotLabel =
                        '${widget.actIndex + 1}-${widget.sceneIndex + 1}-${frameIndex + 1}';
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
    this.frameSources,
    this.onFrameTap,
    this.onBatchEdit,
    this.onAddFrame,
    this.showBottomBar = true,
    this.listBottomPadding = 8,
    this.shellBottomPadding = 0,
  });

  final String title;
  final List<ScriptFrame> frames;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final List<String> shotLabels;
  final List<FrameDraft>? frameSources;
  final void Function(int index)? onFrameTap;
  final VoidCallback? onBatchEdit;
  final VoidCallback? onAddFrame;
  final bool showBottomBar;
  final double listBottomPadding;
  final double shellBottomPadding;

  @override
  State<EditorStoryboardPanel> createState() => _EditorStoryboardPanelState();
}

class _EditorStoryboardPanelState extends State<EditorStoryboardPanel> {
  bool _landscape = false;

  Widget _buildFrameFooter(BuildContext context, int index, ScriptFrame frame) {
    final label = index < widget.shotLabels.length
        ? widget.shotLabels[index]
        : '${index + 1}';
    final caption =
        frame.caption.trim().isEmpty ? '未命名画面' : frame.caption.trim();
    final source = widget.frameSources != null &&
            index < widget.frameSources!.length
        ? widget.frameSources![index]
        : null;
    final durationSec = source?.cineParams.durationSec ?? 0;
    final actionNote = frame.actionNote.trim();

    final metaParts = <String>[];
    if (durationSec > 0) metaParts.add('$durationSec秒');
    if (actionNote.isNotEmpty) metaParts.add(actionNote);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$label $caption',
            style: AppTextStyles.label.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (metaParts.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              metaParts.join(' · '),
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            6,
            AppDimensions.spacingMd,
            0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactHeader =
                  constraints.maxWidth < 480 || Breakpoints.isCompact(context);
              const segmentLabelStyle = TextStyle(fontSize: 12);
              final orientationControl = SegmentedButton<bool>(
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: segmentLabelStyle,
                ),
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('竖屏', style: segmentLabelStyle),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('横屏', style: segmentLabelStyle),
                  ),
                ],
                selected: {_landscape},
                onSelectionChanged: (s) =>
                    setState(() => _landscape = s.first),
              );
              if (compactHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.label.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    orientationControl,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.label.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: orientationControl),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: widget.frames.isEmpty
              ? const Center(child: Text('暂无画面可展示'))
              : FrameThumbnailGrid(
                  frames: widget.frames,
                  galleryPaths: widget.galleryPaths,
                  galleryCaptions: widget.galleryCaptions,
                  crossAxisCount: _landscape ? 1 : 2,
                  showCaptions: false,
                  shrinkWrap: false,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.spacingMd,
                    AppDimensions.spacingSm,
                    AppDimensions.spacingMd,
                    6 +
                        widget.listBottomPadding +
                        widget.shellBottomPadding,
                  ),
                  frameFooterBuilder: _buildFrameFooter,
                  onFrameTap: widget.onFrameTap == null
                      ? null
                      : (index, _) => widget.onFrameTap!(index),
                ),
        ),
        if (widget.showBottomBar &&
            (widget.onBatchEdit != null || widget.onAddFrame != null))
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactActions = constraints.maxWidth < 360;
                final batchButton = widget.onBatchEdit == null
                    ? null
                    : OutlinedButton(
                        onPressed: widget.onBatchEdit,
                        child: const Text('批量操作'),
                      );
                final addButton = widget.onAddFrame == null
                    ? null
                    : FilledButton(
                        onPressed: widget.onAddFrame,
                        child: const Text('添加画面'),
                      );

                if (compactActions) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ?batchButton,
                      if (batchButton != null && addButton != null)
                        const SizedBox(height: 8),
                      ?addButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    if (batchButton != null) Expanded(child: batchButton),
                    if (batchButton != null && addButton != null)
                      const SizedBox(width: 12),
                    if (addButton != null) Expanded(child: addButton),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
