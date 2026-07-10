import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rc0_feature_editor/rc0_feature_editor.dart';

import '../../../app/providers/auth_providers.dart';

import '../../../app/router/routes.dart';
import '../../../core/data/app_catalog.dart';
import '../../../core/utils/state_listeners.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../character/data/character_repository.dart';
import '../../lighting/data/lighting_draft_binding.dart';
import '../../lighting/data/lighting_repository.dart';
import '../../screenplay/data/shoot_params_draft.dart';
import '../../screenplay/data/screenplay_draft.dart';
import '../../screenplay/data/screenplay_draft_tags.dart';
import '../../screenplay/data/screenplay_local_repository.dart';
import '../../screenplay/data/screenplay_publish_service.dart';
import '../../screenplay/data/screenplay_tags_repository.dart';
import '../../screenplay/domain/shoot_params.dart';
import '../../screenplay/presentation/widgets/publish_visibility_dialog.dart';
import '../../upload/data/image_pick_service.dart';
import '../../upload/domain/upload_image_file.dart';
import '../../upload/presentation/widgets/project_settings_sheet.dart';
import '../../upload/presentation/widgets/editor/editor_quick_action_row.dart';
import '../../upload/presentation/widgets/script_editor/script_editor_actions.dart';
import '../../upload/presentation/widgets/script_editor/script_editor_batch_edit_sheet.dart';
import '../../upload/presentation/widgets/script_editor/script_editor_navigation.dart';
import '../../upload/presentation/widgets/script_editor/script_editor_structure_mode.dart';
import '../../upload/presentation/widgets/upload_structure_editor.dart';
import '../domain/script_editor_selection.dart';
import 'studio_editor_shell_bridge.dart';

/// Shared screenplay editing state and operations for UploadPage and Studio.
class ScreenplayEditorController implements EditorControllerView {
  ScreenplayEditorController._({
    required this.draft,
    required this.titleController,
    required this.synopsisController,
    required this.editScriptId,
    required this.editingScript,
    required this.isPicking,
    required this.isPublishing,
    required this.saveStatus,
    required this.saveError,
    required this.poolTags,
    required this.tagsLoading,
    required this.tagsError,
    required this.canUndo,
    required this.canRedo,
    required this.onChanged,
    required this.onCancel,
    required this.onPickCover,
    required this.onResetCover,
    required this.onSaveLocal,
    required this.onPublishToCloud,
    required this.onUndo,
    required this.onRedo,
    required this.buildEditorActions,
    required this.buildStructureMode,
    required this.buildStructureEditor,
    required this.openProjectSettings,
    required this.syncTitleToDraft,
    required this.toggleScreenplayTag,
    required this.addScreenplayTag,
    required this.retryTags,
    required this.onShootParamsChanged,
    required this.lastSavedAt,
  });

  final ScreenplayDraft draft;
  final TextEditingController titleController;
  final TextEditingController synopsisController;
  final String? editScriptId;
  final Screenplay? editingScript;
  @override
  final bool isPicking;
  @override
  final bool isPublishing;
  @override
  final EditorSaveStatus saveStatus;
  @override
  final String? saveError;
  final List<String> poolTags;
  final bool tagsLoading;
  final String? tagsError;
  @override
  final bool canUndo;
  @override
  final bool canRedo;
  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final Future<void> Function() onPickCover;
  final VoidCallback onResetCover;
  final Future<void> Function({bool goHome, bool? requireFrames}) onSaveLocal;
  final Future<void> Function() onPublishToCloud;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final ScriptEditorActions Function() buildEditorActions;
  final Widget Function() buildStructureMode;
  final Widget Function() buildStructureEditor;
  final Future<void> Function() openProjectSettings;
  final void Function() syncTitleToDraft;
  final void Function(String) toggleScreenplayTag;
  final Future<void> Function(String) addScreenplayTag;
  final VoidCallback retryTags;
  final void Function(ShootParams) onShootParamsChanged;
  @override
  final DateTime? lastSavedAt;

  @override
  bool get isEditing =>
      editScriptId != null && editScriptId!.isNotEmpty;

  @override
  bool get isCreateMode => !isEditing;

  bool get isPublished => editingScript?.isPublished ?? false;

  @override
  EditorOpenMode get openMode {
    if (isCreateMode) return EditorOpenMode.create;
    if (editingScript?.id != null) return EditorOpenMode.editRemote;
    return EditorOpenMode.editLocal;
  }

  @override
  int get frameCount => countDraftFrames(draft);

  @override
  String get hierarchySummary => draftHierarchySummary(draft);

  @override
  EditorSessionSnapshot get sessionSnapshot => EditorSessionSnapshot(
        saveStatus: saveStatus,
        isPublishing: isPublishing,
        isPicking: isPicking,
        canUndo: canUndo,
        canRedo: canRedo,
        saveError: saveError,
        lastSavedAt: lastSavedAt,
      );
}

class ScreenplayEditorHost extends ConsumerStatefulWidget {
  const ScreenplayEditorHost({
    super.key,
    this.editScriptId,
    this.initialCharacterId,
    this.initialCharacterName,
    this.initialLightingSchemeId,
    this.enableAutoSave = false,
    this.registerShellBridge = false,
    required this.builder,
  });

  final String? editScriptId;
  final int? initialCharacterId;
  final String? initialCharacterName;
  final String? initialLightingSchemeId;
  final bool enableAutoSave;
  final bool registerShellBridge;
  final Widget Function(BuildContext context, ScreenplayEditorController controller)
      builder;

  @override
  ConsumerState<ScreenplayEditorHost> createState() =>
      _ScreenplayEditorHostState();
}

class _ScreenplayEditorHostState extends ConsumerState<ScreenplayEditorHost> {
  static const _maxUndoSteps = 30;

  final _imagePickService = ImagePickService();
  final _tagsRepo = ScreenplayTagsRepository.instance;
  late final ScreenplayDraft _draft;
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  Screenplay? _editingScript;
  bool _isPicking = false;
  bool _isPublishing = false;
  EditorSaveStatus _saveStatus = EditorSaveStatus.idle;
  String? _saveError;
  Timer? _autoSaveTimer;
  final List<ScreenplayDraft> _undoStack = [];
  final List<ScreenplayDraft> _redoStack = [];
  bool _isRestoringHistory = false;
  String? _localScriptId;
  DateTime? _lastSavedAt;

  String? get _effectiveLocalId {
    if (_localScriptId != null && _localScriptId!.isNotEmpty) {
      return _localScriptId;
    }
    if (widget.editScriptId != null && widget.editScriptId!.isNotEmpty) {
      return widget.editScriptId;
    }
    return null;
  }

  bool get _isEditing => _effectiveLocalId != null;

  bool get _isPublished => _editingScript?.isPublished ?? false;

  List<String> get _poolTags => mergeTagSuggestions(
        pool: draftTagPool(_draft),
        remoteSuggestions: _tagsRepo.suggestedNames,
      );

  @override
  void initState() {
    super.initState();
    _tagsRepo.addListener(_onTagsRepoChanged);
    if (ref.read(isLoggedInProvider)) {
      _tagsRepo.loadTags();
    }
    _loadDraft();
    _titleController = TextEditingController(text: _draft.title);
    _synopsisController = TextEditingController(text: _draft.synopsis);
    _undoStack.add(_draft.copyDeep());
    if (widget.registerShellBridge) {
      StudioEditorShellBridge.instance.beginEditorSession();
      _syncShellBridge();
    }
  }

  void _loadDraft() {
    final repository = ScreenplayLocalRepository.instance;
    final id = widget.editScriptId;
    if (id != null && id.isNotEmpty) {
      _localScriptId = id;
      final doc = repository.documentById(id);
      _editingScript = repository.findById(id);
      _draft = doc != null
          ? screenplayDraftFromTreeDocument(doc)
          : (_editingScript != null
              ? ScreenplayDraft.fromScreenplay(_editingScript!)
              : ScreenplayDraft());
    } else {
      _draft = ScreenplayDraft();
      _editingScript = null;
      _localScriptId = null;
    }
    _applyInitialCharacter();
    _applyInitialLightingScheme();
    // ignore: discarded_futures
    _hydrateRemoteCast();
  }

  Future<void> _hydrateRemoteCast() async {
    final remoteId = _resolveRemoteScreenplayId();
    if (remoteId == null || remoteId <= 0) return;
    final result =
        await CharacterRepository.instance.listScreenplayCast(remoteId);
    if (result.error != null || result.items.isEmpty || !mounted) return;
    var changed = false;
    for (final cast in result.items) {
      final id = cast.characterId.toInt();
      if (id <= 0) continue;
      var name = cast.billingName.trim();
      if (name.isEmpty) {
        final detail = await CharacterRepository.instance.fetchDetail(id);
        name = detail.character?.name.trim() ?? '';
      }
      if (name.isEmpty) name = '角色$id';
      if (_draft.linkedCharacters.any((c) => c.id == id)) {
        // Still apply default costume to first unbound frame if needed.
        continue;
      }
      ensureDraftCharacterLinked(_draft, id: id, name: name);
      final costumeId = cast.defaultCostumeId?.toInt();
      if (costumeId != null && costumeId > 0) {
        for (final act in _draft.acts) {
          for (final scene in act.scenes) {
            for (final frame in scene.frames) {
              if (frame.characterId == id && frame.costumeId == null) {
                frame.costumeId = costumeId;
              }
            }
          }
        }
      }
      changed = true;
    }
    if (changed && mounted) setState(() {});
  }

  void _applyInitialLightingScheme() {
    final schemeId = widget.initialLightingSchemeId?.trim();
    if (schemeId == null || schemeId.isEmpty) return;
    final scheme = LightingRepository.instance.findById(schemeId);
    if (scheme == null) return;
    applyLightingSchemeToDraft(_draft, scheme);
  }

  void _applyInitialCharacter() {
    final id = widget.initialCharacterId;
    if (id == null || id <= 0) return;
    final name = widget.initialCharacterName?.trim() ?? '';
    ensureDraftCharacterLinked(
      _draft,
      id: id,
      name: name.isNotEmpty ? name : '角色$id',
    );
    _bindCharacterToFirstOpenFrame(id, name);
  }

  void _bindCharacterToFirstOpenFrame(int id, String name) {
    for (final act in _draft.acts) {
      for (final scene in act.scenes) {
        for (final frame in scene.frames) {
          if (frame.characterId != null) continue;
          frame.characterId = id;
          if (name.isNotEmpty) {
            frame.characterName = name;
          }
          return;
        }
      }
    }
  }

  @override
  void dispose() {
    if (widget.registerShellBridge) {
      StudioEditorShellBridge.instance.clear();
    }
    _autoSaveTimer?.cancel();
    _tagsRepo.removeListener(_onTagsRepoChanged);
    _titleController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  void _onTagsRepoChanged() => scheduleSetState(this);

  void _safeSetState(VoidCallback update) {
    if (!mounted) return;
    setState(update);
  }

  void _pushUndoSnapshot() {
    if (_isRestoringHistory) return;
    _undoStack.add(_draft.copyDeep());
    if (_undoStack.length > _maxUndoSteps) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void _refresh({bool recordHistory = true}) {
    if (!mounted) return;
    if (recordHistory && !_isRestoringHistory) {
      _pushUndoSnapshot();
    }
    _safeSetState(() {});
    if (widget.enableAutoSave) {
      _scheduleAutoSave();
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _saveLocal(goHome: false, silent: true);
    });
  }

  void _undo() {
    if (_undoStack.length <= 1) return;
    _isRestoringHistory = true;
    _redoStack.add(_draft.copyDeep());
    _undoStack.removeLast();
    final previous = _undoStack.last.copyDeep();
    _applyDraft(previous);
    _isRestoringHistory = false;
    _safeSetState(() {});
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _isRestoringHistory = true;
    final next = _redoStack.removeLast().copyDeep();
    _pushUndoSnapshot();
    _applyDraft(next);
    _isRestoringHistory = false;
    _safeSetState(() {});
  }

  void _applyDraft(ScreenplayDraft source) {
    _draft.title = source.title;
    _draft.synopsis = source.synopsis;
    _draft.tags
      ..clear()
      ..addAll(source.tags);
    _draft.defaultParams = source.defaultParams.copyWith();
    _draft.coverImage = source.coverImage == null
        ? null
        : UploadImageFile(
            path: source.coverImage!.path,
            name: source.coverImage!.name,
            previewPath: source.coverImage!.previewPath,
          );
    _draft.acts
      ..clear()
      ..addAll(source.acts.map((a) => a.copyDeep()));
    _titleController.text = _draft.title;
    _synopsisController.text = _draft.synopsis;
  }

  void _toggleScreenplayTag(String tag) {
    toggleDraftNodeTag(_draft.tags, tag);
    _refresh();
  }

  Future<void> _addScreenplayTag(String name) async {
    addTagToDraftPool(_draft, name);
    _refresh();
    if (ref.read(isLoggedInProvider)) {
      final error = await _tagsRepo.createTagByName(name);
      if (error != null && mounted) _showSnackBar(error);
    }
  }

  void _toggleActTag(int actIndex, String tag) {
    toggleDraftNodeTag(_draft.acts[actIndex].tags, tag);
    _refresh();
  }

  void _toggleSceneTag(int actIndex, int sceneIndex, String tag) {
    toggleDraftNodeTag(_draft.acts[actIndex].scenes[sceneIndex].tags, tag);
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

  void _syncTitleToDraft() {
    if (!mounted) return;
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
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.script(_effectiveLocalId!));
      }
    } else {
      _resetDraft();
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.discovery);
      }
    }
  }

  Future<void> _pickCover() async {
    if (!mounted) return;
    if (_isPicking) return;
    _safeSetState(() => _isPicking = true);
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
      _safeSetState(() => _isPicking = false);
    }
  }

  void _resetCover() {
    _draft.coverImage = null;
    _refresh();
  }

  UploadImageFile _coverImageFromPick(UploadImageFile file) {
    if (file.isVideo && file.previewPath != null) {
      final thumb = file.previewPath!;
      return UploadImageFile(path: thumb, name: thumb.split('/').last);
    }
    return file;
  }

  Future<void> _pickImages(FramePickTarget target) async {
    if (!mounted) return;
    if (_isPicking) return;
    _safeSetState(() => _isPicking = true);
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
      _safeSetState(() => _isPicking = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _hasPersistableContent() {
    _syncTitleToDraft();
    if (_draft.hasFrames) return true;
    if (_draft.title.isNotEmpty || _draft.synopsis.isNotEmpty) return true;
    if (_draft.coverImage != null) return true;
    if (_draft.acts.length > 1) return true;
    for (final act in _draft.acts) {
      if (act.scenes.length > 1) return true;
      if (act.title.trim().isNotEmpty || act.synopsis.trim().isNotEmpty) {
        return true;
      }
      for (final scene in act.scenes) {
        if (scene.title.trim().isNotEmpty &&
            scene.title.trim() != '第一场') {
          return true;
        }
        if (scene.location.isNotEmpty ||
            scene.timeOfDay.isNotEmpty ||
            scene.weather.isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  bool _validateDraft({required bool requireFrames, bool showError = true}) {
    _syncTitleToDraft();
    if (requireFrames && !_draft.hasFrames) {
      if (showError) _showSnackBar('请至少添加一张画（分镜图）');
      return false;
    }
    if (!requireFrames && !_hasPersistableContent()) {
      if (showError) _showSnackBar('请先填写标题或添加幕场内容');
      return false;
    }
    return true;
  }

  Future<String?> _saveLocalDraft({
    bool requireFrames = true,
    bool showError = true,
  }) async {
    if (!_validateDraft(
      requireFrames: requireFrames,
      showError: showError,
    )) {
      return null;
    }
    final repository = ScreenplayLocalRepository.instance;
    final existingId = _effectiveLocalId;
    if (existingId != null) {
      await repository.update(existingId, _draft);
      return existingId;
    }
    final screenplay = await repository.publish(_draft);
    _localScriptId = screenplay.id;
    _editingScript = repository.findById(screenplay.id);
    return screenplay.id;
  }

  void _syncShellBridge() {
    if (!widget.registerShellBridge) return;
    StudioEditorShellBridge.instance.register(
      onAddAct: _addAct,
      onAddScene: _addSceneFromShell,
      onSaveLocal: _saveLocal,
      saveBusy: _isPublishing || _saveStatus == EditorSaveStatus.saving,
    );
  }

  void _syncHubBridge(BuildContext context) {
    if (!widget.registerShellBridge) return;
    StudioEditorShellBridge.instance.attachHubCallbacks(
      owner: this,
      onAiDecompose: () => openAiCreationHub(
        context,
        editScriptId: _effectiveLocalId,
      ),
      onMore: () => _openEditorMoreSheet(context),
    );
  }

  void _openEditorMoreSheet(BuildContext context) {
    showEditorMoreActionsSheet(
      context,
      onOpenProjectSettings: _openProjectSettings,
      onBatchEdit: () => ScriptEditorBatchEditSheet.show(
        context,
        draft: _draft,
        scope: BatchEditScope.entireScript,
        onApply: _refresh,
      ),
      onOpenShotList: () => openShotList(
        context,
        draft: _draft,
        actions: _buildEditorActions(),
      ),
    );
  }

  void _addSceneFromShell() {
    if (_draft.acts.isEmpty) {
      _addAct();
    }
    final actIndex = _draft.acts.isEmpty ? 0 : _draft.acts.length - 1;
    _addScene(actIndex);
  }

  Future<void> _saveLocal({
    bool goHome = true,
    bool silent = false,
    bool? requireFrames,
  }) async {
    if (!mounted) return;
    if (_isPublishing && silent) return;
    final wasCreate = _effectiveLocalId == null;
    final framesRequired = requireFrames ?? !silent;
    _safeSetState(() {
      _isPublishing = true;
      _saveStatus = EditorSaveStatus.saving;
      _saveError = null;
    });
    try {
      final localId = await _saveLocalDraft(
        requireFrames: framesRequired,
        showError: !silent || requireFrames == true,
      );
      if (!mounted) return;
      if (localId == null) {
        _safeSetState(() => _saveStatus = EditorSaveStatus.error);
        return;
      }
      _lastSavedAt = DateTime.now();
      _safeSetState(() => _saveStatus = EditorSaveStatus.saved);
      if (!silent) _showSnackBar('已保存到本地');
      if (wasCreate && widget.editScriptId == null) {
        context.go(AppRoutes.studioEdit(localId));
        return;
      }
      if (goHome) {
        context.go(AppRoutes.script(localId));
      }
    } catch (error) {
      if (mounted) {
        _saveError = '$error';
        _saveStatus = EditorSaveStatus.error;
        if (!silent) _showSnackBar('保存失败：$error');
      }
    } finally {
      _safeSetState(() => _isPublishing = false);
    }
  }

  Future<void> _publishToCloud() async {
    if (!mounted) return;
    if (_isPublishing) return;
    if (!ref.read(isLoggedInProvider)) {
      final redirect = _effectiveLocalId != null
          ? AppRoutes.studioEdit(_effectiveLocalId!)
          : AppRoutes.studioCreate;
      context.go(AppRoutes.loginWithRedirect(redirect));
      return;
    }
    _safeSetState(() => _isPublishing = true);
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
      final progress = ValueNotifier<(String, int, int)>(('准备', 0, 1));
      showPublishProgressSheet(context, progress: progress);
      final result = isSync
          ? await ScreenplayPublishService.instance.syncToServer(
              document: doc,
              visibility: picked.visibility,
              onProgress: (stage, done, total) {
                progress.value = (stage, done, total);
              },
            )
          : await ScreenplayPublishService.instance.publish(
              document: doc,
              visibility: picked.visibility,
              kind: picked.kind,
              onProgress: (stage, done, total) {
                progress.value = (stage, done, total);
              },
            );
      if (!mounted) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      if (result.error != null) {
        _showSnackBar(result.error!);
        return;
      }
      await repository.updateDocument(result.result!.document);
      if (!mounted) return;
      final remoteId = result.result!.document.meta.remoteScreenplayId;
      if (remoteId != null) {
        final tagError = await _tagsRepo.applyTagsToScreenplay(
          screenplayId: remoteId,
          currentNames: _editingScript?.tags ?? [],
          desiredNames: draftTagPool(_draft),
        );
        if (tagError != null && mounted) {
          _showSnackBar('标签同步失败：$tagError');
        }
      }
      final visibilityLabel = picked.visibility == 1 ? '公开' : '非公开';
      final kindLabel =
          picked.kind == Screenplay.kindTemplate ? '模板' : '作品';
      _showSnackBar(
        isSync
            ? '已同步到云端（$visibilityLabel）'
            : '已发布到云端（$kindLabel · $visibilityLabel）',
      );
      if (mounted) context.go(AppRoutes.script(localId));
    } catch (error) {
      if (mounted) _showSnackBar('发布失败：$error');
    } finally {
      _safeSetState(() => _isPublishing = false);
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

  void _onSceneFieldChanged(
    int actIndex,
    int sceneIndex, {
    String? title,
    String? location,
    String? timeOfDay,
    String? weather,
  }) {
    final scene = _draft.acts[actIndex].scenes[sceneIndex];
    if (title != null) scene.title = title;
    if (location != null) scene.location = location;
    if (timeOfDay != null) scene.timeOfDay = timeOfDay;
    if (weather != null) scene.weather = weather;
    _refresh(recordHistory: false);
  }

  ScriptEditorActions _buildEditorActions() {
    return ScriptEditorActions(
      draft: _draft,
      onChanged: () => _refresh(recordHistory: false),
      poolTags: _poolTags,
      onPickFrames: _pickImages,
      onRemoveFrame: _removeFrame,
      onCaptionChanged: (actIndex, sceneIndex, frameIndex, value) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex].caption =
            value;
      },
      onActionNoteChanged: (actIndex, sceneIndex, frameIndex, value) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex].actionNote =
            value;
      },
      onCineParamsChanged: (actIndex, sceneIndex, frameIndex, params) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex].cineParams =
            params;
        _refresh(recordHistory: false);
      },
      onPositivePromptChanged: (actIndex, sceneIndex, frameIndex, value) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex]
            .positivePrompt = value;
      },
      onNegativePromptChanged: (actIndex, sceneIndex, frameIndex, value) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex]
            .negativePrompt = value;
      },
      onSceneOverrideChanged: (actIndex, sceneIndex, override) {
        _draft.acts[actIndex].scenes[sceneIndex].paramOverride = override;
        _refresh(recordHistory: false);
      },
      onFrameOverrideChanged: (actIndex, sceneIndex, frameIndex, override) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex]
            .paramOverride = override;
        _refresh(recordHistory: false);
      },
      onToggleSceneTag: _toggleSceneTag,
      onToggleFrameTag: _toggleFrameTag,
      onMoveFrame: _moveFrame,
      onMoveScene: _moveScene,
      canRemoveScene: (actIndex, _) => _draft.acts[actIndex].scenes.length > 1,
      onRemoveScene: _removeScene,
      onSceneFieldChanged: _onSceneFieldChanged,
      remoteScreenplayId: _resolveRemoteScreenplayId(),
    );
  }

  int? _resolveRemoteScreenplayId() {
    final fromScript = _editingScript?.remoteScreenplayId;
    if (fromScript != null && fromScript > 0) return fromScript;
    final localId = _localScriptId ?? widget.editScriptId;
    if (localId == null || localId.isEmpty) return null;
    return ScreenplayLocalRepository.instance
        .documentById(localId)
        ?.meta
        .remoteScreenplayId;
  }

  Widget _buildStructureMode() {
    return ScriptEditorStructureMode(
      draft: _draft,
      frameCount: countDraftFrames(_draft),
      onChanged: () => _refresh(recordHistory: false),
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
        _refresh(recordHistory: false);
      },
      onFrameOverrideChanged: (actIndex, sceneIndex, frameIndex, override) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex]
            .paramOverride = override;
        _refresh(recordHistory: false);
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

  Widget _buildStructureEditor() {
    return UploadStructureEditor(
      draft: _draft,
      frameCount: countDraftFrames(_draft),
      onChanged: () => _refresh(recordHistory: false),
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
        _refresh(recordHistory: false);
      },
      onFrameOverrideChanged: (actIndex, sceneIndex, frameIndex, override) {
        _draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex]
            .paramOverride = override;
        _refresh(recordHistory: false);
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

  Future<void> _openProjectSettings() async {
    if (!mounted) return;
    final titleController = TextEditingController(text: _titleController.text);
    final synopsisController =
        TextEditingController(text: _synopsisController.text);
    try {
      await showProjectSettingsSheet(
        context,
        draft: _draft,
        titleController: titleController,
        synopsisController: synopsisController,
        onShootParamsChanged: (params) {
          _safeSetState(() => _draft.defaultParams = params);
        },
        poolTags: _poolTags,
        onToggleScreenplayTag: _toggleScreenplayTag,
        onAddScreenplayTag: _addScreenplayTag,
        tagsLoading: _tagsRepo.loading,
        tagsError: _tagsRepo.error,
        onRetryTags: () => _tagsRepo.loadTags(),
        onPickCover: _pickCover,
        onResetCover: _resetCover,
        onSyncTitle: () {
          if (!mounted) return;
          _titleController.text = titleController.text;
          _synopsisController.text = synopsisController.text;
          _syncTitleToDraft();
        },
        remoteScreenplayId: _resolveRemoteScreenplayId(),
      );
      if (mounted) _refresh(recordHistory: false);
    } finally {
      titleController.dispose();
      synopsisController.dispose();
    }
  }

  ScreenplayEditorController _buildController() {
    return ScreenplayEditorController._(
      draft: _draft,
      titleController: _titleController,
      synopsisController: _synopsisController,
      editScriptId: _effectiveLocalId,
      editingScript: _editingScript,
      isPicking: _isPicking,
      isPublishing: _isPublishing,
      saveStatus: _saveStatus,
      saveError: _saveError,
      poolTags: _poolTags,
      tagsLoading: _tagsRepo.loading,
      tagsError: _tagsRepo.error,
      canUndo: _undoStack.length > 1,
      canRedo: _redoStack.isNotEmpty,
      onChanged: () => _refresh(),
      onCancel: _onCancel,
      onPickCover: _pickCover,
      onResetCover: _resetCover,
      onSaveLocal: _saveLocal,
      onPublishToCloud: _publishToCloud,
      onUndo: _undo,
      onRedo: _redo,
      buildEditorActions: _buildEditorActions,
      buildStructureMode: _buildStructureMode,
      buildStructureEditor: _buildStructureEditor,
      openProjectSettings: _openProjectSettings,
      syncTitleToDraft: _syncTitleToDraft,
      toggleScreenplayTag: _toggleScreenplayTag,
      addScreenplayTag: _addScreenplayTag,
      retryTags: () => _tagsRepo.loadTags(),
      onShootParamsChanged: (params) {
        _safeSetState(() => _draft.defaultParams = params);
      },
      lastSavedAt: _lastSavedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.registerShellBridge) {
      _syncShellBridge();
      _syncHubBridge(context);
    }
    return widget.builder(context, _buildController());
  }
}

// Expose structure helpers for workspace panels
extension ScreenplayEditorHostMutations on ScreenplayEditorController {
  void addAct() {
    draft.acts.add(ActDraft());
    onChanged();
  }

  void addScene(int actIndex) {
    draft.acts[actIndex].scenes.add(SceneDraft());
    onChanged();
  }

  bool canRemoveAct() => draft.acts.length > 1;

  Future<void> removeAct(int actIndex) async {
    if (draft.acts.length <= 1) return;
    draft.acts.removeAt(actIndex);
    onChanged();
  }

  void reorderActs(int oldIndex, int newIndex) {
    reorderDraftActs(draft, oldIndex, newIndex);
    onChanged();
  }

  void moveScene(SceneDragData data, int toActIndex, int toInsertIndex) {
    moveDraftScene(
      draft,
      scene: data.scene,
      fromActIndex: data.fromActIndex,
      toActIndex: toActIndex,
      toInsertIndex: toInsertIndex,
    );
    onChanged();
  }

  Future<void> removeFrames(List<DraftFrameRef> refs) async {
    final sorted = List<DraftFrameRef>.from(refs)
      ..sort((a, b) {
        final act = b.actIndex.compareTo(a.actIndex);
        if (act != 0) return act;
        final scene = b.sceneIndex.compareTo(a.sceneIndex);
        if (scene != 0) return scene;
        return b.frameIndex.compareTo(a.frameIndex);
      });
    for (final ref in sorted) {
      final scene = draft.acts[ref.actIndex].scenes[ref.sceneIndex];
      if (scene.frames.length <= 1 && isPublished) continue;
      if (ref.frameIndex < scene.frames.length) {
        scene.frames.removeAt(ref.frameIndex);
      }
    }
    onChanged();
  }

  FramePickTarget defaultPickTarget(ScriptEditorSelection selection) {
    if (selection.hasScene) {
      return FramePickTarget(
        actIndex: selection.actIndex!,
        sceneIndex: selection.sceneIndex!,
      );
    }
    final actIndex = draft.acts.isEmpty ? 0 : draft.acts.length - 1;
    final scenes = draft.acts[actIndex].scenes;
    final sceneIndex = scenes.isEmpty ? 0 : scenes.length - 1;
    return FramePickTarget(actIndex: actIndex, sceneIndex: sceneIndex);
  }

  void duplicateFrameParams(DraftFrameRef ref) {
    final scene = draft.acts[ref.actIndex].scenes[ref.sceneIndex];
    final nextIndex = ref.frameIndex + 1;
    if (nextIndex >= scene.frames.length) return;
    final source = scene.frames[ref.frameIndex];
    final target = scene.frames[nextIndex];
    target.cineParams = source.cineParams.copyWith();
    target.positivePrompt = source.positivePrompt;
    target.negativePrompt = source.negativePrompt;
    target.characterNote = source.characterNote;
    target.paramOverride = source.paramOverride?.copyWith();
    onChanged();
  }
}
