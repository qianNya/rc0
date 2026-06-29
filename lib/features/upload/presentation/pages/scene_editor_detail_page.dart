import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_scene_binding.dart';
import '../../../scene/presentation/widgets/scene_picker_sheet.dart';
import '../utils/shoot_preset_navigation.dart';
import '../widgets/editor/scene_frame_list_view.dart';
import '../widgets/screenplay_editor_sections.dart';
import '../widgets/script_editor/scene_editor_bottom_bar.dart';
import '../widgets/script_editor/script_editor_actions.dart';
import '../widgets/script_editor/script_editor_batch_edit_sheet.dart';
import '../widgets/script_editor/script_editor_navigation.dart';
import '../widgets/script_editor/script_editor_timeline_tab.dart';
class SceneEditorDetailPage extends StatefulWidget {
  const SceneEditorDetailPage({
    super.key,
    required this.actions,
    required this.actIndex,
    required this.sceneIndex,
    this.initialTabIndex = 0,
    this.initialFrameIndex,
  });

  final ScriptEditorActions actions;
  final int actIndex;
  final int sceneIndex;
  final int initialTabIndex;
  final int? initialFrameIndex;

  @override
  State<SceneEditorDetailPage> createState() => _SceneEditorDetailPageState();
}

class _SceneEditorDetailPageState extends State<SceneEditorDetailPage> {
  static const _mobileTabs = ['画面列表', '故事板'];
  static const _desktopTabs = ['画面列表', '故事板', '时间线'];

  late int _tabIndex;
  final _collapsedFrames = <FrameDraft>{};
  final _knownFrames = <FrameDraft>{};

  ScreenplayDraft get _draft => widget.actions.draft;

  SceneDraft get _scene =>
      _draft.acts[widget.actIndex].scenes[widget.sceneIndex];

  List<String> get _tabs =>
      Breakpoints.isDesktop(context) ? _desktopTabs : _mobileTabs;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, _desktopTabs.length - 1);
    _applyFrameDefaults();
    if (widget.initialFrameIndex != null) {
      final frames = _scene.frames;
      final index = widget.initialFrameIndex!;
      if (index >= 0 && index < frames.length) {
        _collapsedFrames.remove(frames[index]);
      }
    }
  }

  void _applyFrameDefaults() {
    final frames = _scene.frames;
    final singleFrame = frames.length == 1;
    for (final frame in frames) {
      if (_knownFrames.add(frame) && !singleFrame) {
        _collapsedFrames.add(frame);
      }
    }
  }

  void _refresh() {
    widget.actions.onChanged();
    setState(_applyFrameDefaults);
  }

  bool _isFrameExpanded(FrameDraft frame) => !_collapsedFrames.contains(frame);

  void _toggleFrame(FrameDraft frame) {
    setState(() {
      if (_collapsedFrames.contains(frame)) {
        _collapsedFrames.remove(frame);
      } else {
        _collapsedFrames.add(frame);
      }
    });
  }

  String get _sceneTitle {
    final title = _scene.title.trim();
    return title.isEmpty ? '第${widget.sceneIndex + 1}场' : title;
  }

  void _openFrameDetail(int frameIndex) {
    openFrameEditorDetail(
      context,
      actions: widget.actions,
      actIndex: widget.actIndex,
      sceneIndex: widget.sceneIndex,
      frameIndex: frameIndex,
    ).then((_) {
      if (mounted) _refresh();
    });
  }

  void _pickFrames() {
    widget.actions.onPickFrames(
      FramePickTarget(
        actIndex: widget.actIndex,
        sceneIndex: widget.sceneIndex,
      ),
    );
  }

  void _openBatchEdit() {
    ScriptEditorBatchEditSheet.show(
      context,
      draft: _draft,
      scope: BatchEditScope.scene,
      actIndex: widget.actIndex,
      sceneIndex: widget.sceneIndex,
      onApply: _refresh,
    );
  }

  void _openTimeline() {
    openSceneTimeline(
      context,
      draft: _draft,
      actions: widget.actions,
      sceneTitle: _sceneTitle,
      filterActIndex: widget.actIndex,
      filterSceneIndex: widget.sceneIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;
    final frames = scene.frames;
    final isDesktop = Breakpoints.isDesktop(context);
    final frameCount = frames.length;

    return DesktopStackScaffold(
      title: Text('第${widget.sceneIndex + 1}场 · $_sceneTitle（$frameCount 画）'),
      onBack: () => popOrGoStudio(context),
      centerTitle: false,
      actions: [
        if (!isDesktop)
          PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'timeline',
                  child: Text('时间线'),
                ),
                const PopupMenuItem(
                  value: 'preset',
                  child: Text('参数预设'),
                ),
                const PopupMenuItem(
                  value: 'ai',
                  child: Text('AI 助手'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'timeline':
                    _openTimeline();
                  case 'preset':
                    _openScenePreset();
                  case 'ai':
                    openAiCreationHub(context);
                }
              },
            ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SceneLibraryBanner(
            scene: _scene,
            draft: _draft,
            onChanged: _refresh,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: DetailTabBar(
              tabs: _tabs,
              selectedIndex: _tabIndex.clamp(0, _tabs.length - 1),
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FadeSlideIndexedStack(
              index: _tabIndex.clamp(0, _tabs.length - 1),
              children: [
                _buildFramesTab(scene, frames, isDesktop),
                _buildStoryboardTab(scene, frames, isDesktop),
                if (isDesktop)
                  ScriptEditorTimelineTab(
                    draft: _draft,
                    actions: widget.actions,
                    filterActIndex: widget.actIndex,
                    filterSceneIndex: widget.sceneIndex,
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0 && !isDesktop
          ? FloatingActionButton(
              onPressed: _pickFrames,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: isDesktop
          ? SceneEditorBottomBar(
              onBatchEdit: _openBatchEdit,
              onPreset: _openScenePreset,
              onAiAssistant: () => openAiCreationHub(context),
            )
          : (_tabIndex == 1
              ? null
              : SceneEditorBottomBar(
                  onBatchEdit: _openBatchEdit,
                  onPreset: _openScenePreset,
                  onAiAssistant: () => openAiCreationHub(context),
                )),
    );
  }

  Future<void> _openScenePreset() async {
    final picked = await openShootPresetPicker(
      context,
      scope: 'scene',
      actIndex: widget.actIndex,
      sceneIndex: widget.sceneIndex,
    );
    if (picked != null && mounted) {
      widget.actions.onSceneOverrideChanged(
        widget.actIndex,
        widget.sceneIndex,
        picked,
      );
      _refresh();
    }
  }

  Widget _buildFramesTab(
    SceneDraft scene,
    List<FrameDraft> frames,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          SceneEditorSection(
            scene: scene,
            sceneIndex: widget.sceneIndex,
            actIndex: widget.actIndex,
            draft: _draft,
            onChanged: _refresh,
            canRemove: widget.actions.canRemoveScene(
              widget.actIndex,
              widget.sceneIndex,
            ),
            onRemove: () => widget.actions
                .onRemoveScene(widget.actIndex, widget.sceneIndex)
                .then((_) {
              if (mounted) Navigator.of(context).pop();
            }),
            frames: frames,
            onPickFrames: _pickFrames,
            onRemoveFrame: (frameIndex) => widget.actions
                .onRemoveFrame(
                  widget.actIndex,
                  widget.sceneIndex,
                  frameIndex,
                )
                .then((_) => _refresh()),
            onCaptionChanged: (frameIndex, value) {
              widget.actions.onCaptionChanged(
                widget.actIndex,
                widget.sceneIndex,
                frameIndex,
                value,
              );
            },
            onActionNoteChanged: (frameIndex, value) {
              widget.actions.onActionNoteChanged(
                widget.actIndex,
                widget.sceneIndex,
                frameIndex,
                value,
              );
            },
            onSceneOverrideChanged: (override) {
              widget.actions.onSceneOverrideChanged(
                widget.actIndex,
                widget.sceneIndex,
                override,
              );
              _refresh();
            },
            onFrameOverrideChanged: (frameIndex, override) {
              widget.actions.onFrameOverrideChanged(
                widget.actIndex,
                widget.sceneIndex,
                frameIndex,
                override,
              );
              _refresh();
            },
            expanded: true,
            onToggleExpanded: () {},
            isFrameExpanded: _isFrameExpanded,
            onToggleFrame: _toggleFrame,
            onMoveFrame: (data, insertIndex) {
              widget.actions.onMoveFrame(
                data,
                widget.actIndex,
                scene,
                insertIndex,
              );
              _refresh();
            },
            poolTags: widget.actions.poolTags,
            onToggleSceneTag: (tag) {
              widget.actions.onToggleSceneTag(
                widget.actIndex,
                widget.sceneIndex,
                tag,
              );
              _refresh();
            },
            onToggleFrameTag: (frameIndex, tag) {
              widget.actions.onToggleFrameTag(
                widget.actIndex,
                widget.sceneIndex,
                frameIndex,
                tag,
              );
              _refresh();
            },
            onOpenFrameDetail: _openFrameDetail,
          ),
        ],
      );
    }

    if (frames.isEmpty) {
      return EmptyStateView(
        icon: Icons.photo_library_outlined,
        title: '暂无画面',
        subtitle: '点击下方添加画面',
        actionLabel: '添加画面',
        onAction: _pickFrames,
      );
    }

    return SceneFrameListView(
      frames: frames,
      actIndex: widget.actIndex,
      sceneIndex: widget.sceneIndex,
      onFrameTap: _openFrameDetail,
      onBatchEdit: _openBatchEdit,
      bottomPadding: 128,
    );
  }

  Widget _buildStoryboardTab(
    SceneDraft scene,
    List<FrameDraft> frames,
    bool isDesktop,
  ) {
    final previewFrames = draftFramesForScene(
      _draft,
      widget.actIndex,
      widget.sceneIndex,
    );
    if (previewFrames.isEmpty) {
      return const EmptyStateView(
        icon: Icons.grid_view_outlined,
        title: '暂无画面',
        subtitle: '在画面列表中添加分镜图',
      );
    }
    final paths = previewFrames.map((f) => f.effectiveDisplayPath).toList();
    final captions = previewFrames.map((f) => f.caption).toList();
    final labels = [
      for (var i = 0; i < frames.length; i++)
        '${widget.actIndex + 1}-${widget.sceneIndex + 1}-${i + 1}',
    ];
    return EditorStoryboardPanel(
      title: '$_sceneTitle（${frames.length}画）',
      frames: previewFrames,
      galleryPaths: paths,
      galleryCaptions: captions,
      shotLabels: labels,
      frameSources: frames,
      onFrameTap: _openFrameDetail,
      onBatchEdit: _openBatchEdit,
      onAddFrame: _pickFrames,
      showBottomBar: !isDesktop,
    );
  }
}

class _SceneLibraryBanner extends StatelessWidget {
  const _SceneLibraryBanner({
    required this.scene,
    required this.draft,
    required this.onChanged,
  });

  final SceneDraft scene;
  final ScreenplayDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final bound = scene.sceneLibraryId != null &&
        scene.sceneLibraryTitle.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: const Icon(Icons.landscape_outlined),
          title: Text(bound ? scene.sceneLibraryTitle : '未绑定场景库'),
          subtitle: bound
              ? Text(
                  scene.location.trim().isEmpty
                      ? '已关联场景资产'
                      : scene.location,
                )
              : const Text('从场景库选择可自动填充地点与拍摄建议'),
          trailing: TextButton(
            onPressed: () async {
              final picked = await ScenePickerSheet.show(
                context,
                selectedSceneId: scene.sceneLibraryId,
              );
              if (picked == null || !context.mounted) return;
              applyLibrarySceneToSceneDraft(picked, scene, draft);
              onChanged();
            },
            child: Text(bound ? '更换' : '选择'),
          ),
        ),
      ),
    );
  }
}
