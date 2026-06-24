import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_batch_edit_sheet.dart';
import '../../domain/script_editor_selection.dart';
import '../screenplay_editor_host.dart';
import '../widgets/frame_inspector_panel.dart';
import '../widgets/script_editor_bottom_toolbar.dart';
import '../widgets/script_editor_center_panel.dart';
import '../widgets/script_editor_left_panel.dart';
import '../widgets/script_studio_action_cards.dart';
import '../widgets/script_studio_module_rail.dart';
import '../widgets/script_studio_recent_section.dart';
import '../widgets/script_studio_workspace_app_bar.dart';

class ScriptStudioWorkspacePage extends StatefulWidget {
  const ScriptStudioWorkspacePage({
    super.key,
    this.editScriptId,
    this.createMode = false,
  });

  final String? editScriptId;
  final bool createMode;

  @override
  State<ScriptStudioWorkspacePage> createState() =>
      _ScriptStudioWorkspacePageState();
}

class _ScriptStudioWorkspacePageState extends State<ScriptStudioWorkspacePage> {
  final _local = ScreenplayLocalRepository.instance;
  ScriptEditorSelection _selection = ScriptEditorSelection.none;
  final Set<String> _checkedRefs = {};
  bool _showMobileInspector = false;

  @override
  void initState() {
    super.initState();
    _local.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _local.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => scheduleSetState(this);

  List<Screenplay> get _recentProjects {
    final items = List<Screenplay>.from(_local.localScreenplays);
    items.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items.take(8).toList(growable: false);
  }

  String? get _effectiveEditId {
    if (widget.createMode) return null;
    if (widget.editScriptId != null && widget.editScriptId!.isNotEmpty) {
      return widget.editScriptId;
    }
    if (_recentProjects.isEmpty) return null;
    return _recentProjects.first.id;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.createMode) {
      return _buildEditorHost(null);
    }

    final editId = _effectiveEditId;
    if (editId == null) {
      return _buildProjectPicker(context);
    }

    return _buildEditorHost(editId);
  }

  Widget _buildEditorHost(String? editId) {
    return ScreenplayEditorHost(
      key: ValueKey(editId ?? 'create'),
      editScriptId: editId,
      enableAutoSave: true,
      builder: (context, controller) {
        if (Breakpoints.isMobile(context)) {
          return _buildMobileWorkspace(context, controller);
        }
        return _buildDesktopWorkspace(context, controller);
      },
    );
  }

  Widget _buildProjectPicker(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Script Studio')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const ScriptStudioActionCards(),
          ScriptStudioRecentSection(
            projects: _recentProjects,
            onDataChanged: _onRepoChanged,
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: EmptyStateView(
              icon: Icons.movie_creation_outlined,
              title: '选择或新建项目',
              subtitle: '从最近项目中选择，或创建新剧本开始编辑',
              actionLabel: '新建剧本',
              onAction: () => context.push(AppRoutes.create),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileWorkspace(
    BuildContext context,
    ScreenplayEditorController controller,
  ) {
    final actions = controller.buildEditorActions();
    return Scaffold(
      appBar: ScriptStudioWorkspaceAppBar(
        controller: controller,
        onBatchEdit: () => _openBatchEdit(context, controller),
        onOpenSettings: controller.openProjectSettings,
        onPreview: () => _openPreview(controller),
      ),
      body: Stack(
        children: [
          ScriptEditorCenterPanel(
            controller: controller,
            actions: actions,
            selection: _selection,
            checkedRefs: _checkedRefs,
            onSelectionChanged: (s) {
              setState(() {
                _selection = s;
                _showMobileInspector = s.hasFrame;
              });
            },
            onCheckedChanged: _handleCheckedChanged,
            onOpenSettings: controller.openProjectSettings,
            onBatchEdit: () => _openBatchEdit(context, controller),
            onAddShot: () {
              final target = controller.defaultPickTarget(_selection);
              actions.onPickFrames(target);
            },
          ),
          if (_showMobileInspector && _selection.hasFrame)
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.25,
              maxChildSize: 0.85,
              builder: (context, scrollController) => Material(
                elevation: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusLg),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: FrameInspectorPanel(
                        actions: actions,
                        selection: _selection,
                        onChanged: () => controller.onChanged(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final target = controller.defaultPickTarget(_selection);
          actions.onPickFrames(target);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDesktopWorkspace(
    BuildContext context,
    ScreenplayEditorController controller,
  ) {
    final actions = controller.buildEditorActions();
    final allRefs = draftAllFrameRefs(controller.draft);

    return Scaffold(
      appBar: ScriptStudioWorkspaceAppBar(
        controller: controller,
        onBatchEdit: () => _openBatchEdit(context, controller),
        onOpenSettings: controller.openProjectSettings,
        onPreview: () => _openPreview(controller),
      ),
      body: Column(
        children: [
          if (controller.isPicking || controller.isPublishing)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ScriptStudioModuleRail(),
                SizedBox(
                  width: 280,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: ScriptEditorLeftPanel(
                      draft: controller.draft,
                      actions: actions,
                      selection: _selection,
                      onSelectionChanged: (s) =>
                          setState(() => _selection = s),
                      onAddAct: controller.addAct,
                      onAddScene: controller.addScene,
                      onChanged: () => controller.onChanged(),
                      structureEditor: controller.buildStructureMode(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ScriptEditorCenterPanel(
                    controller: controller,
                    actions: actions,
                    selection: _selection,
                    checkedRefs: _checkedRefs,
                    onSelectionChanged: (s) =>
                        setState(() => _selection = s),
                    onCheckedChanged: _handleCheckedChanged,
                    onOpenSettings: controller.openProjectSettings,
                    onBatchEdit: () => _openBatchEdit(context, controller),
                    onAddShot: () {
                      final target =
                          controller.defaultPickTarget(_selection);
                      actions.onPickFrames(target);
                    },
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: FrameInspectorPanel(
                      actions: actions,
                      selection: _selection,
                      onChanged: () => controller.onChanged(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ScriptEditorBottomToolbar(
            controller: controller,
            allRefs: allRefs,
            checkedRefs: _checkedRefs,
            onCheckedRefsChanged: (s) => setState(() {
              _checkedRefs
                ..clear()
                ..addAll(s);
            }),
            onImportComplete: _onRepoChanged,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final target = controller.defaultPickTarget(_selection);
          actions.onPickFrames(target);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleCheckedChanged(DraftFrameRef ref, bool checked) {
    setState(() {
      final key = refKeyForFrame(ref);
      if (checked) {
        _checkedRefs.add(key);
      } else {
        _checkedRefs.remove(key);
      }
    });
  }

  void _openBatchEdit(
    BuildContext context,
    ScreenplayEditorController controller,
  ) {
    final checkedRefs = draftAllFrameRefs(controller.draft)
        .where((r) => _checkedRefs.contains(refKeyForFrame(r)))
        .toList();
    ScriptEditorBatchEditSheet.show(
      context,
      draft: controller.draft,
      scope: BatchEditScope.entireScript,
      frameRefs: checkedRefs.isEmpty ? null : checkedRefs,
      onApply: controller.onChanged,
    );
  }

  void _openPreview(ScreenplayEditorController controller) {
    final refs = draftAllFrameRefs(controller.draft);
    final paths = refs
        .map((r) => r.frame.image.displayPath)
        .where((p) => p.isNotEmpty)
        .toList();
    if (paths.isEmpty) return;
    showImagePreview(
      context,
      imagePaths: paths,
      captions: refs.map((r) => r.frame.caption).toList(),
    );
  }
}
