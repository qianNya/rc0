import 'package:flutter/material.dart';

import '../../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../../core/responsive/breakpoints.dart';
import '../../../../screenplay/data/cine_params_draft.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../shared/widgets/shell_insets.dart';
import '../editor/editor_compact_dropdown.dart';
import '../editor/scene_frame_list_view.dart';
import 'script_editor_actions.dart';
import 'script_editor_batch_edit_sheet.dart';
import 'script_editor_navigation.dart';
import 'storyboard_playback_bar.dart';

class ScriptEditorStoryboardTab extends StatefulWidget {
  const ScriptEditorStoryboardTab({
    super.key,
    required this.draft,
    required this.actions,
    this.embeddedInHub = false,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final bool embeddedInHub;

  @override
  State<ScriptEditorStoryboardTab> createState() =>
      _ScriptEditorStoryboardTabState();
}

class _ScriptEditorStoryboardTabState extends State<ScriptEditorStoryboardTab> {
  int? _filterActIndex;
  int? _filterSceneIndex;

  List<({int actIndex, int sceneIndex, String title})> get _sceneOptions {
    final options = <({int actIndex, int sceneIndex, String title})>[];
    for (var actIndex = 0; actIndex < widget.draft.acts.length; actIndex++) {
      final act = widget.draft.acts[actIndex];
      for (var sceneIndex = 0; sceneIndex < act.scenes.length; sceneIndex++) {
        final scene = act.scenes[sceneIndex];
        if (scene.frames.isEmpty) continue;
        final title = scene.title.trim().isEmpty
            ? '第${sceneIndex + 1}场'
            : scene.title.trim();
        options.add((actIndex: actIndex, sceneIndex: sceneIndex, title: title));
      }
    }
    return options;
  }

  String get _playbackLabel {
    final filter = _effectiveFilter;
    if (filter.actIndex != null && filter.sceneIndex != null) {
      final opt = _sceneOptions.firstWhere(
        (o) =>
            o.actIndex == filter.actIndex &&
            o.sceneIndex == filter.sceneIndex,
        orElse: () => (actIndex: 0, sceneIndex: 0, title: '场次'),
      );
      return '${opt.title}（${_refs.length}画）';
    }
    return '全部场次（${_refs.length}画）';
  }

  List<DraftFrameRef> get _refs {
    final filter = _effectiveFilter;
    return draftAllFrameRefs(
      widget.draft,
      filterActIndex: filter.actIndex,
      filterSceneIndex: filter.sceneIndex,
    );
  }

  void _openBatchEdit() {
    ScriptEditorBatchEditSheet.show(
      context,
      draft: widget.draft,
      scope: BatchEditScope.entireScript,
      onApply: widget.actions.onChanged,
    );
  }

  void _addFrame() {
    final target = _resolveAddTarget();
    if (target != null) {
      widget.actions.onPickFrames(target);
    }
  }

  FramePickTarget? _resolveAddTarget() {
    final filter = _effectiveFilter;
    if (filter.actIndex != null && filter.sceneIndex != null) {
      return FramePickTarget(
        actIndex: filter.actIndex!,
        sceneIndex: filter.sceneIndex!,
      );
    }
    for (var actIndex = 0; actIndex < widget.draft.acts.length; actIndex++) {
      if (widget.draft.acts[actIndex].scenes.isNotEmpty) {
        return FramePickTarget(actIndex: actIndex, sceneIndex: 0);
      }
    }
    return null;
  }

  ({int? actIndex, int? sceneIndex}) get _effectiveFilter {
    if (_filterActIndex == null || _filterSceneIndex == null) {
      return (actIndex: null, sceneIndex: null);
    }
    final valid = _sceneOptions.any(
      (o) =>
          o.actIndex == _filterActIndex && o.sceneIndex == _filterSceneIndex,
    );
    if (!valid) return (actIndex: null, sceneIndex: null);
    return (actIndex: _filterActIndex, sceneIndex: _filterSceneIndex);
  }

  String _filterDropdownValue(
    List<({int actIndex, int sceneIndex, String title})> sceneOptions,
  ) {
    final filter = _effectiveFilter;
    if (filter.actIndex == null || filter.sceneIndex == null) {
      return 'all';
    }
    return '${filter.actIndex}-${filter.sceneIndex}';
  }

  @override
  Widget build(BuildContext context) {
    final sceneOptions = _sceneOptions;
    final filter = _effectiveFilter;
    final refs = draftAllFrameRefs(
      widget.draft,
      filterActIndex: filter.actIndex,
      filterSceneIndex: filter.sceneIndex,
    );
    final frames = refs.map((r) => r.preview).toList();
    final paths = frames.map((f) => f.effectiveDisplayPath).toList();
    final captions = frames.map((f) => f.caption).toList();
    final shotLabels = refs.map((r) => r.shotLabel).toList();
    final totalSec = draftTotalDurationSec(
      widget.draft,
      filterActIndex: filter.actIndex,
      filterSceneIndex: filter.sceneIndex,
    );
    final isMobile = Breakpoints.isMobile(context);
    final showPanelActions = widget.embeddedInHub || isMobile;
    final filterTitle = filter.actIndex == null
        ? '全部场次'
        : sceneOptions
            .where(
              (o) =>
                  o.actIndex == filter.actIndex &&
                  o.sceneIndex == filter.sceneIndex,
            )
            .map((o) => o.title)
            .firstOrNull ?? '场次';
    final dropdownValue = _filterDropdownValue(sceneOptions);

    return Column(
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
              const filterLabelStyle = TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
              final dropdown = EditorCompactDropdown<String>(
                key: ValueKey(dropdownValue),
                value: dropdownValue,
                items: [
                  const DropdownMenuEntry(
                    value: 'all',
                    label: '全部场次',
                  ),
                  for (final opt in sceneOptions)
                    DropdownMenuEntry(
                      value: '${opt.actIndex}-${opt.sceneIndex}',
                      label: opt.title,
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    if (value == null || value == 'all') {
                      _filterActIndex = null;
                      _filterSceneIndex = null;
                    } else {
                      final parts = value.split('-');
                      _filterActIndex = int.parse(parts[0]);
                      _filterSceneIndex = int.parse(parts[1]);
                    }
                  });
                },
              );

              if (constraints.maxWidth < 480 ||
                  Breakpoints.isCompact(context)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('场次筛选', style: filterLabelStyle),
                    const SizedBox(height: 6),
                    dropdown,
                  ],
                );
              }

              return Row(
                children: [
                  const Text('场次筛选', style: filterLabelStyle),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(child: dropdown),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: EditorStoryboardPanel(
            title: '$filterTitle（${refs.length}画）',
            frames: frames,
            galleryPaths: paths,
            galleryCaptions: captions,
            shotLabels: shotLabels,
            frameSources: refs.map((r) => r.frame).toList(),
            onFrameTap: (index) {
              final ref = refs[index];
              openFrameEditorDetail(
                context,
                actions: widget.actions,
                actIndex: ref.actIndex,
                sceneIndex: ref.sceneIndex,
                frameIndex: ref.frameIndex,
              );
            },
            onBatchEdit: showPanelActions ? _openBatchEdit : null,
            onAddFrame: showPanelActions ? _addFrame : null,
            showBottomBar: showPanelActions && !widget.embeddedInHub,
            shellBottomPadding:
                widget.embeddedInHub ? ShellInsets.of(context) : 0,
          ),
        ),
        if (!widget.embeddedInHub)
          StoryboardPlaybackBar(
            sceneLabel: _playbackLabel,
            frameCount: refs.length,
            totalDurationSec: totalSec,
            onPlay: () => showPlaybackComingSoon(context),
          ),
      ],
    );
  }
}
