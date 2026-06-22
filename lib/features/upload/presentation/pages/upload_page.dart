import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/tag_editor.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/data/screenplay_publish_service.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/image_pick_service.dart';
import '../widgets/screenplay_editor_sections.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, this.editScriptId});

  final String? editScriptId;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _imagePickService = ImagePickService();
  late final ScreenplayDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  Screenplay? _editingScript;
  bool _isPicking = false;
  bool _isPublishing = false;

  bool get _isEditing =>
      widget.editScriptId != null && widget.editScriptId!.isNotEmpty;

  bool get _isPublished => _editingScript?.isPublished ?? false;

  int get _frameCount => countDraftFrames(_draft);

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _editingScript =
          ScreenplayLocalRepository.instance.findById(widget.editScriptId!);
      _draft = _editingScript != null
          ? ScreenplayDraft.fromScreenplay(_editingScript!)
          : ScreenplayDraft();
    } else {
      _draft = ScreenplayDraft();
    }
    _titleController = TextEditingController(text: _draft.title);
    _synopsisController = TextEditingController(text: _draft.synopsis);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _resetDraft() {
    _draft.title = '';
    _draft.synopsis = '';
    _draft.tags
      ..clear()
      ..add('站姿');
    _draft.acts
      ..clear()
      ..add(ActDraft());
    _titleController.text = '';
    _synopsisController.text = '';
  }

  void _onCancel() {
    if (_isEditing) {
      context.go(AppRoutes.script(widget.editScriptId!));
    } else {
      _resetDraft();
      context.go(AppRoutes.explore);
    }
  }

  Future<void> _pickImages(FramePickTarget target) async {
    if (_isPicking) return;

    setState(() => _isPicking = true);
    try {
      final result = await _imagePickService.pickImages();
      if (!mounted) return;

      if (result.added.isNotEmpty) {
        addImagesToScene(_draft, target, result.added);
        _refresh();
      }
      if (result.hasRejected) {
        _showSnackBar('部分文件格式不支持，已忽略');
      }
    } catch (error) {
      if (mounted) _showSnackBar('选择文件失败：$error');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onPublish({bool goHome = true}) async {
    _draft.title = _titleController.text;
    _draft.synopsis = _synopsisController.text;

    if (!_draft.hasFrames) {
      _showSnackBar('请至少添加一张画（分镜图）');
      return;
    }

    setState(() => _isPublishing = true);
    try {
      final repository = ScreenplayLocalRepository.instance;
      if (_isEditing) {
        await repository.update(widget.editScriptId!, _draft);
        if (!mounted) return;

        if (_isPublished) {
          if (!AuthRepository.instance.isLoggedIn) {
            _showSnackBar('本地已保存，请先登录后再同步');
            if (goHome) context.go(AppRoutes.script(widget.editScriptId!));
            return;
          }
          final doc = repository.documentById(widget.editScriptId!);
          if (doc != null) {
            final sync = await ScreenplayPublishService.instance.syncToServer(
              document: doc,
            );
            if (!mounted) return;
            if (sync.error != null) {
              _showSnackBar('本地已保存，同步失败：${sync.error}');
              if (goHome) context.go(AppRoutes.script(widget.editScriptId!));
              return;
            }
            await repository.updateDocument(sync.result!.document);
            if (!mounted) return;
            _showSnackBar('剧本已保存并同步');
          } else {
            _showSnackBar('剧本已保存');
          }
        } else {
          _showSnackBar('剧本已保存');
        }

        if (goHome) context.go(AppRoutes.script(widget.editScriptId!));
      } else {
        await repository.publish(_draft);
        if (!mounted) return;
        _showSnackBar('剧本发布成功，已保存到本地');
        if (goHome) context.go(AppRoutes.explore);
      }
    } catch (error) {
      if (mounted) _showSnackBar('保存失败：$error');
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _addAct() {
    _draft.acts.add(ActDraft());
    _refresh();
  }

  Future<void> _removeAct(int index) async {
    if (_draft.acts.length <= 1) return;
    _draft.acts.removeAt(index);
    _refresh();
  }

  void _addScene(int actIndex) {
    _draft.acts[actIndex].scenes.add(SceneDraft());
    _refresh();
  }

  Future<void> _removeScene(int actIndex, int sceneIndex) async {
    if (_draft.acts[actIndex].scenes.length <= 1) return;
    _draft.acts[actIndex].scenes.removeAt(sceneIndex);
    _refresh();
  }

  Future<void> _removeFrame(
    int actIndex,
    int sceneIndex,
    int frameIndex,
  ) async {
    final scene = _draft.acts[actIndex].scenes[sceneIndex];
    if (scene.frames.length <= 1 && _isPublished) return;

    scene.frames.removeAt(frameIndex);
    _refresh();
  }

  Widget _buildScreenplayForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('剧本', style: AppTextStyles.title),
        const SizedBox(height: 12),
        const Text('标题', style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(hintText: '给这部剧本起个名字…'),
        ),
        const SizedBox(height: 12),
        const Text('梗概', style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: _synopsisController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '剧本整体说明…'),
        ),
        const SizedBox(height: 12),
        TagEditor(
          suggestedTags: AppCatalog.suggestedUploadTags,
          selectedTags: _draft.tags,
          onToggle: (tag) {
            setState(() {
              if (_draft.tags.contains(tag)) {
                if (_draft.tags.length > 1) _draft.tags.remove(tag);
              } else {
                _draft.tags.add(tag);
              }
            });
          },
          onAdd: (tag) => setState(() => _draft.tags.add(tag)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text('幕 · 场 · 画', style: AppTextStyles.title),
            const Spacer(),
            Text(
              '已选 $_frameCount 画',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var actIndex = 0; actIndex < _draft.acts.length; actIndex++)
          ActEditorSection(
            act: _draft.acts[actIndex],
            actIndex: actIndex,
            onChanged: _refresh,
            canRemove: _draft.acts.length > 1,
            onRemove: () => _removeAct(actIndex),
            onAddScene: () => _addScene(actIndex),
            sceneBuilder: (sceneIndex) {
              final scene = _draft.acts[actIndex].scenes[sceneIndex];
              return SceneEditorSection(
                scene: scene,
                actIndex: actIndex,
                sceneIndex: sceneIndex,
                onChanged: _refresh,
                canRemove: _draft.acts[actIndex].scenes.length > 1,
                onRemove: () => _removeScene(actIndex, sceneIndex),
                frames: scene.frames,
                onPickFrames: () => _pickImages(
                  FramePickTarget(
                    actIndex: actIndex,
                    sceneIndex: sceneIndex,
                  ),
                ),
                onRemoveFrame: (frameIndex) {
                  _removeFrame(actIndex, sceneIndex, frameIndex);
                },
                onCaptionChanged: (frameIndex, value) {
                  scene.frames[frameIndex].caption = value;
                },
                onActionNoteChanged: (frameIndex, value) {
                  scene.frames[frameIndex].actionNote = value;
                },
              );
            },
          ),
        TextButton.icon(
          onPressed: _addAct,
          icon: const Icon(Icons.add),
          label: const Text('添加幕'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _buildScreenplayForm();
    final pageTitle = _isEditing ? '编辑剧本' : '上传剧本';
    final submitLabel = _isEditing ? '保存' : '发布';

    return ResponsiveBuilder(
      mobile: (_) => Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          leading: TextButton(
            onPressed: _onCancel,
            child: const Text('取消'),
          ),
          leadingWidth: 72,
          actions: [
            TextButton(
              onPressed: _isPublishing ? null : () => _onPublish(),
              child: Text(submitLabel, style: const TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              WizardStepIndicator(
                steps: AppCatalog.wizardSteps,
                currentStep: 1,
              ),
              const SizedBox(height: 20),
              form,
              if (_isPicking || _isPublishing)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _isEditing ? '保存修改' : '下一步',
                onPressed: () => _onPublish(),
                isLoading: _isPublishing,
              ),
            ],
          ),
        ),
      ),
      desktop: (_) => Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WizardStepIndicator(
                steps: AppCatalog.wizardSteps,
                currentStep: 1,
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: form),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pageTitle, style: AppTextStyles.title),
                        const SizedBox(height: 16),
                        const Text(
                          '按「剧本 → 幕 → 场 → 画」组织参考图。每张图片对应一个分镜画面。',
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (!_isEditing)
                              Expanded(
                                child: SecondaryButton(
                                  label: '保存草稿',
                                  onPressed: _draft.hasFrames && !_isPublishing
                                      ? () => _onPublish(goHome: false)
                                      : null,
                                ),
                              ),
                            if (!_isEditing) const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                                label: _isEditing ? '保存修改' : '下一步',
                                onPressed: () => _onPublish(),
                                isLoading: _isPublishing,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
