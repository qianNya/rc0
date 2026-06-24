import 'package:flutter/material.dart';

import '../../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../../core/responsive/breakpoints.dart';
import '../../../../screenplay/data/cine_params_draft.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
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
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;

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
    if (_filterActIndex != null && _filterSceneIndex != null) {
      final opt = _sceneOptions.firstWhere(
        (o) =>
            o.actIndex == _filterActIndex && o.sceneIndex == _filterSceneIndex,
        orElse: () => (actIndex: 0, sceneIndex: 0, title: '场次'),
      );
      return '${opt.title}（${_refs.length}画）';
    }
    return '全部场次（${_refs.length}画）';
  }

  List<DraftFrameRef> get _refs => draftAllFrameRefs(
        widget.draft,
        filterActIndex: _filterActIndex,
        filterSceneIndex: _filterSceneIndex,
      );

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
    if (_filterActIndex != null && _filterSceneIndex != null) {
      return FramePickTarget(
        actIndex: _filterActIndex!,
        sceneIndex: _filterSceneIndex!,
      );
    }
    for (var actIndex = 0; actIndex < widget.draft.acts.length; actIndex++) {
      if (widget.draft.acts[actIndex].scenes.isNotEmpty) {
        return FramePickTarget(actIndex: actIndex, sceneIndex: 0);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final refs = _refs;
    final frames = refs.map((r) => r.preview).toList();
    final paths = frames.map((f) => f.effectiveDisplayPath).toList();
    final captions = frames.map((f) => f.caption).toList();
    final shotLabels = refs.map((r) => r.shotLabel).toList();
    final sceneOptions = _sceneOptions;
    final totalSec = draftTotalDurationSec(
      widget.draft,
      filterActIndex: _filterActIndex,
      filterSceneIndex: _filterSceneIndex,
    );
    final isMobile = Breakpoints.isMobile(context);
    final filterTitle = _filterActIndex == null
        ? '全部场次'
        : sceneOptions
            .where(
              (o) =>
                  o.actIndex == _filterActIndex &&
                  o.sceneIndex == _filterSceneIndex,
            )
            .map((o) => o.title)
            .firstOrNull ?? '场次';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              const Text('场次筛选', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filterActIndex == null
                      ? 'all'
                      : '$_filterActIndex-$_filterSceneIndex',
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('全部场次'),
                    ),
                    for (final opt in sceneOptions)
                      DropdownMenuItem(
                        value: '${opt.actIndex}-${opt.sceneIndex}',
                        child: Text(
                          opt.title,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: EditorStoryboardPanel(
            title: '$filterTitle（${refs.length}画）',
            frames: frames,
            galleryPaths: paths,
            galleryCaptions: captions,
            shotLabels: shotLabels,
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
            onBatchEdit: isMobile ? _openBatchEdit : null,
            onAddFrame: isMobile ? _addFrame : null,
            showBottomBar: isMobile,
          ),
        ),
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
