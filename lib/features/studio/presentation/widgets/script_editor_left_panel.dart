import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_actions.dart';
import '../../domain/script_editor_selection.dart';

class ScriptEditorLeftPanel extends StatefulWidget {
  const ScriptEditorLeftPanel({
    super.key,
    required this.draft,
    required this.actions,
    required this.selection,
    required this.onSelectionChanged,
    required this.onAddAct,
    required this.onAddScene,
    required this.onChanged,
    required this.structureEditor,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final ScriptEditorSelection selection;
  final ValueChanged<ScriptEditorSelection> onSelectionChanged;
  final VoidCallback onAddAct;
  final void Function(int actIndex) onAddScene;
  final VoidCallback onChanged;
  final Widget structureEditor;

  @override
  State<ScriptEditorLeftPanel> createState() => _ScriptEditorLeftPanelState();
}

class _ScriptEditorLeftPanelState extends State<ScriptEditorLeftPanel> {
  static const _tabs = ['大纲', '编辑'];
  int _tabIndex = 0;
  final _expandedActs = <int>{0};
  final _expandedScenes = <String>{};

  String _sceneKey(int act, int scene) => '$act-$scene';

  bool get _allActsExpanded =>
      widget.draft.acts.isNotEmpty &&
      _expandedActs.length == widget.draft.acts.length;

  void _toggleExpandAll() {
    setState(() {
      if (_allActsExpanded) {
        _expandedActs.clear();
        _expandedScenes.clear();
      } else {
        _expandedActs
          ..clear()
          ..addAll(List.generate(widget.draft.acts.length, (i) => i));
        for (var a = 0; a < widget.draft.acts.length; a++) {
          for (var s = 0; s < widget.draft.acts[a].scenes.length; s++) {
            _expandedScenes.add(_sceneKey(a, s));
          }
        }
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

  void _toggleScene(int actIndex, int sceneIndex) {
    final key = _sceneKey(actIndex, sceneIndex);
    setState(() {
      if (_expandedScenes.contains(key)) {
        _expandedScenes.remove(key);
      } else {
        _expandedScenes.add(key);
      }
    });
  }

  Future<void> _confirmDeleteFrame(
    int actIndex,
    int sceneIndex,
    int frameIndex,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分镜'),
        content: const Text('确定删除此分镜吗？'),
        actions: [
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
    );
    if (confirmed == true) {
      await widget.actions.onRemoveFrame(actIndex, sceneIndex, frameIndex);
      widget.onChanged();
    }
  }

  Future<void> _confirmDeleteScene(int actIndex, int sceneIndex) async {
    if (!widget.actions.canRemoveScene(actIndex, sceneIndex)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除场次'),
        content: const Text('确定删除此场次及其所有分镜吗？'),
        actions: [
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
    );
    if (confirmed == true) {
      await widget.actions.onRemoveScene(actIndex, sceneIndex);
      widget.onChanged();
    }
  }

  Future<void> _renameScene(int actIndex, int sceneIndex) async {
    final scene = widget.draft.acts[actIndex].scenes[sceneIndex];
    final controller = TextEditingController(text: scene.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名场次'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '场次名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result != null) {
      widget.actions.onSceneFieldChanged?.call(
        actIndex,
        sceneIndex,
        title: result,
      );
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_tabs[i]),
                    selected: _tabIndex == i,
                    onSelected: (_) => setState(() => _tabIndex = i),
                    selectedColor: AppColors.accentLight,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: _tabIndex == i
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _tabIndex == 0
              ? _buildOutline()
              : widget.structureEditor,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: OutlinedButton.icon(
            onPressed: widget.onAddAct,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('新建幕'),
          ),
        ),
      ],
    );
  }

  Widget _buildOutline() {
    final draft = widget.draft;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('剧本结构', style: AppTextStyles.label.copyWith(fontSize: 13)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              draftHierarchySummary(draft),
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
            const Spacer(),
            TextButton(
              onPressed: draft.acts.isEmpty ? null : _toggleExpandAll,
              child: Text(_allActsExpanded ? '收起' : '展开'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var actIndex = 0; actIndex < draft.acts.length; actIndex++)
          _ActSection(
            act: draft.acts[actIndex],
            actIndex: actIndex,
            expanded: _expandedActs.contains(actIndex),
            expandedScenes: _expandedScenes,
            selection: widget.selection,
            onToggleAct: () => _toggleAct(actIndex),
            onToggleScene: _toggleScene,
            onSceneSelect: (sceneIndex) {
              widget.onSelectionChanged(
                ScriptEditorSelection().selectScene(actIndex, sceneIndex),
              );
            },
            onFrameTap: (sceneIndex, frameIndex) {
              widget.onSelectionChanged(
                ScriptEditorSelection().selectFrame(
                  actIndex,
                  sceneIndex,
                  frameIndex,
                ),
              );
            },
            onAddScene: () => widget.onAddScene(actIndex),
            onAddFrame: (sceneIndex) {
              widget.actions.onPickFrames(
                FramePickTarget(actIndex: actIndex, sceneIndex: sceneIndex),
              );
            },
            onRenameScene: _renameScene,
            onDeleteScene: _confirmDeleteScene,
            onDeleteFrame: _confirmDeleteFrame,
            sceneKeyBuilder: _sceneKey,
          ),
      ],
    );
  }
}

class _ActSection extends StatelessWidget {
  const _ActSection({
    required this.act,
    required this.actIndex,
    required this.expanded,
    required this.expandedScenes,
    required this.selection,
    required this.onToggleAct,
    required this.onToggleScene,
    required this.onSceneSelect,
    required this.onFrameTap,
    required this.onAddScene,
    required this.onAddFrame,
    required this.onRenameScene,
    required this.onDeleteScene,
    required this.onDeleteFrame,
    required this.sceneKeyBuilder,
  });

  final ActDraft act;
  final int actIndex;
  final bool expanded;
  final Set<String> expandedScenes;
  final ScriptEditorSelection selection;
  final VoidCallback onToggleAct;
  final void Function(int actIndex, int sceneIndex) onToggleScene;
  final ValueChanged<int> onSceneSelect;
  final void Function(int sceneIndex, int frameIndex) onFrameTap;
  final VoidCallback onAddScene;
  final ValueChanged<int> onAddFrame;
  final Future<void> Function(int actIndex, int sceneIndex) onRenameScene;
  final Future<void> Function(int actIndex, int sceneIndex) onDeleteScene;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)
      onDeleteFrame;
  final String Function(int act, int scene) sceneKeyBuilder;

  @override
  Widget build(BuildContext context) {
    final actTitle =
        act.title.trim().isEmpty ? '第${actIndex + 1}幕' : act.title.trim();
    final frameCount =
        act.scenes.fold(0, (sum, s) => sum + s.frames.length);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onToggleAct,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '第${actIndex + 1}幕 · $actTitle',
                      style: AppTextStyles.label.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${act.scenes.length}场 · $frameCount画',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 16),
                    onSelected: (v) {
                      if (v == 'add_scene') onAddScene();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'add_scene',
                        child: Text('添加场次'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (expanded)
              for (var sceneIndex = 0;
                  sceneIndex < act.scenes.length;
                  sceneIndex++)
                _SceneSection(
                  scene: act.scenes[sceneIndex],
                  actIndex: actIndex,
                  sceneIndex: sceneIndex,
                  expanded: expandedScenes
                      .contains(sceneKeyBuilder(actIndex, sceneIndex)),
                  selection: selection,
                  onToggle: () => onToggleScene(actIndex, sceneIndex),
                  onSceneSelect: () => onSceneSelect(sceneIndex),
                  onFrameTap: (frameIndex) =>
                      onFrameTap(sceneIndex, frameIndex),
                  onAddFrame: () => onAddFrame(sceneIndex),
                  onRename: () => onRenameScene(actIndex, sceneIndex),
                  onDelete: () => onDeleteScene(actIndex, sceneIndex),
                  onDeleteFrame: (frameIndex) =>
                      onDeleteFrame(actIndex, sceneIndex, frameIndex),
                ),
          ],
        ),
      ),
    );
  }
}

class _SceneSection extends StatelessWidget {
  const _SceneSection({
    required this.scene,
    required this.actIndex,
    required this.sceneIndex,
    required this.expanded,
    required this.selection,
    required this.onToggle,
    required this.onSceneSelect,
    required this.onFrameTap,
    required this.onAddFrame,
    required this.onRename,
    required this.onDelete,
    required this.onDeleteFrame,
  });

  final SceneDraft scene;
  final int actIndex;
  final int sceneIndex;
  final bool expanded;
  final ScriptEditorSelection selection;
  final VoidCallback onToggle;
  final VoidCallback onSceneSelect;
  final ValueChanged<int> onFrameTap;
  final VoidCallback onAddFrame;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final ValueChanged<int> onDeleteFrame;

  @override
  Widget build(BuildContext context) {
    final sceneTitle = scene.title.trim().isEmpty
        ? '第${sceneIndex + 1}场'
        : scene.title.trim();
    final sceneSelected = selection.matchesScene(actIndex, sceneIndex) &&
        !selection.hasFrame;

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: sceneSelected
                ? AppColors.accentLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: InkWell(
              onTap: onSceneSelect,
              onLongPress: () => _showSceneMenu(context),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                        expanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '第${sceneIndex + 1}场 · $sceneTitle',
                        style: AppTextStyles.label.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${scene.frames.length}画',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            for (var frameIndex = 0;
                frameIndex < scene.frames.length;
                frameIndex++)
              _FrameRow(
                frame: scene.frames[frameIndex],
                shotLabel: '${actIndex + 1}-${frameIndex + 1}',
                selected: selection.matchesRef(
                  DraftFrameRef(
                    actIndex: actIndex,
                    sceneIndex: sceneIndex,
                    frameIndex: frameIndex,
                    frame: scene.frames[frameIndex],
                    preview: frameDraftToPreviewFrame(
                      frame: scene.frames[frameIndex],
                      id: 'x',
                      orderIndex: frameIndex,
                    ),
                    sceneTitle: sceneTitle,
                    actTitle: '',
                  ),
                ),
                onTap: () => onFrameTap(frameIndex),
                onDelete: () => onDeleteFrame(frameIndex),
              ),
        ],
      ),
    );
  }

  void _showSceneMenu(BuildContext context) {
    showGlassSheet<void>(
      context,
      padding: kGlassSheetMenuPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('添加分镜'),
            onTap: () {
              Navigator.pop(context);
              onAddFrame();
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('重命名场次'),
            onTap: () {
              Navigator.pop(context);
              onRename();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text(
              '删除场次',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}

class _FrameRow extends StatelessWidget {
  const _FrameRow({
    required this.frame,
    required this.shotLabel,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final FrameDraft frame;
  final String shotLabel;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final caption =
        frame.caption.trim().isEmpty ? '未命名' : frame.caption.trim();

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4),
      child: Material(
        color: selected ? AppColors.accentLight : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            showGlassSheet<void>(
              context,
              padding: kGlassSheetMenuPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      '删除分镜',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: PoseCoverImage(
                      imagePath: frame.image.displayPath,
                      expand: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$shotLabel $caption',
                    style: AppTextStyles.label.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
