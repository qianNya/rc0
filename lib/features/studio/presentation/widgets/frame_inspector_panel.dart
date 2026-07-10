import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rc0_core/rc0_core.dart';

import '../../../../app/module_registry.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../character/data/character_repository.dart';
import '../../../character/domain/character_detail_data.dart';
import '../../../screenplay/data/frame_generation_repository.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/shoot_params_draft.dart';
import '../../../screenplay/domain/ai_prompt_builder.dart';
import '../../../upload/presentation/widgets/editor/editor_read_only_info_card.dart';
import '../../../upload/presentation/widgets/editor/screenplay_characters_section.dart';
import '../../../upload/presentation/widgets/editor/screenplay_scenes_section.dart';
import '../../../upload/presentation/widgets/frame_editor/frame_camera_params_grid.dart';
import '../../../upload/presentation/widgets/frame_editor/frame_generation_actions.dart';
import '../../../upload/presentation/widgets/frame_editor/frame_prompt_section.dart';
import '../../../upload/presentation/widgets/script_editor/script_editor_actions.dart';
import '../../domain/script_editor_selection.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/glass/glass.dart';

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
            remoteScreenplayId: widget.actions.remoteScreenplayId,
          ),
          const SizedBox(height: 16),
          const GlassEmptyState(
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
                    target: FrameBindingTarget(
                      draft: widget.actions.draft,
                      actIndex: actIndex,
                      sceneIndex: sceneIndex,
                      frameIndex: frameIndex,
                    ),
                    onChanged: () {
                      widget.onChanged();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _CineSetupSection(
                    target: FrameBindingTarget(
                      draft: widget.actions.draft,
                      actIndex: actIndex,
                      sceneIndex: sceneIndex,
                      frameIndex: frameIndex,
                    ),
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
                    costumeId: frame.costumeId,
                    propIds: frame.propIds,
                    onPickCharacter: () async {
                      final target = FrameBindingTarget(
                        draft: widget.actions.draft,
                        actIndex: actIndex,
                        sceneIndex: sceneIndex,
                        frameIndex: frameIndex,
                      );
                      final picked = await AppModuleRegistry.instance
                          .port<CharacterBindingPort>()
                          .pickAndApplyCharacter(
                            context,
                            target,
                            selectedCharacterId: frame.characterId,
                          );
                      if (!context.mounted) return;
                      if (picked == null) {
                        frame.characterId = null;
                        frame.characterName = '';
                        frame.costumeId = null;
                        frame.propIds = [];
                      } else {
                        frame.characterId = picked.id;
                        frame.characterName = picked.name ?? '';
                        frame.costumeId = picked.defaultCostumeId;
                        if (frame.characterNote.trim().isEmpty &&
                            (picked.appearance?.isNotEmpty ?? false)) {
                          frame.characterNote = picked.appearance!;
                        }
                      }
                      widget.onChanged();
                      setState(() {});
                    },
                    onClearCharacter: () {
                      frame.characterId = null;
                      frame.characterName = '';
                      frame.costumeId = null;
                      frame.propIds = [];
                      widget.onChanged();
                      setState(() {});
                    },
                    onNoteChanged: (v) {
                      frame.characterNote = v;
                      widget.onChanged();
                    },
                    onCostumeChanged: (id) {
                      frame.costumeId = id;
                      widget.onChanged();
                      setState(() {});
                    },
                    onPropIdsChanged: (ids) {
                      frame.propIds = ids;
                      widget.onChanged();
                      setState(() {});
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
                      frame.costumeId = null;
                      frame.propIds = [];
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
                        onPressed: () async {
                          final shootParams = effectiveParamsForFrame(
                            widget.actions.draft,
                            actIndex,
                            sceneIndex,
                            frameIndex,
                          );
                          String? appearance;
                          String? stylePrompt;
                          String? negativeStyle;
                          final propNames = <String>[];
                          final characterId = frame.characterId;
                          if (characterId != null) {
                            final detail = await CharacterRepository.instance
                                .fetchDetail(characterId);
                            final entry = detail.character;
                            if (entry != null) {
                              appearance = entry.appearance;
                              if (entry.style.promptFragment.isNotEmpty) {
                                stylePrompt = entry.style.promptFragment;
                              }
                              if (entry.style.negativeFragment.isNotEmpty) {
                                negativeStyle = entry.style.negativeFragment;
                              }
                            }
                            final costumes = await CharacterRepository.instance
                                .listCostumes(characterId);
                            for (final c in costumes.items) {
                              if (c.id == frame.costumeId &&
                                  c.description.isNotEmpty) {
                                appearance = c.description;
                                break;
                              }
                            }
                            if (frame.propIds.isNotEmpty) {
                              final props = await CharacterRepository.instance
                                  .listProps(characterId);
                              for (final id in frame.propIds) {
                                for (final p in props.items) {
                                  if (p.id == id) propNames.add(p.name);
                                }
                              }
                            }
                          }
                          if (!mounted) return;
                          frame.positivePrompt = AiPromptBuilder.buildPositive(
                            frame: frame,
                            scene: scene,
                            shootParams: shootParams,
                            characterAppearance: appearance,
                            characterStylePrompt: stylePrompt,
                            propNames: propNames,
                          );
                          if (frame.negativePrompt.trim().isEmpty) {
                            frame.negativePrompt =
                                AiPromptBuilder.buildNegative(
                              existing: negativeStyle,
                            );
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
                        context.push(AppRoutes.labsFeature('gen_video'));
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
          remoteScreenplayId: actions.remoteScreenplayId,
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
                    final target = FrameBindingTarget(
                      draft: actions.draft,
                      actIndex: actIndex,
                      sceneIndex: sceneIndex,
                    );
                    final applied = await AppModuleRegistry.instance
                        .port<SceneBindingPort>()
                        .pickAndApplyLibraryScene(
                          context,
                          target,
                          selectedSceneId: scene.sceneLibraryId,
                        );
                    if (!applied || !context.mounted) return;
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
                final target = FrameBindingTarget(
                  draft: actions.draft,
                  actIndex: actIndex,
                  sceneIndex: sceneIndex,
                );
                final applied = await AppModuleRegistry.instance
                    .port<SceneBindingPort>()
                    .pickAndApplyLibraryScene(context, target);
                if (!applied || !context.mounted) return;
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

class _CharacterSection extends StatefulWidget {
  const _CharacterSection({
    required this.characterId,
    required this.characterName,
    required this.characterNote,
    required this.costumeId,
    required this.propIds,
    required this.onPickCharacter,
    required this.onClearCharacter,
    required this.onNoteChanged,
    required this.onCostumeChanged,
    required this.onPropIdsChanged,
    this.onCreateCharacter,
  });

  final int? characterId;
  final String characterName;
  final String characterNote;
  final int? costumeId;
  final List<int> propIds;
  final VoidCallback onPickCharacter;
  final VoidCallback onClearCharacter;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<int?> onCostumeChanged;
  final ValueChanged<List<int>> onPropIdsChanged;
  final Future<void> Function()? onCreateCharacter;

  @override
  State<_CharacterSection> createState() => _CharacterSectionState();
}

class _CharacterSectionState extends State<_CharacterSection> {
  List<CharacterCostumeItem> _costumes = const [];
  List<CharacterPropItem> _props = const [];
  bool _loadingExtras = false;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  @override
  void didUpdateWidget(covariant _CharacterSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.characterId != widget.characterId) {
      _loadExtras();
    }
  }

  Future<void> _loadExtras() async {
    final id = widget.characterId;
    if (id == null) {
      setState(() {
        _costumes = const [];
        _props = const [];
      });
      return;
    }
    setState(() => _loadingExtras = true);
    final costumes = await CharacterRepository.instance.listCostumes(id);
    final props = await CharacterRepository.instance.listProps(id);
    if (!mounted) return;
    setState(() {
      _costumes = costumes.items;
      _props = props.items;
      _loadingExtras = false;
    });
  }

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
          if (widget.characterId != null &&
              widget.characterName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.characterName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(
                    AppRoutes.characterDetailPath(widget.characterId!),
                  ),
                  child: const Text('Wiki'),
                ),
                IconButton(
                  tooltip: '解除绑定',
                  onPressed: widget.onClearCharacter,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ],
          if (widget.characterId != null) ...[
            const SizedBox(height: 8),
            if (_loadingExtras)
              const LinearProgressIndicator(minHeight: 2)
            else ...[
              DropdownButtonFormField<int?>(
                initialValue: widget.costumeId,
                decoration: const InputDecoration(
                  labelText: '服装',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('默认外观'),
                  ),
                  for (final c in _costumes)
                    DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.isDefault ? '${c.name}（默认）' : c.name),
                    ),
                ],
                onChanged: widget.onCostumeChanged,
              ),
              if (_props.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('道具', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in _props)
                      FilterChip(
                        label: Text(p.name),
                        selected: widget.propIds.contains(p.id),
                        onSelected: (selected) {
                          final next = List<int>.from(widget.propIds);
                          if (selected) {
                            if (!next.contains(p.id)) next.add(p.id);
                          } else {
                            next.remove(p.id);
                          }
                          widget.onPropIdsChanged(next);
                        },
                      ),
                  ],
                ),
              ],
            ],
          ],
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey(
              'character-${widget.characterNote}-${widget.characterId}',
            ),
            initialValue: widget.characterNote,
            decoration: const InputDecoration(
              labelText: '角色描述',
              hintText: '分镜级外观 override，如：黑色长发、蓝色雨衣',
              isDense: true,
            ),
            onChanged: widget.onNoteChanged,
          ),
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
                onPressed: widget.onPickCharacter,
                child: Text(
                  widget.characterId == null ? '选择角色' : '更换角色',
                ),
              ),
              if (widget.onCreateCharacter != null)
                OutlinedButton(
                  onPressed: widget.onCreateCharacter,
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
    required this.target,
    required this.onChanged,
  });

  final FrameBindingTarget target;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final port = AppModuleRegistry.instance.port<LightingBindingPort>();
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
                if (await port.pickQuick(context, target)) onChanged();
              },
              child: const Text('快速选择'),
            ),
            TextButton(
              onPressed: () async {
                final draft = target.draft as ScreenplayDraft;
                final frame = draft.acts[target.actIndex]
                    .scenes[target.sceneIndex].frames[target.frameIndex!];
                if (await port.pickFromHub(
                  context,
                  target,
                  characterId: frame.characterId,
                  schemeId: frame.lightingSchemeId,
                )) {
                  onChanged();
                }
              },
              child: const Text('灯光库'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(port.displayLabel(target), style: AppTextStyles.bodySecondary),
      ],
    );
  }
}

class _CineSetupSection extends StatelessWidget {
  const _CineSetupSection({
    required this.target,
    required this.onChanged,
  });

  final FrameBindingTarget target;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final port = AppModuleRegistry.instance.port<CameraBindingPort>();
    final draft = target.draft as ScreenplayDraft;
    final frame = draft.acts[target.actIndex].scenes[target.sceneIndex]
        .frames[target.frameIndex!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('摄影机组合', style: AppTextStyles.label),
            ),
            TextButton(
              onPressed: () async {
                if (await port.pickQuick(context, target)) onChanged();
              },
              child: const Text('快速选择'),
            ),
            TextButton(
              onPressed: () async {
                if (await port.pickControlSheet(context, target)) onChanged();
              },
              child: const Text('摄影机控制'),
            ),
            TextButton(
              onPressed: () async {
                if (await port.pickFromHub(
                  context,
                  target,
                  setupId: frame.cineSetupId,
                )) {
                  onChanged();
                }
              },
              child: const Text('设备库'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(port.displayLabel(target), style: AppTextStyles.bodySecondary),
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
