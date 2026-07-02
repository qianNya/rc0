import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_motion.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../editor/editor_hub_tab_bar.dart';
import '../editor/editor_quick_action_row.dart';
import '../editor/project_hero_card.dart';
import '../editor/scene_frame_stack_preview.dart';
import '../upload_structure_drag.dart';
import 'script_editor_batch_edit_sheet.dart';
import 'script_editor_actions.dart';
import 'script_editor_navigation.dart';
import 'script_editor_frames_tab.dart';
import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../../shared/widgets/glass/glass.dart';
import '../../../../studio/presentation/studio_editor_shell_bridge.dart';
import '../../../../studio/presentation/widgets/script_studio_project_info_card.dart';
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
    this.hubFallbackTitle = '新建剧本',
    this.titleListenable,
    this.onBack,
    this.scriptMenuItems,
    this.onScriptSelected,
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
  final String hubFallbackTitle;
  final Listenable? titleListenable;
  final VoidCallback? onBack;
  final List<PopupMenuEntry<String>>? scriptMenuItems;
  final ValueChanged<String>? onScriptSelected;

  /// Mobile hub embed: avoids duplicate bottom bars and applies shell insets.
  bool get embeddedInHub => hubLayout;

  @override
  State<ScriptEditorOutlineTab> createState() => _ScriptEditorOutlineTabState();
}

class _ScriptEditorOutlineTabState extends State<ScriptEditorOutlineTab> {
  final _expandedActs = <int>{};
  late final StudioEditorShellBridge _shellBridge;

  EditorHubMode get _mode => widget.hubLayout
      ? _shellBridge.hubMode
      : EditorHubMode.outline;

  @override
  void initState() {
    super.initState();
    _shellBridge = StudioEditorShellBridge.instance;
    if (widget.hubLayout) {
      _shellBridge.addListener(_onShellBridgeChanged);
    }
    if (widget.draft.acts.isNotEmpty) {
      _expandedActs.add(0);
    }
  }

  @override
  void dispose() {
    if (widget.hubLayout) {
      _shellBridge.removeListener(_onShellBridgeChanged);
    }
    super.dispose();
  }

  void _onShellBridgeChanged() => setState(() {});

  @override
  void didUpdateWidget(covariant ScriptEditorOutlineTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final actCount = widget.draft.acts.length;
    if (actCount == 0) {
      _expandedActs.clear();
      return;
    }
    _expandedActs.removeWhere((i) => i >= actCount);
  }

  void _handleAddAct() {
    final newIndex = widget.draft.acts.length;
    widget.onAddAct();
    setState(() => _expandedActs.add(newIndex));
  }

  void _handleAddSceneForAct(int actIndex) {
    widget.onAddScene(actIndex);
    setState(() => _expandedActs.add(actIndex));
  }

  Future<bool> _confirmDismissAct(int actIndex) async {
    if (!widget.canRemoveAct(actIndex)) return false;
    final confirmed = await showGlassDialog<bool>(
      context,
      child: GlassDialog(
        title: const Text('删除幕'),
        onClose: () => Navigator.pop(context, false),
        child: const Text('确定删除此幕及其所有场次吗？'),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  '删除',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed == true;
  }

  Future<void> _removeAct(int actIndex) async {
    await widget.onRemoveAct(actIndex);
    if (!mounted) return;
    setState(() {
      final count = widget.draft.acts.length;
      if (count == 0) {
        _expandedActs.clear();
      } else {
        _expandedActs.removeWhere((i) => i >= count);
      }
    });
  }

  Future<bool> _confirmDismissScene(int actIndex, int sceneIndex) async {
    if (!widget.actions.canRemoveScene(actIndex, sceneIndex)) return false;
    final confirmed = await showGlassDialog<bool>(
      context,
      child: GlassDialog(
        title: const Text('删除场'),
        onClose: () => Navigator.pop(context, false),
        child: const Text('确定删除此场及其所有分镜吗？'),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  '删除',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed == true;
  }

  Future<void> _removeScene(int actIndex, int sceneIndex) async {
    await widget.actions.onRemoveScene(actIndex, sceneIndex);
    if (mounted) setState(() {});
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
      onOpenProjectSettings: widget.onOpenSettings,
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
    openShotList(
      context,
      draft: widget.draft,
      actions: widget.actions,
    );
  }

  double _scrollBottomPadding(BuildContext context) {
    final shell = ShellInsets.of(context);
    if (shell > 0) return shell;
    return 12;
  }

  int get _modeIndex {
    switch (_mode) {
      case EditorHubMode.script:
        return 1;
      case EditorHubMode.frames:
        return 2;
      case EditorHubMode.outline:
        return 0;
    }
  }

  String get _structureVersion {
    final draft = widget.draft;
    final actCount = draft.acts.length;
    var sceneCount = 0;
    var frameCount = 0;
    for (final act in draft.acts) {
      sceneCount += act.scenes.length;
      for (final scene in act.scenes) {
        frameCount += scene.frames.length;
      }
    }
    return '$actCount-$sceneCount-$frameCount-${_expandedActs.length}';
  }

  Widget _buildModeStack() {
    final bottomPadding = _scrollBottomPadding(context);
    return FadeSlideIndexedStack(
      index: _modeIndex,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            0,
            AppDimensions.spacingMd,
            bottomPadding,
          ),
          child: AnimatedSwitcher(
            duration: AppMotion.normal,
            switchInCurve: AppMotion.standard,
            switchOutCurve: AppMotion.smooth,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey('outline-$_structureVersion'),
              child: _buildOutlineContent(),
            ),
          ),
        ),
        widget.structureEditor,
        ScriptEditorFramesTab(
          draft: widget.draft,
          actions: widget.actions,
          embeddedInHub: widget.embeddedInHub,
        ),
      ],
    );
  }

  Widget _buildOutlineContent() {
    final draft = widget.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _OutlineAddButton(
            label: '添加幕',
            icon: Icons.add_box_outlined,
            onPressed: _handleAddAct,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: DraftStructureOutlineTree(
            draft: draft,
            actions: widget.actions,
            expandedActs: _expandedActs,
            onToggleAct: _toggleAct,
            onAddScene: _handleAddSceneForAct,
            onAddAct: _handleAddAct,
            confirmDismissAct: _confirmDismissAct,
            onRemoveAct: _removeAct,
            confirmDismissScene: _confirmDismissScene,
            onRemoveScene: _removeScene,
            canRemoveAct: widget.canRemoveAct,
            onReorderActs: _handleReorderActs,
            onMoveScene: widget.onMoveScene,
            onSceneTap: _openScene,
            onFrameStackTap: _openFrameStack,
          ),
        ),
      ],
    );
  }

  Widget _buildHubProjectHeader() {
    final listenable = widget.titleListenable;
    Widget buildCard() {
      final rawTitle = widget.draft.title.trim();
      return ScriptStudioProjectInfoCard(
        draft: widget.draft,
        title: rawTitle,
        fallbackTitle: widget.hubFallbackTitle,
        onBack: widget.onBack!,
        onEditTap: widget.onOpenSettings,
        scriptMenuItems: widget.scriptMenuItems,
        onScriptSelected: widget.onScriptSelected,
      );
    }

    if (listenable == null) return buildCard();
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => buildCard(),
    );
  }

  Widget _buildHubHeader() {
    return AnimatedSwitcher(
      duration: AppMotion.normal,
      switchInCurve: AppMotion.standard,
      switchOutCurve: AppMotion.smooth,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey('hub-header-${_mode.name}'),
        child: EditorHubTabBar(
          selectedMode: _mode,
          onModeSelected: _shellBridge.setHubMode,
          onAiDecompose: () => openAiCreationHub(
            context,
            editScriptId: widget.editScriptId,
          ),
          onMore: _openMoreSheet,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hubLayout) {
      return ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
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

    final showInlineHub = Breakpoints.useSidebarShell(context);
    final showProjectHeader = widget.hubLayout && widget.onBack != null;

    if (showInlineHub) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showProjectHeader) _buildHubProjectHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: _buildHubHeader(),
          ),
          Expanded(child: _buildModeStack()),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showProjectHeader) _buildHubProjectHeader(),
        Expanded(child: _buildModeStack()),
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
    required this.onToggleAct,
    required this.onAddAct,
    required this.onAddScene,
    required this.confirmDismissAct,
    required this.onRemoveAct,
    required this.confirmDismissScene,
    required this.onRemoveScene,
    required this.canRemoveAct,
    required this.onReorderActs,
    required this.onMoveScene,
    required this.onSceneTap,
    required this.onFrameStackTap,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final Set<int> expandedActs;
  final ValueChanged<int> onToggleAct;
  final VoidCallback onAddAct;
  final void Function(int actIndex) onAddScene;
  final Future<bool> Function(int actIndex) confirmDismissAct;
  final Future<void> Function(int actIndex) onRemoveAct;
  final Future<bool> Function(int actIndex, int sceneIndex) confirmDismissScene;
  final Future<void> Function(int actIndex, int sceneIndex) onRemoveScene;
  final bool Function(int actIndex) canRemoveAct;
  final void Function(int oldIndex, int newIndex) onReorderActs;
  final void Function(SceneDragData data, int toActIndex, int toInsertIndex)
      onMoveScene;
  final Future<void> Function(int actIndex, int sceneIndex) onSceneTap;
  final Future<void> Function(int actIndex, int sceneIndex) onFrameStackTap;

  @override
  Widget build(BuildContext context) {
    if (draft.acts.isEmpty) {
      return AnimatedSwitcher(
        duration: AppMotion.normal,
        switchInCurve: AppMotion.standard,
        switchOutCurve: AppMotion.smooth,
        child: Padding(
          key: const ValueKey('outline-empty'),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '暂无结构',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 8),
                _OutlineAddButton(
                  label: '添加幕',
                  icon: Icons.add_box_outlined,
                  onPressed: onAddAct,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: AppMotion.normal,
      switchInCurve: AppMotion.standard,
      switchOutCurve: AppMotion.smooth,
      child: ReorderableListView.builder(
        key: ValueKey('outline-list-${draft.acts.length}-${expandedActs.length}'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: draft.acts.length,
        onReorderItem: onReorderActs,
        proxyDecorator: (child, index, animation) {
          final preview = _OutlineReorderSpacing.dragPreviewOf(child) ?? child;
          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Material(
                color: Colors.transparent,
                elevation: 6 * animation.value,
                shadowColor: AppColors.shadowDrag,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                clipBehavior: Clip.antiAlias,
                child: preview,
              );
            },
          );
        },
        itemBuilder: (context, actIndex) {
          final act = draft.acts[actIndex];
          final card = _ActOutlineSection(
            act: act,
            actIndex: actIndex,
            expanded: expandedActs.contains(actIndex),
            onToggleAct: () => onToggleAct(actIndex),
            onAddScene: () => onAddScene(actIndex),
            onMoveScene: (data, insertIndex) =>
                onMoveScene(data, actIndex, insertIndex),
            confirmDismissScene: (sceneIndex) =>
                confirmDismissScene(actIndex, sceneIndex),
            onRemoveScene: (sceneIndex) => onRemoveScene(actIndex, sceneIndex),
            canRemoveScene: (sceneIndex) =>
                actions.canRemoveScene(actIndex, sceneIndex),
            onSceneTap: onSceneTap,
            onFrameStackTap: onFrameStackTap,
          );

          final draggable = ReorderableDragStartListener(
            index: actIndex,
            child: card,
          );

          final item = canRemoveAct(actIndex)
              ? Dismissible(
                  key: ValueKey('outline-act-$actIndex'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => confirmDismissAct(actIndex),
                  onDismissed: (_) => onRemoveAct(actIndex),
                  background: const _DismissDeleteBackground(label: '删除幕'),
                  child: draggable,
                )
              : draggable;

          return KeyedSubtree(
            key: ValueKey('outline-act-$actIndex'),
            child: _OutlineReorderSpacing(
              spacingTop:
                  actIndex == 0 ? 0 : AppDimensions.spacingSm,
              dragPreview: card,
              child: item,
            ),
          );
        },
      ),
    );
  }
}

class _OutlineAddButton extends StatelessWidget {
  const _OutlineAddButton({
    this.label,
    required this.icon,
    required this.onPressed,
    this.iconOnly = false,
  });

  final String? label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    if (iconOnly || label == null || label!.isEmpty) {
      return IconButton(
        onPressed: onPressed,
        tooltip: '添加场',
        icon: Icon(icon, size: 18),
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        visualDensity: VisualDensity.compact,
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label!),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Keeps list spacing outside the dragged card preview.
class _OutlineReorderSpacing extends StatelessWidget {
  const _OutlineReorderSpacing({
    required this.spacingTop,
    required this.dragPreview,
    required this.child,
  });

  final double spacingTop;
  final Widget dragPreview;
  final Widget child;

  static Widget? dragPreviewOf(Widget widget) {
    if (widget is KeyedSubtree) {
      return dragPreviewOf(widget.child);
    }
    if (widget is _OutlineReorderSpacing) {
      return widget.dragPreview;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (spacingTop <= 0) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: spacingTop),
        child,
      ],
    );
  }
}

class _DismissDeleteBackground extends StatelessWidget {
  const _DismissDeleteBackground({
    required this.label,
    this.borderRadius = AppDimensions.radiusXl,
  });

  final String label;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActOutlineSection extends StatelessWidget {
  const _ActOutlineSection({
    required this.act,
    required this.actIndex,
    required this.expanded,
    required this.onToggleAct,
    required this.onAddScene,
    required this.onMoveScene,
    required this.confirmDismissScene,
    required this.onRemoveScene,
    required this.canRemoveScene,
    required this.onSceneTap,
    required this.onFrameStackTap,
  });

  static const double _headerControlSize = 28;

  final ActDraft act;
  final int actIndex;
  final bool expanded;
  final VoidCallback onToggleAct;
  final VoidCallback onAddScene;
  final void Function(SceneDragData data, int insertIndex) onMoveScene;
  final Future<bool> Function(int sceneIndex) confirmDismissScene;
  final Future<void> Function(int sceneIndex) onRemoveScene;
  final bool Function(int sceneIndex) canRemoveScene;
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
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final primaryText =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryText =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: _headerControlSize,
                  height: _headerControlSize,
                  child: Center(
                    child: Icon(
                      Icons.drag_handle,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: _headerControlSize,
                  height: _headerControlSize,
                  child: IconButton(
                    onPressed: onToggleAct,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: _headerControlSize,
                      height: _headerControlSize,
                    ),
                    icon: Icon(
                      expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                      color: secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '第${actIndex + 1}幕 · $actTitle',
                    style: AppTextStyles.label.copyWith(
                      color: primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  '$sceneCount场 · $frameCount画',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
                _OutlineAddButton(
                  icon: Icons.add_location_alt_outlined,
                  onPressed: onAddScene,
                  iconOnly: true,
                ),
              ],
            ),
            if (actSynopsis.isNotEmpty) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(
                  right: AppDimensions.spacingSm,
                ),
                child: Text(
                  actSynopsis,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            ClipRect(
              child: AnimatedSize(
                duration: AppMotion.normal,
                curve: AppMotion.standard,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppDimensions.spacingXs),
                          for (var sceneIndex = 0;
                              sceneIndex < act.scenes.length;
                              sceneIndex++) ...[
                            StructureInsertDropTarget<SceneDragData>(
                              onAccept: (data) => onMoveScene(data, sceneIndex),
                              canAccept: (data) {
                                if (data.fromActIndex != actIndex) {
                                  return true;
                                }
                                return act.scenes.indexOf(data.scene) != sceneIndex;
                              },
                            ),
                            _SceneOutlineRow(
                              scene: act.scenes[sceneIndex],
                              actIndex: actIndex,
                              sceneIndex: sceneIndex,
                              canRemove: canRemoveScene(sceneIndex),
                              margin: EdgeInsets.only(
                                bottom: sceneIndex < act.scenes.length - 1
                                    ? AppDimensions.spacingXs
                                    : 0,
                              ),
                              onSceneTap: () => onSceneTap(actIndex, sceneIndex),
                              onFrameStackTap: () =>
                                  onFrameStackTap(actIndex, sceneIndex),
                              confirmDismiss: () =>
                                  confirmDismissScene(sceneIndex),
                              onRemove: () => onRemoveScene(sceneIndex),
                            ),
                          ],
                          StructureInsertDropTarget<SceneDragData>(
                            onAccept: (data) =>
                                onMoveScene(data, act.scenes.length),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
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
    required this.canRemove,
    required this.margin,
    required this.onSceneTap,
    required this.onFrameStackTap,
    required this.confirmDismiss,
    required this.onRemove,
  });

  final SceneDraft scene;
  final int actIndex;
  final int sceneIndex;
  final bool canRemove;
  final EdgeInsetsGeometry margin;
  final VoidCallback onSceneTap;
  final VoidCallback onFrameStackTap;
  final Future<bool> Function() confirmDismiss;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor =
        isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    final card = Material(
      color: rowColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onSceneTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: borderColor),
          ),
          child: _SceneOutlineRowContent(
            scene: scene,
            sceneIndex: sceneIndex,
            onFrameStackTap: onFrameStackTap,
          ),
        ),
      ),
    );

    final draggable = CrossListDragHandle<SceneDragData>(
      data: SceneDragData(fromActIndex: actIndex, scene: scene),
      feedback: sceneOutlineCardDragFeedback(scene, sceneIndex),
      child: card,
    );

    final row = canRemove
        ? Dismissible(
            key: ValueKey('outline-scene-$actIndex-$sceneIndex'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => confirmDismiss(),
            onDismissed: (_) => onRemove(),
            background: const _DismissDeleteBackground(
              label: '删除场',
              borderRadius: AppDimensions.radiusMd,
            ),
            child: draggable,
          )
        : draggable;

    return Container(
      margin: margin,
      child: row,
    );
  }
}

class _SceneOutlineRowContent extends StatelessWidget {
  const _SceneOutlineRowContent({
    required this.scene,
    required this.sceneIndex,
    required this.onFrameStackTap,
  });

  final SceneDraft scene;
  final int sceneIndex;
  final VoidCallback onFrameStackTap;

  @override
  Widget build(BuildContext context) {
    final sceneTitle = scene.title.trim().isEmpty
        ? '第${sceneIndex + 1}场'
        : scene.title.trim();
    final description = scene.description.trim();
    final frameCount = scene.frames.length;
    final secondaryText = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            Icons.drag_handle,
            size: 20,
            color: AppColors.textSecondary,
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
            color: secondaryText,
          ),
        ),
        const SizedBox(width: 2),
        Icon(
          Icons.chevron_right,
          size: 18,
          color: secondaryText,
        ),
      ],
    );
  }
}
