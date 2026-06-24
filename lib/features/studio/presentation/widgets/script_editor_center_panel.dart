import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../upload/presentation/widgets/editor/project_hero_card.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_actions.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_navigation.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_storyboard_tab.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_timeline_tab.dart';
import '../../domain/script_editor_selection.dart';
import '../screenplay_editor_host.dart';
import 'studio_shot_card.dart';

/// Optional scene filter for the center shot list (independent of selection).
class SceneFilterOption {
  const SceneFilterOption.all() : actIndex = null, sceneIndex = null;

  const SceneFilterOption.scene({
    required this.actIndex,
    required this.sceneIndex,
  });

  final int? actIndex;
  final int? sceneIndex;

  String label(ScreenplayDraft draft) {
    if (actIndex == null) return '全部场次';
    final act = draft.acts[actIndex!];
    final scene = act.scenes[sceneIndex!];
    final sceneTitle = scene.title.trim().isEmpty
        ? '第${sceneIndex! + 1}场'
        : scene.title.trim();
    return '第${actIndex! + 1}幕 · $sceneTitle';
  }

  bool matches(DraftFrameRef ref) {
    if (actIndex == null) return true;
    return ref.actIndex == actIndex && ref.sceneIndex == sceneIndex;
  }

  String get key =>
      actIndex == null ? 'all' : '$actIndex-$sceneIndex';

  @override
  bool operator ==(Object other) =>
      other is SceneFilterOption &&
      other.actIndex == actIndex &&
      other.sceneIndex == sceneIndex;

  @override
  int get hashCode => Object.hash(actIndex, sceneIndex);
}

class ScriptEditorCenterPanel extends StatefulWidget {
  const ScriptEditorCenterPanel({
    super.key,
    required this.controller,
    required this.actions,
    required this.selection,
    required this.checkedRefs,
    required this.onSelectionChanged,
    required this.onCheckedChanged,
    required this.onOpenSettings,
    required this.onAddShot,
    required this.onBatchEdit,
  });

  final ScreenplayEditorController controller;
  final ScriptEditorActions actions;
  final ScriptEditorSelection selection;
  final Set<String> checkedRefs;
  final ValueChanged<ScriptEditorSelection> onSelectionChanged;
  final void Function(DraftFrameRef ref, bool checked) onCheckedChanged;
  final VoidCallback onOpenSettings;
  final VoidCallback onAddShot;
  final VoidCallback onBatchEdit;

  @override
  State<ScriptEditorCenterPanel> createState() =>
      _ScriptEditorCenterPanelState();
}

class _ScriptEditorCenterPanelState extends State<ScriptEditorCenterPanel> {
  static const _tabs = ['分镜模式', '故事板', '时间线'];
  int _tabIndex = 0;
  SceneFilterOption _sceneFilter = const SceneFilterOption.all();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScriptEditorCenterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selection.hasFrame &&
        widget.selection != oldWidget.selection) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final refs = _filteredRefs();
    final index = refs.indexWhere((r) => widget.selection.matchesRef(r));
    if (index < 0) return;
    final offset = (index * 140.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  List<SceneFilterOption> _sceneFilterOptions() {
    final options = <SceneFilterOption>[const SceneFilterOption.all()];
    for (var actIndex = 0; actIndex < widget.controller.draft.acts.length;
        actIndex++) {
      final act = widget.controller.draft.acts[actIndex];
      for (var sceneIndex = 0; sceneIndex < act.scenes.length; sceneIndex++) {
        options.add(
          SceneFilterOption.scene(
            actIndex: actIndex,
            sceneIndex: sceneIndex,
          ),
        );
      }
    }
    return options;
  }

  List<DraftFrameRef> _filteredRefs() {
    var refs = draftAllFrameRefs(
      widget.controller.draft,
      filterActIndex: widget.selection.hasScene
          ? widget.selection.actIndex
          : null,
      filterSceneIndex: widget.selection.hasScene
          ? widget.selection.sceneIndex
          : null,
    );
    if (_sceneFilter.actIndex != null) {
      refs = refs.where(_sceneFilter.matches).toList();
    }
    return refs;
  }

  void _handleMenuAction(DraftFrameRef ref, StudioShotCardAction action) {
    switch (action) {
      case StudioShotCardAction.delete:
        widget.actions.onRemoveFrame(
          ref.actIndex,
          ref.sceneIndex,
          ref.frameIndex,
        );
        widget.controller.onChanged();
      case StudioShotCardAction.duplicateParams:
        widget.controller.duplicateFrameParams(ref);
      case StudioShotCardAction.openDetail:
        openFrameEditorDetail(
          context,
          actions: widget.actions,
          actIndex: ref.actIndex,
          sceneIndex: ref.sceneIndex,
          frameIndex: ref.frameIndex,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ProjectHeroCard(
            draft: widget.controller.draft,
            onSettingsTap: widget.onOpenSettings,
            onAddTagTap: widget.onOpenSettings,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _buildToolbar(context),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: DetailTabBar(
            tabs: _tabs,
            selectedIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
        Expanded(child: _buildTabBody()),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: widget.onAddShot,
            icon: const Icon(Icons.add),
            label: const Text('添加分镜'),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final filterOptions = _sceneFilterOptions();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<SceneFilterOption>(
            value: filterOptions.contains(_sceneFilter)
                ? _sceneFilter
                : const SceneFilterOption.all(),
            decoration: const InputDecoration(
              labelText: '按场次筛选',
              isDense: true,
            ),
            items: [
              for (final option in filterOptions)
                DropdownMenuItem(
                  value: option,
                  child: Text(
                    option.label(widget.controller.draft),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _sceneFilter = v);
            },
          ),
        ),
        OutlinedButton(
          onPressed: widget.onBatchEdit,
          child: const Text('批量操作'),
        ),
        OutlinedButton(
          onPressed: () => context.push(AppRoutes.createAiHubPath),
          child: const Text('AI 助手'),
        ),
        IconButton.filled(
          tooltip: '添加分镜',
          onPressed: widget.onAddShot,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildTabBody() {
    switch (_tabIndex) {
      case 1:
        return ScriptEditorStoryboardTab(
          draft: widget.controller.draft,
          actions: widget.actions,
        );
      case 2:
        return ScriptEditorTimelineTab(
          draft: widget.controller.draft,
          actions: widget.actions,
        );
      default:
        return _buildShotList();
    }
  }

  Widget _buildShotList() {
    final refs = _filteredRefs();
    if (refs.isEmpty) {
      return Center(
        child: Text(
          '暂无分镜画面，点击「添加分镜」上传',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: refs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ref = refs[index];
        final refKey = refKeyForFrame(ref);
        return StudioShotCard(
          key: ValueKey(refKey),
          shotLabel: ref.shotLabel,
          frame: ref.frame,
          cineParams: ref.frame.cineParams,
          subtitle: '${ref.actTitle} · ${ref.sceneTitle}',
          selected: widget.selection.matchesRef(ref),
          checked: widget.checkedRefs.contains(refKey),
          onTap: () => widget.onSelectionChanged(
            ScriptEditorSelection().selectFrame(
              ref.actIndex,
              ref.sceneIndex,
              ref.frameIndex,
            ),
          ),
          onCheckedChanged: (checked) =>
              widget.onCheckedChanged(ref, checked),
          onCaptionChanged: (v) {
            widget.actions.onCaptionChanged(
              ref.actIndex,
              ref.sceneIndex,
              ref.frameIndex,
              v,
            );
            widget.controller.onChanged();
          },
          onActionNoteChanged: (v) {
            widget.actions.onActionNoteChanged(
              ref.actIndex,
              ref.sceneIndex,
              ref.frameIndex,
              v,
            );
            widget.controller.onChanged();
          },
          onMenuAction: (action) => _handleMenuAction(ref, action),
        );
      },
    );
  }
}

String refKeyForFrame(DraftFrameRef ref) =>
    '${ref.actIndex}-${ref.sceneIndex}-${ref.frameIndex}';
