import 'package:flutter/material.dart';

import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/shell_insets.dart';
import '../../../../screenplay/data/cine_params_draft.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/data/screenplay_draft_tags.dart';
import 'script_editor_actions.dart';
import 'script_editor_navigation.dart';
import 'storyboard_playback_bar.dart';
import 'storyboard_shot_grid_card.dart';
import 'storyboard_shot_meta.dart';
import 'storyboard_shot_toolbar.dart';

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
  final _selectedTags = <String>{};
  bool _groupByScene = false;
  int? _selectedIndex;

  static const _gridCrossAxisCount = 3;
  static const _gridSpacing = 8.0;
  static const _gridAspectRatio = 0.62;

  List<DraftFrameRef> get _allRefs => draftAllFrameRefs(widget.draft);

  List<String> get _tagOptions => draftTagPoolSorted(widget.draft);

  List<DraftFrameRef> get _filteredRefs {
    if (_selectedTags.isEmpty) return _allRefs;
    return [
      for (final ref in _allRefs)
        if (draftFrameMatchesAnyTag(widget.draft, ref, _selectedTags)) ref,
    ];
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _clearTags() => setState(_selectedTags.clear);

  void _openFrame(DraftFrameRef ref, int displayIndex) {
    setState(() => _selectedIndex = displayIndex);
    openFrameEditorDetail(
      context,
      actions: widget.actions,
      actIndex: ref.actIndex,
      sceneIndex: ref.sceneIndex,
      frameIndex: ref.frameIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final refs = _filteredRefs;
    final shellBottom =
        widget.embeddedInHub ? ShellInsets.of(context) : 0.0;
    final totalSec = draftTotalDurationSec(widget.draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StoryboardShotToolbar(
          shotCount: refs.length,
          tags: _tagOptions,
          selectedTags: _selectedTags,
          groupByScene: _groupByScene,
          onTagToggle: _toggleTag,
          onClearTags: _clearTags,
          onGroupToggled: () => setState(() => _groupByScene = !_groupByScene),
        ),
        Expanded(
          child: refs.isEmpty
              ? const Center(child: Text('暂无镜头可展示'))
              : _groupByScene
                  ? _buildGroupedScroll(refs, shellBottom)
                  : _buildFlatGrid(refs, shellBottom),
        ),
        if (!widget.embeddedInHub)
          StoryboardPlaybackBar(
            sceneLabel: '全部镜头（${refs.length}画）',
            frameCount: refs.length,
            totalDurationSec: totalSec,
            onPlay: () => showPlaybackComingSoon(context),
          ),
      ],
    );
  }

  Widget _buildFlatGrid(List<DraftFrameRef> refs, double shellBottom) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        4,
        AppDimensions.spacingMd,
        8 + shellBottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCrossAxisCount,
        mainAxisSpacing: _gridSpacing,
        crossAxisSpacing: _gridSpacing,
        childAspectRatio: _gridAspectRatio,
      ),
      itemCount: refs.length,
      itemBuilder: (context, index) =>
          _buildCard(ref: refs[index], displayIndex: index),
    );
  }

  Widget _buildGroupedScroll(List<DraftFrameRef> refs, double shellBottom) {
    final groups = <({String title, List<DraftFrameRef> refs})>[];
    for (var actIndex = 0; actIndex < widget.draft.acts.length; actIndex++) {
      final act = widget.draft.acts[actIndex];
      final actTitle = act.title.trim().isEmpty
          ? '第${actIndex + 1}幕'
          : act.title.trim();
      for (var sceneIndex = 0; sceneIndex < act.scenes.length; sceneIndex++) {
        final sceneRefs = refs
            .where(
              (r) => r.actIndex == actIndex && r.sceneIndex == sceneIndex,
            )
            .toList();
        if (sceneRefs.isEmpty) continue;
        final sceneTitle = act.scenes[sceneIndex].title.trim().isEmpty
            ? '第${sceneIndex + 1}场'
            : act.scenes[sceneIndex].title.trim();
        groups.add((title: '$actTitle · $sceneTitle', refs: sceneRefs));
      }
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        4,
        AppDimensions.spacingMd,
        8 + shellBottom,
      ),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        return Padding(
          padding:
              EdgeInsets.only(bottom: groupIndex < groups.length - 1 ? 12 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  group.title,
                  style: AppTextStyles.label.copyWith(fontSize: 12),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridCrossAxisCount,
                  mainAxisSpacing: _gridSpacing,
                  crossAxisSpacing: _gridSpacing,
                  childAspectRatio: _gridAspectRatio,
                ),
                itemCount: group.refs.length,
                itemBuilder: (context, index) {
                  final ref = group.refs[index];
                  final displayIndex = refs.indexOf(ref);
                  return _buildCard(ref: ref, displayIndex: displayIndex);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required DraftFrameRef ref,
    required int displayIndex,
  }) {
    return StoryboardShotGridCard(
      sequenceLabel: storyboardShotSequenceLabel(displayIndex),
      ref: ref,
      selected: _selectedIndex == displayIndex,
      onTap: () => _openFrame(ref, displayIndex),
      onMore: () => _openFrame(ref, displayIndex),
    );
  }
}
