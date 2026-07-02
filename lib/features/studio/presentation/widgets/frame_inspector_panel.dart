import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../character/data/character_repository.dart';
import '../../../lighting/domain/lighting_scheme.dart';
import '../../../lighting/data/lighting_draft_binding.dart';
import '../../../lighting/presentation/utils/lighting_navigation.dart';
import '../../../lighting/presentation/widgets/lighting_picker_sheet.dart';
import '../../../scene/presentation/widgets/scene_picker_sheet.dart';
import '../../../screenplay/data/screenplay_scene_binding.dart';
import '../../../upload/presentation/widgets/editor/screenplay_characters_section.dart';
import '../../../upload/presentation/widgets/editor/screenplay_scenes_section.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../screenplay/data/frame_generation_repository.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/shoot_params_draft.dart';
import '../../../screenplay/domain/ai_prompt_builder.dart';
import '../../../upload/presentation/widgets/editor/editor_read_only_info_card.dart';
import '../../../upload/presentation/widgets/frame_editor/frame_camera_params_grid.dart';
import '../../../upload/presentation/widgets/frame_editor/frame_generation_actions.dart';
import '../../../upload/presentation/widgets/frame_editor/frame_prompt_section.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_actions.dart';
import '../../domain/script_editor_selection.dart';
import '../../../../shared/widgets/pose_cover_image.dart';

class FrameInspectorPanel extends StatefulWidget {
  const FrameInspectorPanel({
    super.key,
    required this.actions,
    required this.selection,
    required this.onChanged,
    this.showHeader = true,
  });

  final ScriptEditorActions actions;
  final ScriptEditorSelection selection;
  final VoidCallback onChanged;
  final bool showHeader;

  @override
  State<FrameInspectorPanel> createState() => _FrameInspectorPanelState();
}

class _FrameInspectorPanelState extends State<FrameInspectorPanel> {
  static const _tabs = ['镜头设置', 'AI 生成'];
  int _tabIndex = 0;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.selection.hasFrame) {
      if (widget.selection.hasScene) {
        return _SceneInspector(
          actions: widget.actions,
          actIndex: widget.selection.actIndex!,
          sceneIndex: widget.selection.sceneIndex!,
          selection: widget.selection,
          onChanged: widget.onChanged,
        );
      }
      return ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          ScreenplayCharactersSection(
            draft: widget.actions.draft,
            onChanged: widget.onChanged,
            selection: widget.selection,
            actions: widget.actions,
          ),
          const SizedBox(height: 16),
          const EmptyStateView(
            icon: Icons.tune_outlined,
            title: '选择分镜以编辑',
            subtitle: '在左侧结构树或中间分镜列表中选择一个画面',
          ),
        ],
      );
    }

    final actIndex = widget.selection.actIndex!;
    final sceneIndex = widget.selection.sceneIndex!;
    final frameIndex = widget.selection.frameIndex!;
    final frame = widget.actions.draft.acts[actIndex].scenes[sceneIndex]
        .frames[frameIndex];
    final scene =
        widget.actions.draft.acts[actIndex].scenes[sceneIndex];
    final shotLabel =
        '${actIndex + 1}-${sceneIndex + 1}-${frameIndex + 1}';

    final padding = widget.showHeader ? 16.0 : 12.0;

    return Column(
      key: ValueKey('inspector-$actIndex-$sceneIndex-$frameIndex'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
            child: Text(
              '画面 $shotLabel',
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: DetailTabBar(
            tabs: _tabs,
            selectedIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
        SizedBox(height: padding),
        Expanded(
          child: FadeSlideIndexedStack(
            index: _tabIndex,
            children: [
              ListView(
                padding: EdgeInsets.all(padding),
                children: [
                  TextFormField(
                    initialValue: frame.caption,
                    decoration: const InputDecoration(
                      labelText: '标题',
                      isDense: true,
                    ),
                    onChanged: (v) {
                      widget.actions.onCaptionChanged(
                        actIndex,
                        sceneIndex,
                        frameIndex,
                        v,
                      );
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: frame.actionNote,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '描述',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (v) {
                      widget.actions.onActionNoteChanged(
                        actIndex,
                        sceneIndex,
                        frameIndex,
                        v,
                      );
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: ValueKey(
                      'duration-$actIndex-$sceneIndex-$frameIndex',
                    ),
                    initialValue: '${frame.cineParams.durationSec}',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '时长（秒）',
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final sec = int.tryParse(v.trim());
                      if (sec == null || sec < 1) return;
                      widget.actions.onCineParamsChanged(
                        actIndex,
                        sceneIndex,
                        frameIndex,
                        frame.cineParams.copyWith(durationSec: sec),
                      );
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  FrameCameraParamsGrid(
                    params: frame.cineParams,
                    onChanged: (params) {
                      widget.actions.onCineParamsChanged(
                        actIndex,
                        sceneIndex,
                        frameIndex,
                        params,
                      );
                      widget.onChanged();
                    },
                  ),
                  const SizedBox(height: 16),
                  _LightingSchemeSection(
                    frame: frame,
                    actIndex: actIndex,
                    sceneIndex: sceneIndex,
                    frameIndex: frameIndex,
                    draft: widget.actions.draft,
                    onChanged: () {
                      widget.onChanged();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _SceneFieldsSection(
                    scene: scene,
                    actIndex: actIndex,
                    sceneIndex: sceneIndex,
                    actions: widget.actions,
                    onChanged: widget.onChanged,
                  ),
                  const SizedBox(height: 16),
                  _CharacterSection(
                    characterId: frame.characterId,
                    characterName: frame.characterName,
                    characterNote: frame.characterNote,
                    onPickCharacter: () async {
                      final picked = await pickAndLinkScreenplayCharacter(
                        context,
                        draft: widget.actions.draft,
                        selectedCharacterId: frame.characterId,
                      );
                      if (!context.mounted) return;
                      if (picked == null) {
                        frame.characterId = null;
                        frame.characterName = '';
                      } else {
                        frame.characterId = picked.id;
                        frame.characterName = picked.name;
                        if (frame.characterNote.trim().isEmpty &&
                            picked.appearance.isNotEmpty) {
                          frame.characterNote = picked.appearance;
                        }
                      }
                      widget.onChanged();
                      setState(() {});
                    },
                    onClearCharacter: () {
                      frame.characterId = null;
                      frame.characterName = '';
                      widget.onChanged();
                      setState(() {});
                    },
                    onNoteChanged: (v) {
                      frame.characterNote = v;
                      widget.onChanged();
                    },
                    onCreateCharacter: () async {
                      final createdId =
                          await context.push<int?>(AppRoutes.characterCreate);
                      if (!context.mounted || createdId == null) return;
                      final result = await CharacterRepository.instance
                          .fetchDetail(createdId);
                      final entry = result.character;
                      if (entry == null) return;
                      frame.characterId = entry.id;
                      frame.characterName = entry.name;
                      if (frame.characterNote.trim().isEmpty &&
                          entry.appearance.isNotEmpty) {
                        frame.characterNote = entry.appearance;
                      }
                      ensureDraftCharacterLinked(
                        widget.actions.draft,
                        id: entry.id,
                        name: entry.name,
                      );
                      widget.onChanged();
                      setState(() {});
                    },
                  ),
                ],
              ),
              ListView(
                padding: EdgeInsets.all(padding),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('提示词', style: AppTextStyles.label),
                      ),
                      TextButton(
                        onPressed: () {
                          final shootParams = effectiveParamsForFrame(
                            widget.actions.draft,
                            actIndex,
                            sceneIndex,
                            frameIndex,
                          );
                          frame.positivePrompt = AiPromptBuilder.buildPositive(
                            frame: frame,
                            scene: scene,
                            shootParams: shootParams,
                          );
                          if (frame.negativePrompt.trim().isEmpty) {
                            frame.negativePrompt =
                                AiPromptBuilder.defaultNegativePrompt;
                          }
                          widget.onChanged();
                          setState(() {});
                        },
                        child: const Text('从参数生成'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FramePromptSection(
                    positivePrompt: frame.positivePrompt,
                    negativePrompt: frame.negativePrompt,
                    onPositiveChanged: (v) {
                      widget.actions.onPositivePromptChanged(
                        actIndex,
                        sceneIndex,
                        frameIndex,
                        v,
                      );
                    },
                    onNegativeChanged: (v) {
                      widget.actions.onNegativePromptChanged(
                        actIndex,
                        sceneIndex,
                        frameIndex,
                        v,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _ReferenceImagesSection(
                    frame: frame,
                    onAdd: () async {
                      final result = await FrameGenerationRepository.instance
                          .addReferenceImage(frame: frame);
                      if (result.error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.error!)),
                        );
                      } else {
                        widget.onChanged();
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FrameGenerationActions(
                    isLoading: _isGenerating,
                    onGenerateImage: () => _generateImage(
                      actIndex,
                      sceneIndex,
                      frameIndex,
                    ),
                    onGenerateVideo: () async {
                      final msg = await FrameGenerationRepository.instance
                          .generateVideoForFrame();
                      if (context.mounted && msg != null) {
                        context.push(AppRoutes.comingSoon('生成视频'));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _generateImage(
    int actIndex,
    int sceneIndex,
    int frameIndex,
  ) async {
    setState(() => _isGenerating = true);
    final result = await FrameGenerationRepository.instance
        .generateImageForFrame(
      draft: widget.actions.draft,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: frameIndex,
    );
    if (!mounted) return;
    setState(() => _isGenerating = false);
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    widget.onChanged();
    setState(() {});
  }
}

class _SceneInspector extends StatelessWidget {
  const _SceneInspector({
    required this.actions,
    required this.actIndex,
    required this.sceneIndex,
    required this.selection,
    required this.onChanged,
  });

  final ScriptEditorActions actions;
  final int actIndex;
  final int sceneIndex;
  final ScriptEditorSelection selection;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scene = actions.draft.acts[actIndex].scenes[sceneIndex];
    final sceneTitle = scene.title.trim().isEmpty
        ? '第${sceneIndex + 1}场'
        : scene.title.trim();

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        Text('场次信息', style: AppTextStyles.title.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        EditorReadOnlyInfoCard(
          title: sceneTitle,
          fields: [
            EditorInfoField(
              label: '画面数',
              value: '${scene.frames.length} 画',
            ),
            EditorInfoField(
              label: '地点',
              value: scene.location.trim().isEmpty ? '未设置' : scene.location,
            ),
            EditorInfoField(
              label: '时间',
              value:
                  scene.timeOfDay.trim().isEmpty ? '未设置' : scene.timeOfDay,
            ),
            EditorInfoField(
              label: '天气',
              value: scene.weather.trim().isEmpty ? '未设置' : scene.weather,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SceneFieldsSection(
          scene: scene,
          actIndex: actIndex,
          sceneIndex: sceneIndex,
          actions: actions,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        ScreenplayCharactersSection(
          draft: actions.draft,
          onChanged: onChanged,
          selection: selection,
          actions: actions,
          compact: true,
        ),
        const SizedBox(height: 16),
        ScreenplayScenesSection(
          draft: actions.draft,
          onChanged: onChanged,
          selection: selection,
          actions: actions,
          compact: true,
        ),
        const SizedBox(height: 16),
        Text(
          '选择具体分镜以编辑镜头参数与 AI 生成',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}

class _SceneFieldsSection extends StatelessWidget {
  const _SceneFieldsSection({
    required this.scene,
    required this.actIndex,
    required this.sceneIndex,
    required this.actions,
    required this.onChanged,
  });

  final SceneDraft scene;
  final int actIndex;
  final int sceneIndex;
  final ScriptEditorActions actions;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('场次信息', style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: scene.title,
          decoration: const InputDecoration(
            labelText: '场次名称',
            isDense: true,
          ),
          onChanged: (v) {
            actions.onSceneFieldChanged?.call(
              actIndex,
              sceneIndex,
              title: v,
            );
            onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: scene.location,
          decoration: const InputDecoration(
            labelText: '地点',
            isDense: true,
          ),
          onChanged: (v) {
            actions.onSceneFieldChanged?.call(
              actIndex,
              sceneIndex,
              location: v,
            );
            onChanged();
          },
        ),
        const SizedBox(height: 8),
        if (scene.sceneLibraryId != null &&
            scene.sceneLibraryTitle.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '场景库：${scene.sceneLibraryTitle}',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await ScenePickerSheet.show(
                      context,
                      selectedSceneId: scene.sceneLibraryId,
                    );
                    if (picked == null || !context.mounted) return;
                    applyLibrarySceneToSceneDraft(
                      picked,
                      scene,
                      actions.draft,
                    );
                    onChanged();
                  },
                  child: const Text('更换场景'),
                ),
              ],
            ),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                final picked = await ScenePickerSheet.show(context);
                if (picked == null || !context.mounted) return;
                applyLibrarySceneToSceneDraft(
                  picked,
                  scene,
                  actions.draft,
                );
                onChanged();
              },
              icon: const Icon(Icons.landscape_outlined, size: 18),
              label: const Text('从场景库选择'),
            ),
          ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: scene.timeOfDay,
          decoration: const InputDecoration(
            labelText: '时间',
            isDense: true,
          ),
          onChanged: (v) {
            actions.onSceneFieldChanged?.call(
              actIndex,
              sceneIndex,
              timeOfDay: v,
            );
            onChanged();
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: scene.weather.trim().isEmpty ? null : scene.weather,
          decoration: const InputDecoration(
            labelText: '天气',
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('未设置')),
            ...AppCatalog.weatherPresets.map(
              (w) => DropdownMenuItem(value: w, child: Text(w)),
            ),
          ],
          onChanged: (v) {
            actions.onSceneFieldChanged?.call(
              actIndex,
              sceneIndex,
              weather: v ?? '',
            );
            onChanged();
          },
        ),
      ],
    );
  }
}

class _CharacterSection extends StatelessWidget {
  const _CharacterSection({
    required this.characterId,
    required this.characterName,
    required this.characterNote,
    required this.onPickCharacter,
    required this.onClearCharacter,
    required this.onNoteChanged,
    this.onCreateCharacter,
  });

  final int? characterId;
  final String characterName;
  final String characterNote;
  final VoidCallback onPickCharacter;
  final VoidCallback onClearCharacter;
  final ValueChanged<String> onNoteChanged;
  final Future<void> Function()? onCreateCharacter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('角色信息', style: AppTextStyles.label),
          if (characterId != null && characterName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    characterName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.characterDetailPath(characterId!)),
                  child: const Text('Wiki'),
                ),
                IconButton(
                  tooltip: '解除绑定',
                  onPressed: onClearCharacter,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('character-$characterNote-$characterId'),
            initialValue: characterNote,
            decoration: const InputDecoration(
              labelText: '角色描述',
              hintText: '分镜级外观 override，如：黑色长发、蓝色雨衣',
              isDense: true,
            ),
            onChanged: onNoteChanged,
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.library),
                child: const Text('素材库'),
              ),
              OutlinedButton(
                onPressed: onPickCharacter,
                child: Text(characterId == null ? '选择角色' : '更换角色'),
              ),
              if (onCreateCharacter != null)
                OutlinedButton(
                  onPressed: onCreateCharacter,
                  child: const Text('新建角色'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LightingSchemeSection extends StatelessWidget {
  const _LightingSchemeSection({
    required this.frame,
    required this.actIndex,
    required this.sceneIndex,
    required this.frameIndex,
    required this.draft,
    required this.onChanged,
  });

  final FrameDraft frame;
  final int actIndex;
  final int sceneIndex;
  final int frameIndex;
  final ScreenplayDraft draft;
  final VoidCallback onChanged;

  String get _label {
    final rig = lightingSchemeFromDraftFrame(frame);
    if (rig != null) return rig.displaySummary;
    final params = effectiveParamsForFrame(
      draft,
      actIndex,
      sceneIndex,
      frameIndex,
    );
    return params.lighting?.trim().isNotEmpty == true
        ? params.lighting!
        : '未设置';
  }

  Future<void> _applyScheme(BuildContext context, LightingScheme scheme) async {
    applyLightingSchemeToDraft(
      draft,
      scheme,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: frameIndex,
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('灯光方案', style: AppTextStyles.label),
            ),
            TextButton(
              onPressed: () async {
                final scheme = await LightingPickerSheet.show(context);
                if (scheme == null || !context.mounted) return;
                await _applyScheme(context, scheme);
              },
              child: const Text('快速选择'),
            ),
            TextButton(
              onPressed: () async {
                final scheme = await openLightingHub(
                  context,
                  schemeId: frame.lightingSchemeId,
                  characterId: frame.characterId,
                  scope: 'apply',
                  actIndex: actIndex,
                  sceneIndex: sceneIndex,
                  frameIndex: frameIndex,
                );
                if (scheme == null || !context.mounted) return;
                await _applyScheme(context, scheme);
              },
              child: const Text('灯光库'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(_label, style: AppTextStyles.bodySecondary),
      ],
    );
  }
}

class _ReferenceImagesSection extends StatelessWidget {
  const _ReferenceImagesSection({
    required this.frame,
    required this.onAdd,
  });

  final FrameDraft frame;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('参考图', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final img in frame.referenceImages)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: PoseCoverImage(
                    imagePath: img.displayPath,
                    expand: true,
                  ),
                ),
              ),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: const Icon(Icons.add, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
