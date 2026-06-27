import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../editor/editor_quick_action_row.dart';
import '../editor/outline_structure_context_menu.dart';
import '../editor/project_hero_card.dart';
import '../editor/scene_frame_stack_preview.dart';
import '../screenplay_editor_sections.dart';
import '../upload_structure_drag.dart';
import 'script_editor_batch_edit_sheet.dart';
import 'script_editor_actions.dart';
import 'script_editor_navigation.dart';
import 'script_editor_shot_list_tab.dart';
import 'script_editor_storyboard_tab.dart';
import 'script_editor_timeline_tab.dart';
import '../../../../../shared/widgets/rc0_app_bar.dart';
import '../../../../../shared/widgets/shell_insets.dart';

class ScriptEditorOutlineTab extends StatefulWidget {
  const ScriptEditorOutlineTab({
    super.key,
    required this.draft,
    required this.actions,
    required this.onAddAct,
    required this.onAddScene,
    required this.onRemoveAct,
    required this.canRemoveAct,
    required this.onReorderActs,
    required this.onMoveScene,
    required this.structureEditor,
    this.editScriptId,
    this.onOpenSettings,
    this.hubLayout = true,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final VoidCallback onAddAct;
  final void Function(int actIndex) onAddScene;
  final Future<void> Function(int actIndex) onRemoveAct;
  final bool Function(int actIndex) canRemoveAct;
  final void Function(int oldIndex, int newIndex) onReorderActs;
  final void Function(SceneDragData data, int toActIndex, int toInsertIndex)
      onMoveScene;
  final Widget structureEditor;
  final String? editScriptId;
  final VoidCallback? onOpenSettings;
  final bool hubLayout;

  /// Mobile hub embed: avoids duplicate bottom bars and applies shell insets.
  bool get embeddedInHub => hubLayout;

  @override
  State<ScriptEditorOutlineTab> createState() => _ScriptEditorOutlineTabState();
}

class _ScriptEditorOutlineTabState extends State<ScriptEditorOutlineTab> {
  EditorHubMode _mode = EditorHubMode.outline;
  final _expandedActs = <int>{};
  int? _selectedActIndex;

  @override
  void initState() {
    super.initState();
    if (widget.draft.acts.isNotEmpty) {
      _expandedActs.add(0);
      _selectedActIndex = 0;
    }
  }

  @override
  void didUpdateWidget(covariant ScriptEditorOutlineTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final actCount = widget.draft.acts.length;
    if (actCount == 0) {
      _selectedActIndex = null;
      _expandedActs.clear();
      return;
    }
    if (_selectedActIndex == null || _selectedActIndex! >= actCount) {
      _selectedActIndex = actCount - 1;
    }
    _expandedActs.removeWhere((i) => i >= actCount);
  }

  void _selectAct(int actIndex) {
    setState(() {
      _selectedActIndex = actIndex;
      _expandedActs.add(actIndex);
    });
  }

  void _handleAddAct() {
    final newIndex = widget.draft.acts.length;
    widget.onAddAct();
    setState(() {
      _selectedActIndex = newIndex;
      _expandedActs.add(newIndex);
    });
  }

  void _handleAddSceneForAct(int actIndex) {
    setState(() => _selectedActIndex = actIndex);
    widget.onAddScene(actIndex);
  }

  Future<void> _confirmRemoveAct(int actIndex) async {
    if (!widget.canRemoveAct(actIndex)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除幕'),
        content: const Text('确定删除此幕及其所有场次吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '删除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.onRemoveAct(actIndex);
    if (!mounted) return;
    setState(() {
      final count = widget.draft.acts.length;
      if (count == 0) {
        _selectedActIndex = null;
        _expandedActs.clear();
      } else {
        if (_selectedActIndex == null || _selectedActIndex! >= count) {
          _selectedActIndex = count - 1;
        }
        _expandedActs.removeWhere((i) => i >= count);
      }
    });
  }

  Future<void> _confirmRemoveScene(int actIndex, int sceneIndex) async {
    if (!widget.actions.canRemoveScene(actIndex, sceneIndex)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除场'),
        content: const Text('确定删除此场及其所有分镜吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '删除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.actions.onRemoveScene(actIndex, sceneIndex);
    if (mounted) setState(() {});
  }

  void _showEmptyOutlineMenu(Offset globalPosition) {
    showOutlineStructureContextMenu(
      context,
      globalPosition: globalPosition,
      scope: OutlineStructureMenuScope.empty,
      actIndex: 0,
      onAddAct: _handleAddAct,
      onAddScene: () {},
      onRemoveAct: _confirmRemoveAct,
      onRemoveScene: _confirmRemoveScene,
      canRemoveAct: false,
      canRemoveScene: widget.actions.canRemoveScene,
    );
  }

  void _showActOutlineMenu(int actIndex, Offset globalPosition) {
    _selectAct(actIndex);
    showOutlineStructureContextMenu(
      context,
      globalPosition: globalPosition,
      scope: OutlineStructureMenuScope.act,
      actIndex: actIndex,
      onAddAct: _handleAddAct,
      onAddScene: () => _handleAddSceneForAct(actIndex),
      onRemoveAct: _confirmRemoveAct,
      onRemoveScene: _confirmRemoveScene,
      canRemoveAct: widget.canRemoveAct(actIndex),
      canRemoveScene: widget.actions.canRemoveScene,
    );
  }

  void _showSceneOutlineMenu(
    int actIndex,
    int sceneIndex,
    Offset globalPosition,
  ) {
    _selectAct(actIndex);
    showOutlineStructureContextMenu(
      context,
      globalPosition: globalPosition,
      scope: OutlineStructureMenuScope.scene,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      onAddAct: _handleAddAct,
      onAddScene: () => _handleAddSceneForAct(actIndex),
      onRemoveAct: _confirmRemoveAct,
      onRemoveScene: _confirmRemoveScene,
      canRemoveAct: widget.canRemoveAct(actIndex),
      canRemoveScene: widget.actions.canRemoveScene,
    );
  }

  void _handleReorderActs(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    widget.onReorderActs(oldIndex, newIndex);
    setState(() {
      int remap(int i) {
        if (i == oldIndex) return newIndex;
        if (oldIndex < newIndex) {
          if (i > oldIndex && i <= newIndex) return i - 1;
        } else if (i >= newIndex && i < oldIndex) {
          return i + 1;
        }
        return i;
      }

      final previous = Set<int>.from(_expandedActs);
      _expandedActs
        ..clear()
        ..addAll(previous.map(remap));

      final sel = _selectedActIndex;
      if (sel == null) return;
      _selectedActIndex = remap(sel);
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
    await openSceneEditorDetail(
      context,
      actions: widget.actions,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
    );
    if (mounted) setState(() {});
  }

  Future<void> _openFrameStack(int actIndex, int sceneIndex) async {
    final scene = widget.draft.acts[actIndex].scenes[sceneIndex];
    if (scene.frames.isEmpty) {
      widget.actions.onPickFrames(
        FramePickTarget(actIndex: actIndex, sceneIndex: sceneIndex),
      );
      if (mounted) setState(() {});
      return;
    }
    await openFrameEditorDetail(
      context,
      actions: widget.actions,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: min(scene.frames.length - 1, 4),
    );
    if (mounted) setState(() {});
  }

  void _openMoreSheet() {
    showEditorMoreActionsSheet(
      context,
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
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: Rc0AppBar(title: const Text('分镜列表')),
          body: ScriptEditorShotListTab(
            draft: widget.draft,
            actions: widget.actions,
          ),
        ),
      ),
    );
  }

  double _scrollBottomPadding(BuildContext context) {
    final shell = ShellInsets.of(context);
    if (shell > 0) return shell;
    return 12;
  }

  Widget _buildModeBody() {
    final bottomPadding = _scrollBottomPadding(context);
    switch (_mode) {
      case EditorHubMode.outline:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding),
          child: _buildOutlineContent(),
        );
      case EditorHubMode.script:
        return widget.structureEditor;
      case EditorHubMode.storyboard:
        return ScriptEditorStoryboardTab(
          draft: widget.draft,
          actions: widget.actions,
          embeddedInHub: widget.embeddedInHub,
        );
      case EditorHubMode.timeline:
        return ScriptEditorTimelineTab(
          draft: widget.draft,
          actions: widget.actions,
          embeddedInHub: widget.embeddedInHub,
        );
    }
  }

  Widget _buildOutlineContent() {
    final draft = widget.draft;
    return DraftStructureOutlineTree(
      draft: draft,
      actions: widget.actions,
      expandedActs: _expandedActs,
      selectedActIndex: _selectedActIndex,
      onToggleAct: _toggleAct,
      onSelectAct: _selectAct,
      onActLongPress: _showActOutlineMenu,
      onSceneLongPress: _showSceneOutlineMenu,
      onEmptyLongPress: _showEmptyOutlineMenu,
      onReorderActs: _handleReorderActs,
      onMoveScene: widget.onMoveScene,
      onSceneTap: _openScene,
      onFrameStackTap: _openFrameStack,
    );
  }

  Widget _buildHubHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          ProjectHeroCard(
            draft: widget.draft,
            layout: ProjectHeroLayout.summary,
            onAddTagTap: widget.onOpenSettings,
          ),
          const SizedBox(height: 8),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: _buildHubHeader(),
        ),
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
    required this.selectedActIndex,
    required this.onToggleAct,
    required this.onSelectAct,
    required this.onActLongPress,
    required this.onSceneLongPress,
    required this.onEmptyLongPress,
    required this.onReorderActs,
    required this.onMoveScene,
    required this.onSceneTap,
    required this.onFrameStackTap,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final Set<int> expandedActs;
  final int? selectedActIndex;
  final ValueChanged<int> onToggleAct;
  final ValueChanged<int> onSelectAct;
  final void Function(int actIndex, Offset globalPosition) onActLongPress;
  final void Function(int actIndex, int sceneIndex, Offset globalPosition)
      onSceneLongPress;
  final void Function(Offset globalPosition) onEmptyLongPress;
  final void Function(int oldIndex, int newIndex) onReorderActs;
  final void Function(SceneDragData data, int toActIndex, int toInsertIndex)
      onMoveScene;
  final Future<void> Function(int actIndex, int sceneIndex) onSceneTap;
  final Future<void> Function(int actIndex, int sceneIndex) onFrameStackTap;

  @override
  Widget build(BuildContext context) {
    if (draft.acts.isEmpty) {
      return GestureDetector(
        onLongPressStart: (details) => onEmptyLongPress(details.globalPosition),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              '暂无结构，长按添加幕',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: draft.acts.length,
      onReorderItem: onReorderActs,
      itemBuilder: (context, actIndex) {
        final act = draft.acts[actIndex];
        return _ActOutlineSection(
          key: ValueKey('outline-act-$actIndex'),
          act: act,
          actIndex: actIndex,
          expanded: expandedActs.contains(actIndex),
          selected: selectedActIndex == actIndex,
          onToggleAct: () => onToggleAct(actIndex),
          onSelectAct: () => onSelectAct(actIndex),
          onLongPress: (position) => onActLongPress(actIndex, position),
          onMoveScene: (data, insertIndex) =>
              onMoveScene(data, actIndex, insertIndex),
          onSceneLongPress: onSceneLongPress,
          onSceneTap: onSceneTap,
          onFrameStackTap: onFrameStackTap,
        );
      },
    );
  }
}

class _ActOutlineSection extends StatelessWidget {
  const _ActOutlineSection({
    super.key,
    required this.act,
    required this.actIndex,
    required this.expanded,
    required this.selected,
    required this.onToggleAct,
    required this.onSelectAct,
    required this.onLongPress,
    required this.onMoveScene,
    required this.onSceneLongPress,
    required this.onSceneTap,
    required this.onFrameStackTap,
  });

  final ActDraft act;
  final int actIndex;
  final bool expanded;
  final bool selected;
  final VoidCallback onToggleAct;
  final VoidCallback onSelectAct;
  final void Function(Offset globalPosition) onLongPress;
  final void Function(SceneDragData data, int insertIndex) onMoveScene;
  final void Function(int actIndex, int sceneIndex, Offset globalPosition)
      onSceneLongPress;
  final Future<void> Function(int actIndex, int sceneIndex) onSceneTap;
  final Future<void> Function(int actIndex, int sceneIndex) onFrameStackTap;

  @override
  Widget build(BuildContext context) {
    final actTitle = act.title.trim().isEmpty
        ? '第${actIndex + 1}幕'
        : act.title.trim();
    final actSynopsis = act.synopsis.trim();
    final sceneCount = act.scenes.length;
    final frameCount = act.scenes.fold(0, (sum, s) => sum + s.frames.length);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final selectedFill =
        isDark ? AppColors.sidebarActiveDark : AppColors.sidebarActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? selectedFill : surfaceColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: onSelectAct,
          onLongPressStart: (details) => onLongPress(details.globalPosition),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: selected ? 4 : 0,
                  color: AppColors.accent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EditorDragHandle(index: actIndex),
                            InkWell(
                              onTap: onToggleAct,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusSm),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2, right: 4),
                                child: Icon(
                                  expanded
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_right,
                                  size: 20,
                                  color: selected
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '第${actIndex + 1}幕 · $actTitle',
                                    style: AppTextStyles.label.copyWith(
                                      color: selected
                                          ? AppColors.accent
                                          : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary),
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  if (actSynopsis.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      actSynopsis,
                                      style: AppTextStyles.bodySecondary.copyWith(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Text(
                                '$sceneCount场 · $frameCount画',
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 12,
                                  color: selected
                                      ? AppColors.accent
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (expanded) ...[
                          const SizedBox(height: 8),
                          for (var sceneIndex = 0;
                              sceneIndex < act.scenes.length;
                              sceneIndex++) ...[
                            StructureInsertDropTarget<SceneDragData>(
                              onAccept: (data) =>
                                  onMoveScene(data, sceneIndex),
                              canAccept: (data) {
                                if (data.fromActIndex != actIndex) {
                                  return true;
                                }
                                return act.scenes.indexOf(data.scene) !=
                                    sceneIndex;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _SceneOutlineRow(
                                scene: act.scenes[sceneIndex],
                                actIndex: actIndex,
                                sceneIndex: sceneIndex,
                                onSceneTap: () =>
                                    onSceneTap(actIndex, sceneIndex),
                                onFrameStackTap: () =>
                                    onFrameStackTap(actIndex, sceneIndex),
                                onLongPress: (position) => onSceneLongPress(
                                  actIndex,
                                  sceneIndex,
                                  position,
                                ),
                              ),
                            ),
                          ],
                          StructureInsertDropTarget<SceneDragData>(
                            onAccept: (data) =>
                                onMoveScene(data, act.scenes.length),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    required this.onSceneTap,
    required this.onFrameStackTap,
    required this.onLongPress,
  });

  final SceneDraft scene;
  final int actIndex;
  final int sceneIndex;
  final VoidCallback onSceneTap;
  final VoidCallback onFrameStackTap;
  final void Function(Offset globalPosition) onLongPress;

  @override
  Widget build(BuildContext context) {
    final sceneTitle = scene.title.trim().isEmpty
        ? '第${sceneIndex + 1}场'
        : scene.title.trim();
    final description = scene.description.trim();
    final frameCount = scene.frames.length;

    return Material(
      color: AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: GestureDetector(
        onTap: onSceneTap,
        onLongPressStart: (details) => onLongPress(details.globalPosition),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CrossListDragHandle<SceneDragData>(
                data: SceneDragData(fromActIndex: actIndex, scene: scene),
                feedback: sceneDragFeedback(scene, sceneIndex),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.drag_handle,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
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
              const SizedBox(width: 8),
              SceneFrameStackPreview(
                frames: scene.frames,
                onTap: onFrameStackTap,
              ),
              const SizedBox(width: 6),
              Text(
                '$frameCount画',
                style: AppTextStyles.bodySecondary.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
