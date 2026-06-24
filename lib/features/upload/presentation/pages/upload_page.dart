import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_draft_tags.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/data/screenplay_publish_service.dart';
import '../../../screenplay/data/screenplay_tags_repository.dart';
import '../../../screenplay/data/shoot_params_draft.dart';
import '../../../screenplay/presentation/widgets/publish_visibility_dialog.dart';
import '../../data/image_pick_service.dart';
import '../../domain/upload_image_file.dart';
import '../widgets/upload_screenplay_preview_section.dart';
import '../widgets/upload_structure_editor.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, this.editScriptId});

  final String? editScriptId;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _imagePickService = ImagePickService();
  final _tagsRepo = ScreenplayTagsRepository.instance;
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

  List<String> get _poolTags => mergeTagSuggestions(
        pool: draftTagPool(_draft),
        remoteSuggestions: _tagsRepo.suggestedNames,
      );

  @override
  void initState() {
    super.initState();
    _tagsRepo.addListener(_onTagsRepoChanged);
    if (AuthRepository.instance.isLoggedIn) {
      _tagsRepo.loadTags();
    }
    final repository = ScreenplayLocalRepository.instance;
    if (_isEditing) {
      final doc = repository.documentById(widget.editScriptId!);
      _editingScript = repository.findById(widget.editScriptId!);
      _draft = doc != null
          ? screenplayDraftFromTreeDocument(doc)
          : (_editingScript != null
              ? ScreenplayDraft.fromScreenplay(_editingScript!)
              : ScreenplayDraft());
    } else {
      _draft = ScreenplayDraft();
    }
    _titleController = TextEditingController(text: _draft.title);
    _synopsisController = TextEditingController(text: _draft.synopsis);
  }

  @override
  void dispose() {
    _tagsRepo.removeListener(_onTagsRepoChanged);
    _titleController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  void _onTagsRepoChanged() {
    if (mounted) setState(() {});
  }

  void _toggleScreenplayTag(String tag) {
    toggleDraftNodeTag(_draft.tags, tag);
    _refresh();
  }

  Future<void> _addScreenplayTag(String name) async {
    addTagToDraftPool(_draft, name);
    _refresh();
    if (AuthRepository.instance.isLoggedIn) {
      final error = await _tagsRepo.createTagByName(name);
      if (error != null && mounted) _showSnackBar(error);
    }
  }

  void _toggleActTag(int actIndex, String tag) {
    toggleDraftNodeTag(_draft.acts[actIndex].tags, tag);
    _refresh();
  }

  void _toggleSceneTag(int actIndex, int sceneIndex, String tag) {
    toggleDraftNodeTag(
      _draft.acts[actIndex].scenes[sceneIndex].tags,
      tag,
    );
    _refresh();
  }

  void _toggleFrameTag(
    int actIndex,
    int sceneIndex,
    int frameIndex,
    String tag,
  ) {
    toggleDraftNodeTag(
      _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex].tags,
      tag,
    );
    _refresh();
  }

  void _refresh() => setState(() {});

  void _syncTitleToDraft() {
    _draft.title = _titleController.text.trim();
    _draft.synopsis = _synopsisController.text.trim();
  }

  void _resetDraft() {
    _draft.title = '';
    _draft.synopsis = '';
    _draft.defaultParams = AppCatalog.defaultShootParams;
    _draft.tags
      ..clear()
      ..add('站姿');
    _draft.acts
      ..clear()
      ..add(ActDraft());
    _draft.coverImage = null;
    _titleController.text = '';
    _synopsisController.text = '';
  }

  void _onCancel() {
    if (_isEditing) {
      context.go(AppRoutes.script(widget.editScriptId!));
    } else {
      _resetDraft();
      context.go(AppRoutes.discovery);
    }
  }

  Future<void> _pickCover() async {
    if (_isPicking) return;

    setState(() => _isPicking = true);
    try {
      final result = await _imagePickService.pickCover();
      if (!mounted) return;

      if (result.added.isNotEmpty) {
        _draft.coverImage = _coverImageFromPick(result.added.first);
        _refresh();
      }
      if (result.hasRejected) {
        _showSnackBar('封面格式不支持或无法提取视频首帧');
      }
    } catch (error) {
      if (mounted) _showSnackBar('选择封面失败：$error');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _resetCover() {
    _draft.coverImage = null;
    _refresh();
  }

  UploadImageFile _coverImageFromPick(UploadImageFile file) {
    if (file.isVideo && file.previewPath != null) {
      final thumb = file.previewPath!;
      return UploadImageFile(
        path: thumb,
        name: thumb.split('/').last,
      );
    }
    return file;
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

  bool _validateDraft() {
    _syncTitleToDraft();
    if (!_draft.hasFrames) {
      _showSnackBar('请至少添加一张画（分镜图）');
      return false;
    }
    return true;
  }

  Future<String?> _saveLocalDraft() async {
    if (!_validateDraft()) return null;

    final repository = ScreenplayLocalRepository.instance;
    if (_isEditing) {
      await repository.update(widget.editScriptId!, _draft);
      return widget.editScriptId;
    }
    final screenplay = await repository.publish(_draft);
    return screenplay.id;
  }

  Future<void> _saveLocal({bool goHome = true}) async {
    if (_isPublishing) return;

    setState(() => _isPublishing = true);
    try {
      final localId = await _saveLocalDraft();
      if (!mounted || localId == null) return;
      _showSnackBar('已保存到本地');
      if (goHome) {
        context.go(
          _isEditing ? AppRoutes.script(localId) : AppRoutes.discovery,
        );
      }
    } catch (error) {
      if (mounted) _showSnackBar('保存失败：$error');
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _publishToCloud() async {
    if (_isPublishing) return;

    if (!AuthRepository.instance.isLoggedIn) {
      final redirect = _isEditing
          ? AppRoutes.uploadEdit(widget.editScriptId!)
          : AppRoutes.upload;
      context.go(AppRoutes.loginWithRedirect(redirect));
      return;
    }

    setState(() => _isPublishing = true);
    String? localId;
    try {
      localId = await _saveLocalDraft();
      if (!mounted || localId == null) return;

      final repository = ScreenplayLocalRepository.instance;
      final doc = repository.documentById(localId);
      if (doc == null) {
        _showSnackBar('本地剧本不存在');
        return;
      }

      final isSync = doc.meta.remoteScreenplayId != null;
      final picked = await PublishVisibilityDialog.show(context);
      if (picked == null || !mounted) return;
      final visibility = picked;

      final progress = ValueNotifier<(String, int, int)>(('准备', 0, 1));
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => ValueListenableBuilder(
          valueListenable: progress,
          builder: (_, value, _) => PublishProgressSheet(
            stage: value.$1,
            done: value.$2,
            total: value.$3,
          ),
        ),
      );

      final result = isSync
          ? await ScreenplayPublishService.instance.syncToServer(
              document: doc,
              visibility: visibility,
              onProgress: (stage, done, total) {
                progress.value = (stage, done, total);
              },
            )
          : await ScreenplayPublishService.instance.publish(
              document: doc,
              visibility: visibility,
              onProgress: (stage, done, total) {
                progress.value = (stage, done, total);
              },
            );

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (result.error != null) {
        _showSnackBar(result.error!);
        return;
      }

      await repository.updateDocument(result.result!.document);
      if (!mounted) return;

      final remoteId = result.result!.document.meta.remoteScreenplayId;
      if (remoteId != null) {
        final tagError = await ScreenplayTagsRepository.instance
            .applyTagsToScreenplay(
          screenplayId: remoteId,
          currentNames: _editingScript?.tags ?? [],
          desiredNames: draftTagPool(_draft),
        );
        if (tagError != null && mounted) {
          _showSnackBar('标签同步失败：$tagError');
        }
      }

      final visibilityLabel = visibility == 1 ? '公开' : '非公开';
      _showSnackBar(isSync ? '已同步到云端（$visibilityLabel）' : '已发布到云端（$visibilityLabel）');
      if (!mounted) return;
      context.go(AppRoutes.script(localId));
    } catch (error) {
      if (mounted) _showSnackBar('发布失败：$error');
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

  void _reorderActs(int oldIndex, int newIndex) {
    reorderDraftActs(_draft, oldIndex, newIndex);
    _refresh();
  }

  void _moveScene(SceneDragData data, int toActIndex, int toInsertIndex) {
    moveDraftScene(
      _draft,
      scene: data.scene,
      fromActIndex: data.fromActIndex,
      toActIndex: toActIndex,
      toInsertIndex: toInsertIndex,
    );
    _refresh();
  }

  void _moveFrame(
    FrameDragData data,
    int toActIndex,
    SceneDraft toScene,
    int toInsertIndex,
  ) {
    moveDraftFrame(
      _draft,
      frame: data.frame,
      fromActIndex: data.fromActIndex,
      fromScene: data.fromScene,
      toActIndex: toActIndex,
      toScene: toScene,
      toInsertIndex: toInsertIndex,
    );
    _refresh();
  }

  Widget _buildStructureEditor() {
    return UploadStructureEditor(
      draft: _draft,
      frameCount: _frameCount,
      onChanged: _refresh,
      canRemoveAct: (_) => _draft.acts.length > 1,
      onRemoveAct: (index) => () => _removeAct(index),
      onAddScene: (actIndex) => () => _addScene(actIndex),
      canRemoveScene: (actIndex, _) => _draft.acts[actIndex].scenes.length > 1,
      onRemoveScene: (actIndex, sceneIndex) =>
          () => _removeScene(actIndex, sceneIndex),
      onPickFrames: (target) => () => _pickImages(target),
      onRemoveFrame: _removeFrame,
      onCaptionChanged: (actIndex, sceneIndex, frameIndex, value) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex].caption =
            value;
      },
      onActionNoteChanged: (actIndex, sceneIndex, frameIndex, value) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex].actionNote =
            value;
      },
      onSceneOverrideChanged: (actIndex, sceneIndex, override) {
        _draft.acts[actIndex].scenes[sceneIndex].paramOverride = override;
        _refresh();
      },
      onFrameOverrideChanged: (actIndex, sceneIndex, frameIndex, override) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex]
            .paramOverride = override;
        _refresh();
      },
      onAddAct: _addAct,
      onReorderActs: _reorderActs,
      onMoveScene: _moveScene,
      onMoveFrame: _moveFrame,
      poolTags: _poolTags,
      onToggleActTag: _toggleActTag,
      onToggleSceneTag: _toggleSceneTag,
      onToggleFrameTag: _toggleFrameTag,
    );
  }

  Widget _buildPreviewSection() {
    return UploadScreenplayPreviewSection(
      draft: _draft,
      titleController: _titleController,
      synopsisController: _synopsisController,
      onShootParamsChanged: (params) {
        setState(() => _draft.defaultParams = params);
      },
      poolTags: _poolTags,
      onToggleScreenplayTag: _toggleScreenplayTag,
      onAddScreenplayTag: _addScreenplayTag,
      tagsLoading: _tagsRepo.loading,
      tagsError: _tagsRepo.error,
      onRetryTags: () => _tagsRepo.loadTags(),
      onPickCover: _pickCover,
      onResetCover: _resetCover,
    );
  }

  Widget _buildActionButtons({bool isExpanded = true}) {
    final cloudLabel = _isEditing ? '同步到云端' : '发布到云端';
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: '保存到本地',
            isExpanded: isExpanded,
            onPressed: _isPublishing || !_draft.hasFrames ? null : _saveLocal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            label: cloudLabel,
            isExpanded: isExpanded,
            onPressed: _isPublishing || !_draft.hasFrames ? null : _publishToCloud,
            isLoading: _isPublishing,
          ),
        ),
      ],
    );
  }

  Widget _buildScreenplayForm({bool compact = false}) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewSection(),
          const SizedBox(height: 24),
          _buildStructureEditor(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildPreviewSection(),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 2,
          child: _buildStructureEditor(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _isEditing ? '编辑剧本' : '上传剧本';

    return ResponsiveBuilder(
      mobile: (_) => Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          leading: TextButton(
            onPressed: _onCancel,
            child: const Text('取消'),
          ),
          leadingWidth: 72,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildScreenplayForm(compact: true),
              if (_isPicking || _isPublishing)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      desktop: (_) => Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          leading: TextButton(
            onPressed: _onCancel,
            child: const Text('取消'),
          ),
          leadingWidth: 72,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildScreenplayForm(compact: false),
              if (_isPicking || _isPublishing)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              const SizedBox(height: 24),
              SizedBox(width: 480, child: _buildActionButtons()),
            ],
          ),
        ),
      ),
    );
  }
}
