import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../editor/editor_quick_action_row.dart';
import '../editor/project_hero_card.dart';
import 'script_editor_batch_edit_sheet.dart';
import 'script_editor_actions.dart';
import 'script_editor_navigation.dart';
import 'script_editor_shot_list_tab.dart';
import 'script_editor_storyboard_tab.dart';
import 'script_editor_timeline_tab.dart';

class ScriptEditorOutlineTab extends StatefulWidget {
  const ScriptEditorOutlineTab({
    super.key,
    required this.draft,
    required this.actions,
    required this.onAddAct,
    required this.onAddScene,
    required this.structureEditor,
    this.editScriptId,
    this.onOpenSettings,
    this.hubLayout = true,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final VoidCallback onAddAct;
  final void Function(int actIndex) onAddScene;
  final Widget structureEditor;
  final String? editScriptId;
  final VoidCallback? onOpenSettings;
  final bool hubLayout;

  @override
  State<ScriptEditorOutlineTab> createState() => _ScriptEditorOutlineTabState();
}

class _ScriptEditorOutlineTabState extends State<ScriptEditorOutlineTab> {
  EditorHubMode _mode = EditorHubMode.outline;
  final _expandedActs = <int>{};
  ({int act, int scene})? _highlightedScene;

  @override
  void initState() {
    super.initState();
    if (widget.draft.acts.isNotEmpty) {
      _expandedActs.add(0);
    }
  }

  bool get _allActsExpanded =>
      widget.draft.acts.isNotEmpty &&
      _expandedActs.length == widget.draft.acts.length;

  void _toggleExpandAll() {
    setState(() {
      if (_allActsExpanded) {
        _expandedActs.clear();
      } else {
        _expandedActs
          ..clear()
          ..addAll(List.generate(widget.draft.acts.length, (i) => i));
      }
    });
  }

  void _toggleAct(int actIndex) {
    setState(() {
      if (_expandedActs.contains(actIndex)) {
        _expandedActs.remove(actIndex);
      } else {
        _expandedActs.add(actIndex);
      }
    });
  }

  Future<void> _openScene(int actIndex, int sceneIndex) async {
    setState(() => _highlightedScene = (act: actIndex, scene: sceneIndex));
    await openSceneEditorDetail(
      context,
      actions: widget.actions,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
    );
    if (mounted) setState(() {});
  }

  int get _defaultActIndex => widget.draft.acts.isEmpty
      ? 0
      : widget.draft.acts.length - 1;

  void _openMoreSheet() {
    showEditorMoreActionsSheet(
      context,
      onAddAct: widget.onAddAct,
      onAddScene: () => widget.onAddScene(_defaultActIndex),
      onBatchEdit: () => ScriptEditorBatchEditSheet.show(
        context,
        draft: widget.draft,
        scope: BatchEditScope.entireScript,
        onApply: widget.actions.onChanged,
      ),
      onOpenShotList: _openShotList,
    );
  }

  void _openShotList() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('分镜列表')),
          body: ScriptEditorShotListTab(
            draft: widget.draft,
            actions: widget.actions,
          ),
        ),
      ),
    );
  }

  Widget _buildModeBody() {
    switch (_mode) {
      case EditorHubMode.outline:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _buildOutlineContent(),
        );
      case EditorHubMode.script:
        return widget.structureEditor;
      case EditorHubMode.storyboard:
        return ScriptEditorStoryboardTab(
          draft: widget.draft,
          actions: widget.actions,
        );
      case EditorHubMode.timeline:
        return ScriptEditorTimelineTab(
          draft: widget.draft,
          actions: widget.actions,
        );
    }
  }

  Widget _buildOutlineContent() {
    final draft = widget.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              draftHierarchySummary(draft),
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
            ),
            const Spacer(),
            TextButton(
              onPressed: draft.acts.isEmpty ? null : _toggleExpandAll,
              child: Text(_allActsExpanded ? '全部收起' : '全部展开 >'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DraftStructureOutlineTree(
          draft: draft,
          actions: widget.actions,
          expandedActs: _expandedActs,
          highlightedScene: _highlightedScene,
          onToggleAct: _toggleAct,
          onSceneTap: _openScene,
        ),
      ],
    );
  }

  Widget _buildHubHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          ProjectHeroCard(
            draft: widget.draft,
            onSettingsTap: widget.onOpenSettings,
            onAddTagTap: widget.onOpenSettings,
          ),
          EditorHubModeBar(
            selectedMode: _mode,
            onModeSelected: (mode) => setState(() => _mode = mode),
            onAiDecompose: () => openAiCreationHub(
              context,
              editScriptId: widget.editScriptId,
            ),
            onMore: _openMoreSheet,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hubLayout) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProjectHeroCard(
            draft: widget.draft,
            onSettingsTap: widget.onOpenSettings,
            onAddTagTap: widget.onOpenSettings,
          ),
          _buildOutlineContent(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHubHeader(),
        Expanded(child: _buildModeBody()),
      ],
    );
  }
}

class DraftStructureOutlineTree extends StatelessWidget {
  const DraftStructureOutlineTree({
    super.key,
    required this.draft,
    required this.actions,
    required this.expandedActs,
    required this.highlightedScene,
    required this.onToggleAct,
    required this.onSceneTap,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final Set<int> expandedActs;
  final ({int act, int scene})? highlightedScene;
  final ValueChanged<int> onToggleAct;
  final Future<void> Function(int actIndex, int sceneIndex) onSceneTap;

  @override
  Widget build(BuildContext context) {
    if (draft.acts.isEmpty) {
      return Text('暂无结构', style: AppTextStyles.bodySecondary);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var actIndex = 0; actIndex < draft.acts.length; actIndex++)
          _ActOutlineSection(
            act: draft.acts[actIndex],
            actIndex: actIndex,
            expanded: expandedActs.contains(actIndex),
            highlightedScene: highlightedScene,
            onToggleAct: () => onToggleAct(actIndex),
            onSceneTap: onSceneTap,
          ),
      ],
    );
  }
}

class _ActOutlineSection extends StatelessWidget {
  const _ActOutlineSection({
    required this.act,
    required this.actIndex,
    required this.expanded,
    required this.highlightedScene,
    required this.onToggleAct,
    required this.onSceneTap,
  });

  final ActDraft act;
  final int actIndex;
  final bool expanded;
  final ({int act, int scene})? highlightedScene;
  final VoidCallback onToggleAct;
  final Future<void> Function(int actIndex, int sceneIndex) onSceneTap;

  @override
  Widget build(BuildContext context) {
    final actTitle = act.title.trim().isEmpty
        ? '第${actIndex + 1}幕'
        : act.title.trim();
    final actSynopsis = act.synopsis.trim();
    final sceneCount = act.scenes.length;
    final frameCount = act.scenes.fold(0, (sum, s) => sum + s.frames.length);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggleAct,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '第${actIndex + 1}幕 · $actTitle',
                          style: AppTextStyles.label,
                        ),
                        if (actSynopsis.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            actSynopsis,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '$sceneCount场 · $frameCount画',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: 8),
              for (var sceneIndex = 0;
                  sceneIndex < act.scenes.length;
                  sceneIndex++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SceneOutlineRow(
                    scene: act.scenes[sceneIndex],
                    actIndex: actIndex,
                    sceneIndex: sceneIndex,
                    highlighted: highlightedScene?.act == actIndex &&
                        highlightedScene?.scene == sceneIndex,
                    onSceneTap: () => onSceneTap(actIndex, sceneIndex),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SceneOutlineRow extends StatelessWidget {
  const _SceneOutlineRow({
    required this.scene,
    required this.actIndex,
    required this.sceneIndex,
    required this.highlighted,
    required this.onSceneTap,
  });

  final SceneDraft scene;
  final int actIndex;
  final int sceneIndex;
  final bool highlighted;
  final VoidCallback onSceneTap;

  @override
  Widget build(BuildContext context) {
    final sceneTitle = scene.title.trim().isEmpty
        ? '第${sceneIndex + 1}场'
        : scene.title.trim();
    final description = scene.description.trim();
    final frameCount = scene.frames.length;

    return Material(
      color: highlighted ? AppColors.accentLight : AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onSceneTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: highlighted ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '第${sceneIndex + 1}场 · $sceneTitle',
                      style: AppTextStyles.label.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  '$frameCount画',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 11,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
